---
description: Build Docker images following current best practices and industry standards
---

# Docker Build with Best Practices

## Purpose
Build optimized, secure Docker images following the latest industry standards and best practices for the target platform (Windows, Linux, or macOS).

## Before Building

**CRITICAL: Check latest best practices** before proceeding:
1. Search for latest Docker image best practices (current year)
2. Review official Docker documentation for buildkit features
3. Check for platform-specific considerations

## Build Process

### 1. Analyze Current Dockerfile (if exists)
- Read the existing Dockerfile
- Identify potential security issues
- Note optimization opportunities
- Check for deprecated instructions

### 2. Platform Detection
Determine the target platform and adjust recommendations:
- **Linux**: Standard Docker practices
- **macOS**: Consider M1/M2 ARM architecture vs Intel
- **Windows**: Windows containers vs Linux containers on Windows

### 3. Best Practices Checklist

Apply current industry standards:

**Base Image:**
- Use official images from Docker Hub
- Specify exact version tags (never use `latest`)
- Prefer slim/alpine variants when appropriate
- Use multi-stage builds for smaller images
- Consider distroless images for production

**Security:**
- Run as non-root user
- Scan for vulnerabilities with `docker scout` or `trivy`
- Don't include secrets in image layers
- Use `.dockerignore` to exclude sensitive files
- Minimize attack surface by including only necessary tools

**Optimization:**
- Order layers from least to most frequently changing
- Combine RUN commands to reduce layers
- Use BuildKit features (caching, secrets, SSH)
- Leverage layer caching effectively
- Remove temporary files in the same RUN command

**Labels & Metadata:**
- Add OCI-compliant labels
- Include version, maintainer, description
- Add build date and commit SHA

### 4. Build Command

Use modern Docker build features:

```bash
# Enable BuildKit
export DOCKER_BUILDKIT=1

# Build with best practices
docker build \
  --tag IMAGE_NAME:VERSION \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --label "org.opencontainers.image.created=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
  --label "org.opencontainers.image.version=VERSION" \
  --progress=plain \
  .
```

**For multi-platform builds:**
```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag IMAGE_NAME:VERSION \
  --push \
  .
```

### 5. Post-Build Validation

After building:
1. Check image size: `docker images IMAGE_NAME`
2. Scan for vulnerabilities: `docker scout cves IMAGE_NAME`
3. Inspect layers: `docker history IMAGE_NAME`
4. Test the image: `docker run --rm IMAGE_NAME`
5. Verify non-root user: `docker run --rm IMAGE_NAME whoami`

## Example Optimized Dockerfile

Provide a sample optimized Dockerfile based on the application type:

```dockerfile
# syntax=docker/dockerfile:1

# Multi-stage build example
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:20-alpine AS runtime
# Security: Run as non-root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001
WORKDIR /app
# Copy from builder stage
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --chown=nodejs:nodejs . .
USER nodejs
EXPOSE 3000
CMD ["node", "server.js"]
```

## Common Issues by Platform

### Windows-Specific
- Ensure Docker Desktop is running
- Choose between Windows containers or Linux containers
- Path separators in COPY/ADD commands
- Line ending issues (CRLF vs LF)

### macOS-Specific
- ARM64 vs AMD64 architecture on M1/M2
- File system performance with mounted volumes
- Resource limits in Docker Desktop settings

### Linux-Specific
- SELinux contexts for mounted volumes
- User namespace remapping
- cgroup v2 considerations

## Output

Provide:
1. Optimized Dockerfile (if improvements found)
2. Build command with recommended flags
3. Security scan results summary
4. Image size comparison (before/after if applicable)
5. Platform-specific warnings or recommendations
