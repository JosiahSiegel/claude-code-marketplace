---
name: docker-2025-features
description: Latest Docker 2025 features including AI Assistant, Enhanced Container Isolation, and Moby 25
---

# Docker 2025 Features

This skill covers the latest Docker features introduced in 2025, ensuring you leverage cutting-edge capabilities for security, performance, and developer experience.

## Docker Desktop 4.38+ Features

### 1. Docker AI Assistant (Project Gordon)

**What it is:**
AI-powered assistant integrated into Docker Desktop and CLI for intelligent container development.

**Key capabilities:**
- Natural language command interface
- Context-aware troubleshooting
- Automated Dockerfile optimization
- Real-time best practice recommendations
- Intelligent error diagnosis

**How to use:**
```bash
# Enable in Docker Desktop Settings > Features > Docker AI (Beta)

# Ask questions in natural language
"Optimize my Python Dockerfile"
"Why is my container restarting?"
"Suggest secure nginx configuration"
```

**Local Model Runner:**
- Runs AI models directly on your machine (llama.cpp)
- No cloud API dependencies
- Privacy-preserving (data stays local)
- GPU acceleration for performance
- Works offline

### 2. Enhanced Container Isolation (ECI)

**What it is:**
Additional security layer that restricts Docker socket access and container escape vectors.

**Security benefits:**
- Prevents unauthorized Docker socket access
- Restricts container capabilities by default
- Blocks common escape techniques
- Enforces stricter resource boundaries
- Audits container operations

**How to enable:**
```bash
# Docker Desktop Settings > Security > Enhanced Container Isolation
# Or via CLI:
docker desktop settings set enhancedContainerIsolation=true
```

**Use cases:**
- Multi-tenant environments
- Security-critical applications
- Compliance requirements (PCI-DSS, HIPAA)
- Zero-trust architectures
- Development environments with untrusted code

**Compatibility:**
- May break containers requiring Docker socket access
- Requires Docker Desktop 4.38+
- Supported on Windows (WSL2), macOS, Linux Desktop

### 3. Model Runner

**What it is:**
Built-in AI model execution engine allowing developers to run large language models locally.

**Features:**
- Run AI models without cloud services
- Optimal GPU acceleration
- Privacy-preserving inference
- Multiple model format support
- Integration with Docker AI

**How to use:**
```bash
# Install via Docker Desktop Extensions
# Or use CLI:
docker model run llama2-7b

# View running models:
docker model ls

# Stop model:
docker model stop MODEL_ID
```

**Benefits:**
- No API costs
- Complete data privacy
- Offline availability
- Faster inference (local GPU)
- Integration with development workflow

### 4. Multi-Node Kubernetes Testing

**What it is:**
Test Kubernetes deployments with multi-node clusters directly in Docker Desktop.

**Previously:** Single-node only
**Now:** 2-5 node clusters for realistic testing

**How to enable:**
```bash
# Docker Desktop Settings > Kubernetes > Enable multi-node
# Specify node count (2-5)
```

**Use cases:**
- Test pod scheduling across nodes
- Validate affinity/anti-affinity rules
- Test network policies
- Simulate node failures
- Validate StatefulSets and DaemonSets

### 5. Bake (General Availability)

**What it is:**
High-level build orchestration tool for complex multi-target builds.

**Previously:** Experimental
**Now:** Generally available and production-ready

**Features:**
```hcl
# docker-bake.hcl
target "app" {
  context = "."
  dockerfile = "Dockerfile"
  tags = ["myapp:latest"]
  platforms = ["linux/amd64", "linux/arm64"]
  cache-from = ["type=registry,ref=myapp:cache"]
  cache-to = ["type=registry,ref=myapp:cache,mode=max"]
}

target "test" {
  inherits = ["app"]
  target = "test"
  output = ["type=local,dest=./coverage"]
}
```

```bash
# Build all targets
docker buildx bake

# Build specific target
docker buildx bake test
```

## Moby 25 Engine Updates

### Performance Improvements

**1. Faster Container Startup:**
- 20-30% faster cold starts
- Improved layer extraction
- Optimized network initialization

**2. Better Resource Management:**
- More accurate memory accounting
- Improved CPU throttling
- Better cgroup v2 support

**3. Storage Driver Enhancements:**
- overlay2 performance improvements
- Better disk space management
- Faster image pulls

### Security Updates

**1. Enhanced Seccomp Profiles:**
```json
{
  "defaultAction": "SCMP_ACT_ERRNO",
  "architectures": ["SCMP_ARCH_X86_64", "SCMP_ARCH_AARCH64"],
  "syscalls": [
    {
      "names": ["read", "write", "exit"],
      "action": "SCMP_ACT_ALLOW"
    }
  ]
}
```

**2. Improved AppArmor Integration:**
- Better Docker profile generation
- Reduced false positives
- Enhanced logging

**3. User Namespace Improvements:**
- Easier configuration
- Better compatibility
- Performance optimizations

## Docker Compose v2.40+ Features

### Breaking Changes

**1. Version Field Obsolete:**
```yaml
# OLD (deprecated):
version: '3.8'
services:
  app:
    image: nginx

# NEW (2025):
services:
  app:
    image: nginx
```

The `version` field is now ignored and can be omitted.

### New Features

**1. Develop Watch with initial_sync:**
```yaml
services:
  app:
    build: .
    develop:
      watch:
        - action: sync
          path: ./src
          target: /app/src
          initial_sync: full  # NEW: Sync all files on start
```

**2. Volume Type: Image:**
```yaml
services:
  app:
    volumes:
      - type: image
        source: mydata:latest
        target: /data
        read_only: true
```

**3. Build Print:**
```bash
# Debug complex build configurations
docker compose build --print > build-config.json
```

**4. Config No-Env-Resolution:**
```bash
# View raw config without environment variable substitution
docker compose config --no-env-resolution
```

**5. Watch with Prune:**
```bash
# Automatically prune unused resources during watch
docker compose watch --prune
```

**6. Run with Quiet:**
```bash
# Reduce output noise
docker compose run --quiet app npm test
```

## BuildKit Updates (2025)

### New Features

**1. Git SHA-256 Support:**
```dockerfile
# Use SHA-256 based repositories
ADD https://github.com/user/repo#sha256:abc123... /src
```

**2. Enhanced COPY/ADD --exclude:**
```dockerfile
# Now generally available (was labs-only)
COPY --exclude=*.test.js --exclude=*.md . /app
```

**3. ADD --unpack with --chown:**
```dockerfile
# Extract and set ownership in one step
ADD --unpack=true --chown=appuser:appgroup archive.tar.gz /app
```

**4. Git Query Parameters:**
```dockerfile
# Fine-grained Git clone control
ADD https://github.com/user/repo.git?depth=1&branch=main /src
```

**5. Image Checksum Verification:**
```dockerfile
# Verify image integrity
FROM alpine:3.19@sha256:abc123...
# BuildKit verifies checksum automatically
```

### Security Enhancements

**1. Improved Frontend Verification:**
```dockerfile
# Always use official Docker frontends
# syntax=docker/dockerfile:1

# Pin with digest for maximum security
# syntax=docker/dockerfile:1@sha256:ac85f380a63b13dfcefa89046420e1781752bab202122f8f50032edf31be0021
```

**2. Remote Cache Improvements:**
- Fixed concurrency issues
- Better loop handling
- Enhanced security

## Best Practices for 2025 Features

### Using Docker AI Effectively

**DO:**
- Provide specific context in queries
- Verify AI-generated configurations
- Combine with traditional security tools
- Use for learning and exploration

**DON'T:**
- Trust AI blindly for security-critical apps
- Skip manual code review
- Ignore security scan results
- Use in air-gapped environments without Model Runner

### Enhanced Container Isolation

**DO:**
- Enable for security-sensitive workloads
- Test containers for compatibility first
- Document socket access requirements
- Use with least privilege principles

**DON'T:**
- Enable without testing existing containers
- Disable without understanding risks
- Grant socket access unnecessarily
- Ignore audit logs

### Modern Compose Files

**DO:**
- Remove version field from new compose files
- Use new features (volume type: image, watch improvements)
- Leverage --print for debugging
- Adopt --quiet for cleaner CI/CD output

**DON'T:**
- Keep version field (it's ignored anyway)
- Rely on deprecated syntax
- Skip testing with Compose v2.40+
- Use outdated documentation

## Migration Guide

### Updating to Docker Desktop 4.38+

**1. Backup existing configurations:**
```bash
# Export current settings
docker context export desktop-linux > backup.tar
```

**2. Update Docker Desktop:**
- Download latest from docker.com
- Run installer
- Restart machine if required

**3. Enable new features:**
```bash
# Enable AI Assistant (beta)
docker desktop settings set enableAI=true

# Enable Enhanced Container Isolation
docker desktop settings set enhancedContainerIsolation=true
```

**4. Test existing containers:**
```bash
# Verify containers work with ECI
docker compose up -d
docker compose ps
docker compose logs
```

### Updating Compose Files

**Before:**
```yaml
version: '3.8'

services:
  app:
    image: nginx:latest
    volumes:
      - data:/data

volumes:
  data:
```

**After:**
```yaml
services:
  app:
    image: nginx:1.26.0  # Specific version
    volumes:
      - data:/data
    develop:
      watch:
        - action: sync
          path: ./config
          target: /etc/nginx/conf.d
          initial_sync: full

volumes:
  data:
    driver: local
```

## Troubleshooting 2025 Features

### Docker AI Issues

**Problem:** AI Assistant not responding
**Solution:**
```bash
# Check Docker Desktop version
docker version

# Ensure beta features enabled
docker desktop settings get enableAI

# Restart Docker Desktop
```

**Problem:** Model Runner slow
**Solution:**
- Update GPU drivers
- Increase Docker Desktop memory (Settings > Resources)
- Close other GPU-intensive applications
- Use smaller models for faster inference

### Enhanced Container Isolation Issues

**Problem:** Container fails with socket permission error
**Solution:**
```bash
# Identify socket dependencies
docker inspect CONTAINER | grep -i socket

# If truly needed, add socket access explicitly
# (Document why in docker-compose.yml comments)
docker run -v /var/run/docker.sock:/var/run/docker.sock ...
```

**Problem:** ECI breaks CI/CD pipeline
**Solution:**
- Disable ECI temporarily: `docker desktop settings set enhancedContainerIsolation=false`
- Review which containers need socket access
- Refactor to eliminate socket dependencies
- Re-enable ECI with exceptions documented

### Compose v2.40 Issues

**Problem:** "version field is obsolete" warning
**Solution:**
```yaml
# Simply remove the version field
# OLD:
version: '3.8'
services: ...

# NEW:
services: ...
```

**Problem:** watch with initial_sync fails
**Solution:**
```bash
# Check file permissions
ls -la ./src

# Ensure paths are correct
docker compose config | grep -A 5 watch

# Verify sync target exists in container
docker compose exec app ls -la /app/src
```

## Recommended Feature Adoption Timeline

**Immediate (Production-Ready):**
- Bake for complex builds
- Compose v2.40 features (remove version field)
- Moby 25 engine (via regular Docker updates)
- BuildKit improvements (automatic)

**Testing (Beta but Stable):**
- Docker AI for development workflows
- Model Runner for local AI testing
- Multi-node Kubernetes for pre-production

**Evaluation (Security-Critical):**
- Enhanced Container Isolation (test thoroughly)
- ECI with existing production containers
- Socket access elimination strategies

This skill ensures you stay current with Docker's 2025 evolution while maintaining stability, security, and production-readiness.
