---
description: Debug Docker containers and troubleshoot common issues across all platforms
---

# Docker Debugging & Troubleshooting

## Purpose
Diagnose and resolve Docker container issues efficiently using systematic debugging approaches for Windows, Linux, and macOS.

## Debugging Workflow

### 1. Identify the Problem

**Gather basic information:**
```bash
# Container status
docker ps -a

# Recent logs
docker logs CONTAINER_NAME --tail 100

# Container details
docker inspect CONTAINER_NAME

# Resource usage
docker stats CONTAINER_NAME --no-stream

# Events
docker events --since '10m' --filter 'container=CONTAINER_NAME'
```

### 2. Common Issues & Solutions

#### Issue: Container Won't Start

**Symptoms:** Container exits immediately after starting.

**Debug steps:**
```bash
# Check exit code
docker ps -a --filter "name=CONTAINER_NAME" --format "{{.Status}}"

# View full logs
docker logs CONTAINER_NAME

# Try running interactively
docker run -it --rm IMAGE_NAME /bin/sh

# Check for port conflicts
docker port CONTAINER_NAME
netstat -tulpn | grep PORT  # Linux
lsof -i :PORT               # macOS
netstat -ano | findstr PORT # Windows

# Inspect configuration
docker inspect CONTAINER_NAME | grep -A 10 "Config"
```

**Common causes:**
- Application crash on startup
- Missing dependencies
- Port already in use
- Invalid command or entrypoint
- Permission issues
- Missing environment variables

**Solutions:**
```bash
# Override entrypoint to debug
docker run -it --entrypoint /bin/sh IMAGE_NAME

# Check application logs inside container
docker run -it IMAGE_NAME cat /app/logs/error.log

# Verify environment variables
docker run --rm IMAGE_NAME env
```

#### Issue: Container Runs But Application Doesn't Work

**Debug steps:**
```bash
# Execute shell in running container
docker exec -it CONTAINER_NAME /bin/sh
# or
docker exec -it CONTAINER_NAME /bin/bash

# Check processes
docker exec CONTAINER_NAME ps aux

# Check listening ports
docker exec CONTAINER_NAME netstat -tulpn
# If netstat not available:
docker exec CONTAINER_NAME ss -tulpn

# Test connectivity from inside
docker exec CONTAINER_NAME wget -O- http://localhost:PORT
docker exec CONTAINER_NAME curl http://localhost:PORT

# Check file permissions
docker exec CONTAINER_NAME ls -la /app

# View application logs
docker exec CONTAINER_NAME tail -f /var/log/app.log
```

#### Issue: Network Connectivity Problems

**Debug steps:**
```bash
# List networks
docker network ls

# Inspect network
docker network inspect NETWORK_NAME

# Check container network settings
docker inspect CONTAINER_NAME | grep -A 20 "NetworkSettings"

# Test DNS resolution
docker exec CONTAINER_NAME nslookup google.com
docker exec CONTAINER_NAME ping -c 3 google.com

# Test inter-container communication
docker exec CONTAINER_NAME ping -c 3 OTHER_CONTAINER_NAME
docker exec CONTAINER_NAME curl http://OTHER_CONTAINER_NAME:PORT

# Check iptables rules (Linux host)
sudo iptables -L -n -v | grep docker

# Verify port bindings
docker port CONTAINER_NAME
```

**Common network issues:**
- Containers on different networks
- Firewall blocking ports
- DNS not resolving container names
- Port mapping incorrect
- Network driver issues

**Solutions:**
```bash
# Connect container to network
docker network connect NETWORK_NAME CONTAINER_NAME

# Create custom network
docker network create --driver bridge my-network

# Run container with specific network
docker run --network=my-network IMAGE_NAME

# Expose port correctly
docker run -p HOST_PORT:CONTAINER_PORT IMAGE_NAME

# Use host network (debugging only, not for production)
docker run --network=host IMAGE_NAME
```

#### Issue: Volume/Mount Problems

**Debug steps:**
```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect VOLUME_NAME

# Check mounts in container
docker inspect CONTAINER_NAME | grep -A 10 "Mounts"

# Verify files inside container
docker exec CONTAINER_NAME ls -la /mounted/path

# Check permissions
docker exec CONTAINER_NAME stat /mounted/path

# Read file content
docker exec CONTAINER_NAME cat /mounted/path/file.txt
```

**Common volume issues:**
- Permission denied
- Files not syncing (macOS/Windows)
- Volume mounted as empty
- Wrong path
- Read-only when should be writable

**Platform-specific solutions:**

**Linux:**
```bash
# Fix permissions with chown
docker exec CONTAINER_NAME chown -R 1000:1000 /mounted/path

# SELinux labels
docker run -v /host/path:/container/path:z IMAGE_NAME
```

**macOS:**
```bash
# Ensure path is in Docker Desktop file sharing settings
# Preferences -> Resources -> File Sharing

# Use cached/delegated for performance
docker run -v /host/path:/container/path:cached IMAGE_NAME
```

**Windows:**
```powershell
# Ensure drive is shared in Docker Desktop
# Settings -> Resources -> File Sharing

# Use forward slashes or escape backslashes
docker run -v C:/Users/path:/container/path IMAGE_NAME
docker run -v C:\\Users\\path:/container/path IMAGE_NAME
```

#### Issue: Resource Constraints

**Debug steps:**
```bash
# Real-time resource usage
docker stats

# Check configured limits
docker inspect CONTAINER_NAME | grep -A 10 "HostConfig"

# OOM (Out of Memory) events
docker inspect CONTAINER_NAME | grep OOMKilled

# CPU throttling
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

**Solutions:**
```bash
# Increase memory limit
docker run --memory="1g" IMAGE_NAME

# Increase CPU quota
docker run --cpus="2.0" IMAGE_NAME

# Remove limits temporarily for debugging
docker run --memory="0" --cpus="0" IMAGE_NAME

# Check Docker Desktop resources (macOS/Windows)
# Preferences -> Resources -> Advanced
```

#### Issue: Health Check Failing

**Debug steps:**
```bash
# Check health status
docker inspect CONTAINER_NAME | grep -A 10 "Health"

# View health check command
docker inspect CONTAINER_NAME | grep -A 5 "Healthcheck"

# Execute health check manually
docker exec CONTAINER_NAME HEALTH_CHECK_COMMAND

# Monitor health check logs
docker inspect CONTAINER_NAME --format='{{json .State.Health}}' | jq
```

**Solutions:**
```bash
# Adjust health check timings
docker run \
  --health-cmd="curl -f http://localhost/health || exit 1" \
  --health-interval=30s \
  --health-timeout=10s \
  --health-retries=3 \
  --health-start-period=60s \
  IMAGE_NAME

# Temporarily disable health check
docker run --no-healthcheck IMAGE_NAME
```

### 3. Advanced Debugging Techniques

#### Debugging Build Failures

```bash
# Build with verbose output
docker build --progress=plain --no-cache -t IMAGE_NAME .

# Build up to specific stage
docker build --target STAGE_NAME -t debug-image .

# Inspect failed layer
docker run -it $(docker ps -a -q -n 1) /bin/sh

# Use buildkit debugging
docker build --progress=plain --no-cache --target builder -t debug .
docker run -it debug /bin/sh
```

#### Debugging Multi-Container Applications

```bash
# Compose logs for all services
docker compose logs -f

# Logs for specific service
docker compose logs -f SERVICE_NAME

# Check service status
docker compose ps

# View compose configuration
docker compose config

# Restart single service
docker compose restart SERVICE_NAME

# Rebuild and restart
docker compose up -d --build SERVICE_NAME

# Check service dependencies
docker compose config --services
```

#### System-Level Debugging

```bash
# Docker daemon logs (Linux)
sudo journalctl -u docker -f

# Docker Desktop logs (macOS)
# ~/Library/Containers/com.docker.docker/Data/log/

# Docker Desktop logs (Windows)
# %APPDATA%\Docker\log

# Check Docker system info
docker system info

# Disk usage analysis
docker system df -v

# Check for image/container issues
docker system events --since '1h'
```

#### Performance Debugging

```bash
# Detailed container stats
docker stats --all --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

# Process list with resource usage
docker top CONTAINER_NAME aux

# Trace system calls (Linux)
docker run --cap-add SYS_PTRACE --pid=host IMAGE_NAME strace -p PID

# Monitor file access
docker exec CONTAINER_NAME lsof

# Network packet capture
docker run --net=container:CONTAINER_NAME nicolaka/netshoot tcpdump -i eth0
```

### 4. Debugging Tools & Utilities

#### Essential Debugging Image

Use `nicolaka/netshoot` for network debugging:
```bash
# Run alongside your container
docker run -it --net=container:CONTAINER_NAME nicolaka/netshoot

# Available tools: curl, wget, dig, nslookup, netstat, iperf, tcpdump, etc.
```

#### Install debugging tools temporarily

```dockerfile
# Add to Dockerfile for debugging (remove in production)
RUN apk add --no-cache \
    curl \
    wget \
    netcat-openbsd \
    bind-tools \
    strace \
    htop
```

Or install at runtime:
```bash
# Alpine
docker exec CONTAINER_NAME apk add --no-cache curl

# Debian/Ubuntu
docker exec CONTAINER_NAME apt-get update && apt-get install -y curl

# CentOS/RHEL
docker exec CONTAINER_NAME yum install -y curl
```

### 5. Platform-Specific Issues

#### Windows-Specific

```powershell
# Check Hyper-V status
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All

# Restart Docker Desktop
Restart-Service docker

# Check WSL2 integration (if using WSL2 backend)
wsl --list --verbose

# View Docker Desktop diagnostics
# Docker Desktop -> Troubleshoot -> Get Diagnostics
```

#### macOS-Specific

```bash
# Reset Docker Desktop
# Docker Desktop -> Troubleshoot -> Reset to factory defaults

# Check virtualization framework
# Docker Desktop -> Preferences -> General -> "Use the new Virtualization framework"

# File syncing issues with osxfs
# Consider using docker-sync or cached/delegated mounts

# Check for M1/M2 architecture issues
docker inspect IMAGE_NAME | grep Architecture
```

#### Linux-Specific

```bash
# Check Docker service status
sudo systemctl status docker

# Restart Docker daemon
sudo systemctl restart docker

# Check cgroup driver
docker info | grep "Cgroup Driver"

# SELinux issues
sudo setenforce 0  # Temporarily disable (debugging only)
ausearch -m avc -ts recent  # Check for denials

# AppArmor issues
sudo aa-status
sudo aa-complain /etc/apparmor.d/docker
```

### 6. Debugging Checklist

**Container won't start:**
- [ ] Check logs: `docker logs CONTAINER_NAME`
- [ ] Verify image exists: `docker images`
- [ ] Check port conflicts
- [ ] Try interactive mode: `docker run -it`
- [ ] Check entrypoint/command
- [ ] Verify environment variables
- [ ] Check resource availability

**Container runs but app fails:**
- [ ] Execute shell inside: `docker exec -it CONTAINER_NAME /bin/sh`
- [ ] Check processes: `docker exec CONTAINER_NAME ps aux`
- [ ] Test connectivity
- [ ] Check file permissions
- [ ] Verify configuration files
- [ ] Check application logs
- [ ] Test health endpoint

**Network issues:**
- [ ] Inspect network: `docker network inspect`
- [ ] Test DNS resolution
- [ ] Verify port bindings
- [ ] Check firewall rules
- [ ] Test inter-container communication
- [ ] Verify network driver

**Volume issues:**
- [ ] Inspect mounts: `docker inspect | grep Mounts`
- [ ] Check permissions
- [ ] Verify source path exists
- [ ] Test read/write access
- [ ] Check platform-specific settings

## Debugging Commands Quick Reference

```bash
# Inspection
docker ps -a                          # All containers
docker logs CONTAINER --tail 100 -f   # Live logs
docker inspect CONTAINER              # Full details
docker stats CONTAINER                # Resource usage
docker top CONTAINER                  # Processes
docker port CONTAINER                 # Port mappings
docker diff CONTAINER                 # Filesystem changes

# Interaction
docker exec -it CONTAINER /bin/sh     # Shell access
docker attach CONTAINER               # Attach to main process
docker cp CONTAINER:/path ./local     # Copy files out
docker cp ./local CONTAINER:/path     # Copy files in

# Network
docker network inspect NETWORK        # Network details
docker exec CONTAINER ping HOST       # Test connectivity
docker exec CONTAINER netstat -tulpn  # Listening ports
docker exec CONTAINER nslookup DOMAIN # DNS check

# Volumes
docker volume inspect VOLUME          # Volume details
docker exec CONTAINER df -h           # Disk usage
docker exec CONTAINER ls -la /path    # List files

# System
docker system info                    # System information
docker system df                      # Disk usage
docker system events                  # System events
docker version                        # Version info
```

## Output

Provide:
1. Identified issue description
2. Root cause analysis
3. Step-by-step debugging process followed
4. Solution with commands
5. Platform-specific considerations
6. Prevention recommendations
7. Verification steps to confirm fix
8. Related issues to watch for
