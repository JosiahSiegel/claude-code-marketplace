---
description: Run Docker containers with proper configuration and best practices
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

# Docker Run with Best Practices

## Purpose
Run Docker containers following security best practices, resource management, and platform-specific optimizations.

## Pre-Run Checklist

**Research latest recommendations:**
1. Check Docker documentation for latest flags and features
2. Review security best practices for container runtime
3. Understand platform-specific considerations

## Run Configuration

### 1. Analyze Requirements
Determine what the container needs:
- Network access? (which ports, which network)
- Volume mounts? (data persistence, configs)
- Environment variables? (check for secrets)
- Resource limits? (CPU, memory)
- Security constraints? (capabilities, AppArmor, SELinux)

### 2. Security Best Practices

**NEVER:**
- Run with `--privileged` unless absolutely necessary
- Use `--cap-add=ALL`
- Mount Docker socket (`/var/run/docker.sock`) without understanding risks
- Run as root when avoidable
- Expose unnecessary ports

**ALWAYS:**
- Use `--read-only` filesystem when possible
- Drop capabilities with `--cap-drop`
- Use `--security-opt` for additional hardening
- Limit resources with `--memory` and `--cpus`
- Use secrets management for sensitive data

### 3. Resource Management

Set appropriate limits:
```bash
docker run \
  --memory="512m" \
  --memory-swap="512m" \
  --cpus="1.0" \
  --pids-limit=100 \
  IMAGE_NAME
```

### 4. Network Configuration

**Best practices:**
- Create custom networks instead of using default bridge
- Use `--network` to specify network
- Expose only necessary ports
- Use `--publish` carefully (prefer 127.0.0.1:PORT for local-only)

```bash
# Create custom network
docker network create my-app-network

# Run with custom network
docker run --network my-app-network IMAGE_NAME
```

### 5. Volume Management

**Bind mounts vs named volumes:**
- Named volumes: Better for production, managed by Docker
- Bind mounts: Good for development, direct host access

```bash
# Named volume (preferred)
docker run -v my-data-volume:/data IMAGE_NAME

# Bind mount with read-only where appropriate
docker run -v /host/path:/container/path:ro IMAGE_NAME
```

**CRITICAL: Git Bash/MINGW on Windows Path Conversion:**

When using bind mounts in Git Bash on Windows, paths are automatically converted incorrectly. **Always use MSYS_NO_PATHCONV:**

```bash
# CORRECT: With MSYS_NO_PATHCONV
MSYS_NO_PATHCONV=1 docker run -v $(pwd):/app IMAGE_NAME

# CORRECT: With double slash workaround
docker run -v //c/Users/project:/app IMAGE_NAME

# WRONG: Without fix (path gets mangled)
docker run -v $(pwd):/app IMAGE_NAME  # FAILS in Git Bash

# Best practice: Add to ~/.bashrc
export MSYS_NO_PATHCONV=1
```

**Why this matters:** Git Bash converts `/c/Users/project` to `C:\Program Files\Git\c\Users\project`, breaking volume mounts.

See the `docker-git-bash-guide` skill for comprehensive path conversion guidance.

### 6. Environment & Secrets

**NEVER put secrets in environment variables visible in `docker inspect`**

Use Docker secrets or config files:
```bash
# For development (use proper secrets management in production)
docker run --env-file .env IMAGE_NAME

# Better: Use Docker secrets (Swarm) or mounted config files
docker run -v /secure/path/config:/etc/config:ro IMAGE_NAME
```

## Complete Run Example

```bash
docker run \
  --name my-container \
  --detach \
  --restart unless-stopped \
  --network my-app-network \
  --memory="512m" \
  --cpus="1.0" \
  --read-only \
  --tmpfs /tmp \
  --cap-drop=ALL \
  --cap-add=NET_BIND_SERVICE \
  --security-opt="no-new-privileges:true" \
  --publish 127.0.0.1:8080:8080 \
  --volume my-data:/data \
  --env-file .env \
  --health-cmd="curl -f http://localhost:8080/health || exit 1" \
  --health-interval=30s \
  --health-timeout=3s \
  --health-retries=3 \
  --label "com.example.version=1.0.0" \
  IMAGE_NAME:TAG
```

## Platform-Specific Considerations

### Windows
- Choose container type: `--isolation=process` or `--isolation=hyperv`
- Path format: Use forward slashes or escape backslashes
- Volume mounting: Use absolute Windows paths
- Port binding: May need to configure Windows Firewall

### macOS
- File sharing: Ensure paths are in Docker Desktop allowed directories
- Performance: Consider delegated/cached volume options for better I/O
- Resource limits: Check Docker Desktop resource allocation
- Networking: Use host.docker.internal for host access

### Linux
- SELinux: May need `:z` or `:Z` volume flags
- AppArmor: Check profile compatibility
- User namespaces: Consider `--userns-remap`
- cgroup version: Ensure compatibility with v1 vs v2

## Health Checks

Always include health checks for production:
```bash
--health-cmd="command to check health" \
--health-interval=30s \
--health-timeout=3s \
--health-retries=3 \
--health-start-period=40s
```

## Logging Configuration

Configure appropriate logging:
```bash
docker run \
  --log-driver=json-file \
  --log-opt max-size=10m \
  --log-opt max-file=3 \
  IMAGE_NAME
```

## Interactive vs Detached

**For development/debugging:**
```bash
docker run -it --rm IMAGE_NAME /bin/sh
```

**For production:**
```bash
docker run -d --restart unless-stopped IMAGE_NAME
```

## Cleanup

Include cleanup strategy:
- Use `--rm` for temporary containers
- Set `--restart` policy appropriately
- Implement log rotation
- Plan for volume cleanup

## Validation Steps

After running:
1. Check container status: `docker ps`
2. View logs: `docker logs CONTAINER_NAME`
3. Verify health: `docker inspect --format='{{.State.Health.Status}}' CONTAINER_NAME`
4. Check resource usage: `docker stats CONTAINER_NAME`
5. Test connectivity and functionality

## Output

Provide:
1. Complete `docker run` command with all recommended flags
2. Platform-specific warnings or adjustments
3. Security recommendations applied
4. Resource limits explanation
5. Health check configuration
6. Expected post-run validation commands
