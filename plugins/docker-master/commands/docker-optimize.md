---
description: Optimize Docker images for size, build time, and runtime performance
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

# Docker Image Optimization

## Purpose
Analyze and optimize Docker images following current best practices to reduce size, improve build times, and enhance runtime performance across all platforms.

## Optimization Analysis

### 1. Current State Assessment

**Analyze existing image:**
```bash
# Check image size
docker images IMAGE_NAME

# Inspect layers and their sizes
docker history IMAGE_NAME --human --format "table {{.CreatedBy}}\t{{.Size}}"

# Detailed layer information
docker image inspect IMAGE_NAME
```

**Identify optimization opportunities:**
- Large base images
- Unnecessary dependencies
- Inefficient layer caching
- Redundant files
- Missing multi-stage builds
- Suboptimal COPY/ADD usage

### 2. Size Optimization Strategies

#### Strategy 1: Choose Minimal Base Images

**Image size comparison:**
```
ubuntu:22.04         → ~77MB
debian:12-slim       → ~74MB
alpine:3.19          → ~7MB
distroless/static    → ~2MB (for static binaries)
scratch              → 0MB (for standalone binaries)
```

**Recommendations by use case:**
- **Python apps:** `python:3.12-slim` or `python:3.12-alpine`
- **Node.js apps:** `node:20-alpine`
- **Go apps:** `alpine` or `distroless/static` or `scratch`
- **Java apps:** `eclipse-temurin:21-jre-alpine`
- **Static sites:** `nginx:alpine`

#### Strategy 2: Multi-Stage Builds

**Before (single-stage):**
```dockerfile
FROM node:20
WORKDIR /app
COPY package*.json ./
RUN npm install  # Includes devDependencies
COPY . .
RUN npm run build
CMD ["npm", "start"]
# Result: Large image with build tools
```

**After (multi-stage):**
```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine AS runtime
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./
USER node
CMD ["node", "dist/server.js"]
# Result: Much smaller, only runtime dependencies
```

#### Strategy 3: Layer Optimization

**Bad - Creates multiple layers:**
```dockerfile
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN rm -rf /var/lib/apt/lists/*  # This doesn't reduce size!
```

**Good - Single layer, cleanup in same RUN:**
```dockerfile
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        wget && \
    rm -rf /var/lib/apt/lists/*
```

#### Strategy 4: .dockerignore

**Create comprehensive .dockerignore:**
```
# Version control
.git
.gitignore
.gitattributes

# CI/CD
.github
.gitlab-ci.yml
Jenkinsfile

# Development
node_modules
npm-debug.log
.env
.env.local
*.local

# Testing
coverage
.nyc_output
**/*.test.js
**/*.spec.js

# Documentation
README.md
docs/
*.md

# IDE
.vscode
.idea
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Build artifacts
dist
build
target
*.log
```

#### Strategy 5: Dependency Management

**For Node.js:**
```dockerfile
# Use npm ci instead of npm install
RUN npm ci --only=production

# Or clean cache
RUN npm install --production && npm cache clean --force
```

**For Python:**
```dockerfile
# Install only what's needed
RUN pip install --no-cache-dir -r requirements.txt

# Use wheels for faster installs
RUN pip install --no-cache-dir --find-links=/wheelhouse -r requirements.txt
```

**For Go:**
```dockerfile
# Leverage Go modules caching
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o app
```

### 3. Build Performance Optimization

#### BuildKit Features

Enable BuildKit for faster builds:
```bash
# Set environment variable
export DOCKER_BUILDKIT=1

# Or in docker-compose.yml
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1
```

**BuildKit advantages:**
- Parallel builds
- Better caching
- Secrets handling
- SSH forwarding

#### Layer Caching Strategy

Order Dockerfile from least to most frequently changing:

```dockerfile
# 1. System dependencies (rarely change)
FROM node:20-alpine
RUN apk add --no-cache python3 make g++

# 2. Application dependencies (change occasionally)
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# 3. Application code (changes frequently)
COPY . .

# 4. Build step
RUN npm run build

CMD ["node", "server.js"]
```

#### Cache Mounts

Use BuildKit cache mounts for package managers:

```dockerfile
# syntax=docker/dockerfile:1

FROM node:20-alpine
WORKDIR /app

# Cache npm packages
RUN --mount=type=cache,target=/root/.npm \
    npm ci --only=production

# Cache pip packages
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt

# Cache Go modules
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download
```

### 4. Runtime Performance Optimization

#### Resource Efficiency

```dockerfile
# Use ENTRYPOINT for executables
ENTRYPOINT ["node"]
CMD ["server.js"]

# Set proper signals handling
STOPSIGNAL SIGTERM

# Optimize for fewer processes
# Use exec form to avoid shell wrapper
CMD ["node", "server.js"]  # Good
# CMD node server.js       # Bad - creates shell process
```

#### Security Hardening

```dockerfile
# Run as non-root user
RUN addgroup -g 1001 -S appuser && \
    adduser -S appuser -u 1001
USER appuser

# Read-only filesystem
# (Configure tmpfs volumes at runtime)
# Set no-new-privileges
# (Configure via docker run --security-opt)
```

### 5. Advanced Optimization Techniques

#### Squash Layers (Post-Build)

```bash
# Experimental feature
docker build --squash -t IMAGE_NAME .
```

**Note:** This removes build history and may affect caching.

#### Static Binary in Scratch

For Go applications:
```dockerfile
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags="-s -w" -o main .

FROM scratch
COPY --from=builder /app/main /main
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["/main"]
# Result: ~10MB image
```

#### UPX Compression

Compress binaries (use cautiously):
```dockerfile
FROM golang:1.21-alpine AS builder
RUN apk add --no-cache upx
WORKDIR /app
COPY . .
RUN go build -o app && upx --best --lzma app

FROM alpine
COPY --from=builder /app/app /app
ENTRYPOINT ["/app"]
```

### 6. Verification & Comparison

#### Image Size Analysis

```bash
# Before optimization
docker images IMAGE_NAME:before

# After optimization
docker images IMAGE_NAME:after

# Detailed layer comparison
dive IMAGE_NAME:after
# Install dive: https://github.com/wagoodman/dive
```

#### Performance Testing

```bash
# Build time comparison
time docker build -t test:before -f Dockerfile.before .
time docker build -t test:after -f Dockerfile.after .

# Startup time
time docker run --rm test:before /bin/true
time docker run --rm test:after /bin/true

# Runtime performance
docker stats $(docker run -d test:after)
```

### 7. Platform-Specific Optimizations

#### Windows Containers
- Use Windows Server Core only if needed
- Prefer Nano Server for smaller size
- Clean up Windows Update cache
- Remove unnecessary Windows features

#### macOS (Docker Desktop)
- Consider ARM64 builds for M1/M2 Macs
- Use multi-platform builds for compatibility
- Optimize file sharing for bind mounts

#### Linux
- Leverage native performance
- Use Alpine for smallest images
- Consider distroless for security

## Optimization Checklist

**Size Reduction:**
- [ ] Using minimal base image (alpine/slim/distroless)
- [ ] Multi-stage build implemented
- [ ] .dockerignore configured
- [ ] Dependencies cleaned up in same layer
- [ ] Development tools excluded from final image
- [ ] Unnecessary files removed

**Build Performance:**
- [ ] BuildKit enabled
- [ ] Layers ordered by change frequency
- [ ] Cache mounts used for package managers
- [ ] Dependency layer cached separately
- [ ] Parallel builds utilized

**Runtime Performance:**
- [ ] Exec form CMD/ENTRYPOINT used
- [ ] Running as non-root user
- [ ] Proper signal handling
- [ ] Health checks configured
- [ ] Resource limits set

**Security:**
- [ ] No secrets in layers
- [ ] Minimal attack surface
- [ ] Security scanning passed
- [ ] Non-root user
- [ ] Read-only filesystem where possible

## Output

Provide:
1. Optimized Dockerfile with comments explaining changes
2. Before/after size comparison
3. Build time improvements
4. Layer analysis with recommendations
5. Platform-specific optimizations applied
6. .dockerignore file
7. Build commands with BuildKit features
8. Verification commands to test optimizations
9. Estimated improvements (size, build time, security)
