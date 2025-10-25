#!/usr/bin/env bash
#
# Dockerfile Generator from Azure Web App Configuration
#
# This script generates Dockerfiles based on Azure Web App runtime configurations
# extracted from the azure-infrastructure-extractor.sh output.
#
# Usage: ./dockerfile-generator.sh <webapp-config-directory> [output-directory]
#

set -euo pipefail

# Configuration
WEBAPP_DIR="${1:-}"
OUTPUT_DIR="${2:-.}"

# Color output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Validate input
if [[ -z "$WEBAPP_DIR" ]]; then
    log_error "Usage: $0 <webapp-config-directory> [output-directory]"
    exit 1
fi

if [[ ! -d "$WEBAPP_DIR" ]]; then
    log_error "Directory not found: $WEBAPP_DIR"
    exit 1
fi

WEBAPP_NAME=$(basename "$WEBAPP_DIR")
log_info "Generating Dockerfile for: $WEBAPP_NAME"

# Read runtime configuration
RUNTIME_FILE="$WEBAPP_DIR/runtime.json"
STARTUP_FILE="$WEBAPP_DIR/startup.json"
CONTAINER_FILE="$WEBAPP_DIR/container-settings.json"

if [[ ! -f "$RUNTIME_FILE" ]]; then
    log_error "Runtime configuration not found: $RUNTIME_FILE"
    exit 1
fi

# Parse runtime information
runtime_json=$(cat "$RUNTIME_FILE")
linux_fx=$(echo "$runtime_json" | jq -r '.runtime // empty')
node_version=$(echo "$runtime_json" | jq -r '.nodeVersion // empty')
python_version=$(echo "$runtime_json" | jq -r '.pythonVersion // empty')
php_version=$(echo "$runtime_json" | jq -r '.phpVersion // empty')
java_version=$(echo "$runtime_json" | jq -r '.javaVersion // empty')
net_version=$(echo "$runtime_json" | jq -r '.netFrameworkVersion // empty')

# Parse startup command if available
startup_cmd=""
if [[ -f "$STARTUP_FILE" ]]; then
    startup_cmd=$(jq -r '.appCommandLine // empty' "$STARTUP_FILE")
fi

# Determine runtime and generate Dockerfile
generate_dockerfile() {
    local dockerfile_path="$OUTPUT_DIR/Dockerfile"

    log_info "Detected runtime: $linux_fx"

    # Node.js
    if [[ "$linux_fx" == *"NODE"* ]] || [[ -n "$node_version" ]]; then
        generate_nodejs_dockerfile "$dockerfile_path"

    # Python
    elif [[ "$linux_fx" == *"PYTHON"* ]] || [[ -n "$python_version" ]]; then
        generate_python_dockerfile "$dockerfile_path"

    # .NET
    elif [[ "$linux_fx" == *"DOTNET"* ]] || [[ -n "$net_version" ]]; then
        generate_dotnet_dockerfile "$dockerfile_path"

    # PHP
    elif [[ "$linux_fx" == *"PHP"* ]] || [[ -n "$php_version" ]]; then
        generate_php_dockerfile "$dockerfile_path"

    # Java
    elif [[ "$linux_fx" == *"JAVA"* ]] || [[ -n "$java_version" ]]; then
        generate_java_dockerfile "$dockerfile_path"

    # Docker container (already containerized)
    elif [[ -f "$CONTAINER_FILE" ]] && [[ $(jq -r '.linuxFxVersion // empty' "$CONTAINER_FILE") != "" ]]; then
        generate_container_info "$dockerfile_path"

    else
        log_warning "Unknown or unsupported runtime. Generating generic Dockerfile."
        generate_generic_dockerfile "$dockerfile_path"
    fi

    log_success "Dockerfile generated: $dockerfile_path"
}

# Node.js Dockerfile
generate_nodejs_dockerfile() {
    local output="$1"

    # Extract Node version
    local node_ver="18"  # Default
    if [[ "$linux_fx" =~ NODE\|([0-9]+) ]]; then
        node_ver="${BASH_REMATCH[1]}"
    elif [[ -n "$node_version" ]]; then
        node_ver="$node_version"
    fi

    cat > "$output" <<EOF
# Generated Dockerfile for Node.js Application
# Based on Azure Web App: $WEBAPP_NAME

FROM node:${node_ver}-alpine AS build

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY . .

# Build if necessary (uncomment if you have a build step)
# RUN npm run build

# Production stage
FROM node:${node_ver}-alpine

WORKDIR /app

# Copy dependencies and code from build stage
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app .

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \\
    adduser -S nodejs -u 1001

USER nodejs

# Expose port (Azure App Service uses 8080 by default, adjust as needed)
EXPOSE 8080

# Environment variables (can be overridden)
ENV NODE_ENV=production
ENV PORT=8080

# Startup command
EOF

    if [[ -n "$startup_cmd" ]]; then
        echo "CMD $startup_cmd" >> "$output"
    else
        echo 'CMD ["node", "index.js"]' >> "$output"
        log_warning "No startup command found. Using default: node index.js"
        log_warning "Update CMD in Dockerfile if your entry point is different"
    fi

    cat >> "$output" <<'EOF'

# Health check (adjust endpoint as needed)
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD node -e "require('http').get('http://localhost:8080/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})" || exit 1
EOF

    # Generate .dockerignore
    cat > "$OUTPUT_DIR/.dockerignore" <<'EOF'
node_modules
npm-debug.log
.env
.env.*
!.env.example
.git
.gitignore
.DS_Store
*.md
.vscode
.idea
coverage
.nyc_output
dist
build
logs
*.log
EOF

    log_success "Node.js Dockerfile created"
}

# Python Dockerfile
generate_python_dockerfile() {
    local output="$1"

    # Extract Python version
    local python_ver="3.11"  # Default
    if [[ "$linux_fx" =~ PYTHON\|([0-9.]+) ]]; then
        python_ver="${BASH_REMATCH[1]}"
    elif [[ -n "$python_version" ]]; then
        python_ver="$python_version"
    fi

    cat > "$output" <<EOF
# Generated Dockerfile for Python Application
# Based on Azure Web App: $WEBAPP_NAME

FROM python:${python_ver}-slim AS build

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \\
    gcc \\
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir --user -r requirements.txt

# Production stage
FROM python:${python_ver}-slim

WORKDIR /app

# Copy Python dependencies from build stage
COPY --from=build /root/.local /root/.local

# Copy application code
COPY . .

# Make sure scripts in .local are usable
ENV PATH=/root/.local/bin:\$PATH

# Create non-root user (optional, uncomment if needed)
# RUN useradd -m -u 1001 appuser && chown -R appuser:appuser /app
# USER appuser

# Expose port
EXPOSE 8000

# Environment variables
ENV PYTHONUNBUFFERED=1
ENV PORT=8000

# Startup command
EOF

    if [[ -n "$startup_cmd" ]]; then
        echo "CMD $startup_cmd" >> "$output"
    elif [[ -f "$WEBAPP_DIR/../app.py" ]] || [[ -f "$WEBAPP_DIR/../main.py" ]]; then
        echo 'CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]' >> "$output"
        log_warning "Using default Gunicorn command. Update if your app structure differs."
    else
        echo 'CMD ["python", "app.py"]' >> "$output"
        log_warning "Using default Python command. Update CMD in Dockerfile."
    fi

    cat >> "$output" <<'EOF'

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1
EOF

    # Generate .dockerignore
    cat > "$OUTPUT_DIR/.dockerignore" <<'EOF'
__pycache__
*.pyc
*.pyo
*.pyd
.Python
env/
venv/
ENV/
.env
.env.*
!.env.example
.git
.gitignore
*.md
.vscode
.idea
.pytest_cache
htmlcov
.coverage
*.log
EOF

    log_success "Python Dockerfile created"
}

# .NET Dockerfile
generate_dotnet_dockerfile() {
    local output="$1"

    # Extract .NET version
    local dotnet_ver="8.0"  # Default
    if [[ "$linux_fx" =~ DOTNETCORE\|([0-9.]+) ]]; then
        dotnet_ver="${BASH_REMATCH[1]}"
    fi

    cat > "$output" <<EOF
# Generated Dockerfile for .NET Application
# Based on Azure Web App: $WEBAPP_NAME

FROM mcr.microsoft.com/dotnet/sdk:${dotnet_ver} AS build

WORKDIR /src

# Copy csproj and restore dependencies
COPY *.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:${dotnet_ver}

WORKDIR /app

# Copy published app
COPY --from=build /app/publish .

# Create non-root user
RUN useradd -m -u 1001 dotnetuser
USER dotnetuser

# Expose port
EXPOSE 8080

# Environment variables
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Startup command
ENTRYPOINT ["dotnet", "YourApp.dll"]

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \\
    CMD curl -f http://localhost:8080/health || exit 1
EOF

    log_warning "Update 'YourApp.dll' in ENTRYPOINT to match your .NET assembly name"

    # Generate .dockerignore
    cat > "$OUTPUT_DIR/.dockerignore" <<'EOF'
bin/
obj/
.vs/
.vscode/
*.user
*.suo
.git
.gitignore
*.md
.env
.env.*
!.env.example
EOF

    log_success ".NET Dockerfile created"
}

# PHP Dockerfile
generate_php_dockerfile() {
    local output="$1"

    # Extract PHP version
    local php_ver="8.2"  # Default
    if [[ "$linux_fx" =~ PHP\|([0-9.]+) ]]; then
        php_ver="${BASH_REMATCH[1]}"
    elif [[ -n "$php_version" ]]; then
        php_ver="$php_version"
    fi

    cat > "$output" <<EOF
# Generated Dockerfile for PHP Application
# Based on Azure Web App: $WEBAPP_NAME

FROM php:${php_ver}-apache

WORKDIR /var/www/html

# Install PHP extensions (customize as needed)
RUN docker-php-ext-install pdo pdo_mysql mysqli

# Enable Apache modules
RUN a2enmod rewrite

# Copy application code
COPY . /var/www/html/

# Set permissions
RUN chown -R www-data:www-data /var/www/html \\
    && chmod -R 755 /var/www/html

# Expose port
EXPOSE 80

# Apache runs as www-data by default

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \\
    CMD curl -f http://localhost/health.php || exit 1
EOF

    # Generate .dockerignore
    cat > "$OUTPUT_DIR/.dockerignore" <<'EOF'
.git
.gitignore
*.md
.env
.env.*
!.env.example
vendor/
node_modules/
.vscode
.idea
EOF

    log_success "PHP Dockerfile created"
}

# Java Dockerfile
generate_java_dockerfile() {
    local output="$1"

    # Extract Java version
    local java_ver="17"  # Default
    if [[ "$linux_fx" =~ JAVA\|([0-9]+) ]]; then
        java_ver="${BASH_REMATCH[1]}"
    elif [[ -n "$java_version" ]]; then
        java_ver="$java_version"
    fi

    cat > "$output" <<EOF
# Generated Dockerfile for Java Application
# Based on Azure Web App: $WEBAPP_NAME

FROM maven:3.9-openjdk-${java_ver} AS build

WORKDIR /app

# Copy pom.xml and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source and build
COPY src ./src
RUN mvn package -DskipTests

# Runtime stage
FROM openjdk:${java_ver}-jdk-slim

WORKDIR /app

# Copy JAR from build stage
COPY --from=build /app/target/*.jar app.jar

# Create non-root user
RUN useradd -m -u 1001 javauser
USER javauser

# Expose port
EXPOSE 8080

# Environment variables
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# Startup command
ENTRYPOINT ["sh", "-c", "java \$JAVA_OPTS -jar app.jar"]

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \\
    CMD curl -f http://localhost:8080/actuator/health || exit 1
EOF

    # Generate .dockerignore
    cat > "$OUTPUT_DIR/.dockerignore" <<'EOF'
target/
.mvn/
.git
.gitignore
*.md
.env
.env.*
!.env.example
.vscode
.idea
EOF

    log_success "Java Dockerfile created"
}

# Container-based app (already using Docker)
generate_container_info() {
    local output="$1"

    local container_image=$(jq -r '.linuxFxVersion // empty' "$CONTAINER_FILE")
    local registry_url=$(jq -r '.dockerRegistryServerUrl // empty' "$CONTAINER_FILE")
    local registry_user=$(jq -r '.dockerRegistryServerUserName // empty' "$CONTAINER_FILE")

    cat > "$output" <<EOF
# This app is already containerized in Azure
# Container Image: $container_image
# Registry: $registry_url
# Registry User: $registry_user

# To use this container locally:
# 1. Pull the image from the registry:
#    docker pull $container_image

# 2. Or if using a private registry:
#    docker login $registry_url -u $registry_user
#    docker pull $container_image

# 3. Run the container:
#    docker run -p 8080:80 $container_image

# For docker-compose, use:
# services:
#   app:
#     image: $container_image
#     ports:
#       - "8080:80"
#     environment:
#       # Add environment variables from .env file
#     env_file:
#       - .env
EOF

    log_info "App is already containerized. See $output for details."
}

# Generic Dockerfile
generate_generic_dockerfile() {
    local output="$1"

    cat > "$output" <<EOF
# Generic Dockerfile Template
# Based on Azure Web App: $WEBAPP_NAME
#
# CUSTOMIZE THIS FILE based on your application requirements

FROM ubuntu:22.04

WORKDIR /app

# Install dependencies (customize as needed)
RUN apt-get update && apt-get install -y \\
    curl \\
    && rm -rf /var/lib/apt/lists/*

# Copy application code
COPY . .

# Expose port
EXPOSE 8080

# Environment variables
ENV PORT=8080

# Startup command (CUSTOMIZE THIS)
CMD ["./start.sh"]

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \\
    CMD curl -f http://localhost:8080/health || exit 1
EOF

    log_warning "Generated generic Dockerfile. Please customize it for your application."
}

# Generate docker-compose service entry
generate_compose_entry() {
    log_info "Generating docker-compose service entry..."

    cat > "$OUTPUT_DIR/docker-compose-service.yml" <<EOF
  # Service for: $WEBAPP_NAME
  $WEBAPP_NAME:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8080:8080"  # Adjust port mapping as needed
    environment:
      # Environment variables will be loaded from .env file
      - NODE_ENV=development  # Adjust for your runtime
    env_file:
      - .env
    depends_on:
      # Add service dependencies (uncomment and customize)
      # - postgres
      # - redis
      # - sqlserver
    networks:
      - app-network
    volumes:
      # For development, mount source code
      - .:/app
      # Exclude node_modules (for Node.js)
      # - /app/node_modules
    restart: unless-stopped

    # Health check
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 30s
EOF

    log_success "Docker Compose service entry created: $OUTPUT_DIR/docker-compose-service.yml"
    log_info "Add this to your main docker-compose.yml under 'services:'"
}

# Generate build script
generate_build_script() {
    log_info "Generating build and run scripts..."

    # Build script
    cat > "$OUTPUT_DIR/build.sh" <<'EOF'
#!/bin/bash
# Build Docker image

set -e

IMAGE_NAME="${IMAGE_NAME:-myapp}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

echo "Building Docker image: $IMAGE_NAME:$IMAGE_TAG"

docker build -t "$IMAGE_NAME:$IMAGE_TAG" .

echo "Build complete!"
echo "To run: docker run -p 8080:8080 $IMAGE_NAME:$IMAGE_TAG"
EOF
    chmod +x "$OUTPUT_DIR/build.sh"

    # Run script
    cat > "$OUTPUT_DIR/run.sh" <<'EOF'
#!/bin/bash
# Run Docker container locally

set -e

IMAGE_NAME="${IMAGE_NAME:-myapp}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
CONTAINER_NAME="${CONTAINER_NAME:-myapp-dev}"

echo "Running container: $CONTAINER_NAME from $IMAGE_NAME:$IMAGE_TAG"

# Stop existing container if running
docker stop "$CONTAINER_NAME" 2>/dev/null || true
docker rm "$CONTAINER_NAME" 2>/dev/null || true

# Run container
docker run -d \
    --name "$CONTAINER_NAME" \
    -p 8080:8080 \
    --env-file .env \
    "$IMAGE_NAME:$IMAGE_TAG"

echo "Container started!"
echo "View logs: docker logs -f $CONTAINER_NAME"
echo "Stop: docker stop $CONTAINER_NAME"
EOF
    chmod +x "$OUTPUT_DIR/run.sh"

    log_success "Build and run scripts created"
}

# Main execution
main() {
    mkdir -p "$OUTPUT_DIR"

    generate_dockerfile
    generate_compose_entry
    generate_build_script

    echo ""
    log_success "Dockerfile generation complete!"
    echo ""
    echo "Generated files in: $OUTPUT_DIR"
    echo "  - Dockerfile"
    echo "  - .dockerignore"
    echo "  - docker-compose-service.yml"
    echo "  - build.sh"
    echo "  - run.sh"
    echo ""
    echo "Next steps:"
    echo "1. Review and customize Dockerfile"
    echo "2. Copy your application code to $OUTPUT_DIR"
    echo "3. Create .env file with environment variables (see ../.env)"
    echo "4. Build: ./build.sh"
    echo "5. Run: ./run.sh"
    echo "   OR use docker-compose with the generated service entry"
    echo ""
}

main
