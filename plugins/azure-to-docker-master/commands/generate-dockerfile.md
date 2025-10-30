---
description: Generate production-ready Dockerfiles from Azure App Service configurations
---

## 🚨 CRITICAL GUIDELINES

### Windows File Path Requirements

**MANDATORY: Always Use Backslashes on Windows for File Paths**

When using Edit or Write tools on Windows, you MUST use backslashes (`\`) in file paths, NOT forward slashes (`/`).

**Examples:**
- ❌ WRONG: `D:/repos/project/file.tsx`
- ✅ CORRECT: `D:\repos\project\file.tsx`

This applies to:
- Edit tool file_path parameter
- Write tool file_path parameter
- All file operations on Windows systems


### Documentation Guidelines

**NEVER create new documentation files unless explicitly requested by the user.**

- **Priority**: Update existing README.md files rather than creating new documentation
- **Repository cleanliness**: Keep repository root clean - only README.md unless user requests otherwise
- **Style**: Documentation should be concise, direct, and professional - avoid AI-generated tone
- **User preference**: Only create additional .md files when user specifically asks for documentation


---

# Generate Dockerfile from Azure App Service

## Purpose
Create optimized, production-ready Dockerfiles based on Azure App Service runtime configurations, following 2025 best practices.

## Prerequisites

- Azure App Service configuration JSON (from `extract-infrastructure`)
- Application source code
- Docker Desktop 4.40+ installed
- Understanding of application runtime requirements

## Step 1: Analyze App Service Configuration

Read the App Service configuration JSON to identify:

1. **Runtime Stack:**
   - .NET (Core/Framework version)
   - Node.js version
   - Python version
   - Java version
   - PHP version
   - Custom container image

2. **Operating System:**
   - Linux (preferred for containers)
   - Windows (needs Windows containers)

3. **Build Configuration:**
   - Build commands
   - Startup commands
   - Environment variables

4. **Dependencies:**
   - Package managers (npm, pip, maven, nuget)
   - System dependencies
   - Native libraries

Example from `az webapp show` output:
```json
{
  "siteConfig": {
    "linuxFxVersion": "NODE|20-lts",
    "appCommandLine": "npm start",
    "alwaysOn": true
  }
}
```

## Step 2: Choose Base Image Strategy

Use official images from Microsoft Container Registry or Docker Hub:

### .NET Applications

**ASP.NET Core (2025 recommended):**
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS base
FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS build
```

**Legacy .NET Framework (Windows containers):**
```dockerfile
FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8
```

### Node.js Applications

**Node 20 LTS (2025):**
```dockerfile
FROM node:20-alpine AS base
```

**Node 22 (Latest):**
```dockerfile
FROM node:22-alpine AS base
```

### Python Applications

**Python 3.12 (2025):**
```dockerfile
FROM python:3.12-slim AS base
```

### Java Applications

**Java 21 LTS:**
```dockerfile
FROM eclipse-temurin:21-jre-alpine AS base
```

### PHP Applications

**PHP 8.3 (2025):**
```dockerfile
FROM php:8.3-fpm-alpine AS base
```

## Step 3: Apply 2025 Best Practices

### Multi-Stage Builds

Always use multi-stage builds to minimize final image size:

```dockerfile
# Stage 1: Build
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Stage 2: Production
FROM node:20-alpine AS production
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY package.json ./
USER node
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

### Security Hardening

1. **Run as non-root user**
2. **Use minimal base images (alpine, distroless)**
3. **Don't install unnecessary packages**
4. **Use specific version tags**
5. **Scan for vulnerabilities**

### Layer Optimization

Order layers from least to most frequently changing:

```dockerfile
# 1. System dependencies (rarely change)
RUN apk add --no-cache ...

# 2. Application dependencies (change occasionally)
COPY package*.json ./
RUN npm ci

# 3. Application code (changes frequently)
COPY . .
```

## Step 4: Generate Runtime-Specific Dockerfiles

### Node.js Application (Express/Nest/Next.js)

```dockerfile
# Build stage
FROM node:20-alpine AS build

# Install build dependencies
RUN apk add --no-cache \
    python3 \
    make \
    g++

WORKDIR /app

# Copy dependency manifests
COPY package*.json ./

# Install dependencies (including devDependencies for build)
RUN npm ci

# Copy source code
COPY . .

# Build application
RUN npm run build

# Prune dev dependencies
RUN npm prune --production

# Production stage
FROM node:20-alpine AS production

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create app user
RUN addgroup -g 1000 node && \
    adduser -D -u 1000 -G node node

WORKDIR /app

# Copy built application and production dependencies
COPY --from=build --chown=node:node /app/dist ./dist
COPY --from=build --chown=node:node /app/node_modules ./node_modules
COPY --from=build --chown=node:node /app/package.json ./

# Switch to non-root user
USER node

# Expose port (from Azure config)
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start application
CMD ["node", "dist/index.js"]
```

### ASP.NET Core Application

```dockerfile
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS build

WORKDIR /src

# Copy solution and project files
COPY *.sln ./
COPY **/*.csproj ./
RUN for file in $(ls *.csproj); do mkdir -p ${file%.*}/ && mv $file ${file%.*}/; done

# Restore dependencies
RUN dotnet restore

# Copy source code
COPY . .

# Build application
WORKDIR /src/MyApp
RUN dotnet build -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS production

# Install required packages
RUN apk add --no-cache \
    icu-libs \
    tzdata

# Create app user
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

WORKDIR /app

# Copy published application
COPY --from=publish --chown=appuser:appuser /app/publish .

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Environment variables
ENV ASPNETCORE_URLS=http://+:8080 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_EnableDiagnostics=0

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Start application
ENTRYPOINT ["dotnet", "MyApp.dll"]
```

### Python Application (Flask/FastAPI/Django)

```dockerfile
# Build stage
FROM python:3.12-slim AS build

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements
COPY requirements.txt ./

# Create virtual environment and install dependencies
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir -r requirements.txt

# Production stage
FROM python:3.12-slim AS production

# Install runtime dependencies only
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Create app user
RUN useradd -m -u 1000 appuser

WORKDIR /app

# Copy virtual environment from build stage
COPY --from=build /opt/venv /opt/venv

# Copy application code
COPY --chown=appuser:appuser . .

# Switch to non-root user
USER appuser

# Set environment variables
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"

# Start application (adjust based on framework)
# FastAPI with uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

# Or Flask with gunicorn
# CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "app:app"]

# Or Django with gunicorn
# CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "myproject.wsgi:application"]
```

### Java Spring Boot Application

```dockerfile
# Build stage
FROM eclipse-temurin:21-jdk-alpine AS build

WORKDIR /app

# Copy Maven/Gradle wrapper and dependencies
COPY mvnw* pom.xml ./
COPY .mvn .mvn
RUN ./mvnw dependency:go-offline

# Copy source code
COPY src ./src

# Build application
RUN ./mvnw package -DskipTests

# Production stage
FROM eclipse-temurin:21-jre-alpine AS production

# Install dumb-init
RUN apk add --no-cache dumb-init

# Create app user
RUN addgroup -g 1000 spring && \
    adduser -D -u 1000 -G spring spring

WORKDIR /app

# Copy JAR from build stage
COPY --from=build --chown=spring:spring /app/target/*.jar app.jar

# Switch to non-root user
USER spring

# Expose port
EXPOSE 8080

# JVM tuning for containers
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:InitialRAMPercentage=50.0"

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Use dumb-init for signal handling
ENTRYPOINT ["dumb-init", "--"]

# Start application
CMD ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

## Step 5: Add .dockerignore

Create `.dockerignore` to exclude unnecessary files:

```dockerignore
# Version control
.git
.gitignore
.gitattributes

# Dependencies (will be installed during build)
node_modules
vendor
venv
__pycache__
*.pyc

# IDE files
.vscode
.idea
*.swp
*.swo

# Build artifacts
dist
build
target
out
*.log

# Environment files
.env
.env.local
*.local

# OS files
.DS_Store
Thumbs.db

# Documentation
README.md
docs/
*.md

# CI/CD
.github
.gitlab-ci.yml
azure-pipelines.yml

# Docker
Dockerfile*
docker-compose*
.dockerignore
```

## Step 6: Environment Variable Mapping

Map Azure App Settings to Docker environment variables:

**Azure App Settings → Dockerfile ENV:**

```dockerfile
# From Azure: WEBSITE_NODE_DEFAULT_VERSION
ENV NODE_VERSION=20

# From Azure: DATABASE_CONNECTION_STRING
# Don't hardcode - use docker-compose environment

# From Azure: APPINSIGHTS_INSTRUMENTATIONKEY
ENV APPINSIGHTS_ENABLED=false

# Azure-specific variables to remove/replace
# - WEBSITE_* (Azure internal)
# - APPSETTING_* (Azure prefix)
```

**In docker-compose.yml instead:**
```yaml
services:
  app:
    environment:
      - DATABASE_URL=Server=sqlserver;Database=myapp;...
      - REDIS_URL=redis://redis:6379
```

## Step 7: Platform-Specific Adjustments

### Windows Containers

If Azure App Service uses Windows:

```dockerfile
FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8

WORKDIR /inetpub/wwwroot

COPY . .

EXPOSE 80
```

### Linux Containers

Preferred for better portability and smaller images.

## Step 8: Build and Test

**Build image:**
```bash
docker build -t myapp:local .
```

**Test locally:**
```bash
docker run -p 8080:8080 myapp:local
```

**Scan for vulnerabilities:**
```bash
docker scout cves myapp:local
# Or
trivy image myapp:local
```

**Check image size:**
```bash
docker images myapp:local
```

**Inspect layers:**
```bash
docker history myapp:local
```

## Step 9: Optimization Checklist

- [ ] Multi-stage build reduces final image size
- [ ] Alpine or slim base images used where possible
- [ ] Non-root user configured
- [ ] Specific version tags (not `latest`)
- [ ] `.dockerignore` excludes unnecessary files
- [ ] Dependencies cached in separate layer
- [ ] Health check configured
- [ ] Proper signal handling (dumb-init/tini)
- [ ] Build-time secrets not leaked
- [ ] Vulnerability scan passes
- [ ] Image size < 500MB (target < 200MB)

## Step 10: Integration with docker-compose.yml

Update compose file to use generated Dockerfile:

```yaml
services:
  app:
    build:
      context: ./app
      dockerfile: Dockerfile
      target: production
      args:
        - BUILD_DATE=${BUILD_DATE}
        - VERSION=${VERSION}
      cache_from:
        - myapp:latest
    image: myapp:local
    # ... rest of configuration
```

## Common Patterns by Framework

### Next.js (React)

```dockerfile
FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package*.json ./
RUN npm ci

FROM node:20-alpine AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM node:20-alpine AS production
WORKDIR /app
RUN addgroup -g 1000 nodejs && adduser -D -u 1000 -G nodejs nextjs
COPY --from=build --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=build --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=build --chown=nextjs:nodejs /app/public ./public
USER nextjs
EXPOSE 3000
ENV PORT=3000 NODE_ENV=production
CMD ["node", "server.js"]
```

### Django

```dockerfile
FROM python:3.12-slim AS build
WORKDIR /app
COPY requirements.txt ./
RUN pip install --user --no-cache-dir -r requirements.txt

FROM python:3.12-slim AS production
WORKDIR /app
COPY --from=build /root/.local /root/.local
COPY . .
RUN useradd -m django && chown -R django:django /app
USER django
ENV PATH=/root/.local/bin:$PATH \
    PYTHONUNBUFFERED=1
EXPOSE 8000
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "project.wsgi"]
```

### Angular (Frontend)

```dockerfile
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build -- --configuration production

FROM nginx:alpine AS production
COPY --from=build /app/dist/my-app /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## Troubleshooting

**Build fails during dependency installation:**
- Check network connectivity
- Verify package manager cache
- Add build dependencies to build stage

**Image size too large:**
- Use alpine base images
- Multi-stage builds
- Remove unnecessary files
- Combine RUN commands

**Permission denied errors:**
- Ensure correct user ownership
- Check file permissions in COPY commands
- Verify USER directive placement

**Health check fails:**
- Test health endpoint locally
- Adjust timeout and interval
- Check port binding

**Signal handling issues:**
- Use dumb-init or tini
- Proper ENTRYPOINT configuration
- Handle SIGTERM gracefully in application

## Output Deliverables

For each App Service, provide:

1. `Dockerfile` - Production-ready multi-stage Dockerfile
2. `.dockerignore` - Files to exclude from build
3. `README.md` - Build and run instructions
4. Optimization report - Image size, layers, security scan results
5. docker-compose integration snippet

## Best Practices Summary

1. **Always use multi-stage builds**
2. **Run as non-root user**
3. **Use specific version tags**
4. **Implement health checks**
5. **Optimize layer caching**
6. **Exclude files with .dockerignore**
7. **Scan for vulnerabilities**
8. **Test locally before deployment**
9. **Document build process**
10. **Keep images minimal (<200MB target)**
