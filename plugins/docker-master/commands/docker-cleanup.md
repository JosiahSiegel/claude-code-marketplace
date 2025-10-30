---
description: Clean up Docker resources safely and efficiently across all platforms
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

# Docker Cleanup & Maintenance

## Purpose
Safely remove unused Docker resources to reclaim disk space while following best practices to avoid data loss across Windows, Linux, and macOS.

## Before Cleaning

**CRITICAL: Always check what will be deleted before running cleanup commands!**

### 1. Assess Current Usage

```bash
# Overall disk usage
docker system df

# Detailed breakdown
docker system df -v

# List all images
docker images -a

# List all containers
docker ps -a

# List all volumes
docker volume ls

# List all networks
docker network ls
```

## Safe Cleanup Procedures

### 2. Progressive Cleanup (Safest Approach)

Follow this order from safest to most aggressive:

#### Level 1: Remove Stopped Containers (Safest)

```bash
# Preview what will be removed
docker ps -a --filter "status=exited"

# Remove stopped containers
docker container prune

# Or remove specific container
docker rm CONTAINER_ID

# Remove multiple specific containers
docker rm $(docker ps -a -q --filter "status=exited")

# Force remove (if needed)
docker rm -f CONTAINER_ID
```

#### Level 2: Remove Dangling Images

```bash
# List dangling images (intermediate layers)
docker images -f "dangling=true"

# Remove dangling images
docker image prune

# Confirm space saved
docker system df
```

#### Level 3: Remove Unused Images

```bash
# List unused images
docker images --filter "dangling=false" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"

# Remove unused images (not associated with containers)
docker image prune -a

# Remove specific image
docker rmi IMAGE_ID

# Remove multiple images
docker rmi $(docker images -q --filter "dangling=true")

# Force remove (use cautiously)
docker rmi -f IMAGE_ID
```

⚠️ **Warning:** `-a` removes ALL unused images, not just dangling ones!

#### Level 4: Remove Unused Volumes (⚠️ Data Loss Risk)

```bash
# List all volumes
docker volume ls

# Identify unused volumes
docker volume ls -qf "dangling=true"

# ⚠️ BACKUP DATA FIRST if volumes contain important data!

# Remove unused volumes
docker volume prune

# Remove specific volume
docker volume rm VOLUME_NAME

# Force remove (⚠️ use with extreme caution)
docker volume rm -f VOLUME_NAME
```

**IMPORTANT:** Volume removal is PERMANENT. Backup data before removal!

#### Level 5: Remove Unused Networks

```bash
# List networks
docker network ls

# Remove unused networks
docker network prune

# Remove specific network
docker network rm NETWORK_NAME

# Force disconnect and remove
docker network disconnect -f NETWORK_NAME CONTAINER_NAME
docker network rm NETWORK_NAME
```

#### Level 6: Remove Build Cache

```bash
# Check build cache usage
docker buildx du

# or
docker system df -v

# Remove build cache
docker builder prune

# Remove all build cache (more aggressive)
docker builder prune --all

# Keep cache from last N days
docker builder prune --keep-storage=10GB
docker builder prune --filter "until=24h"
```

### 3. One-Command Cleanup (⚠️ Use with Caution)

```bash
# Remove everything unused (INTERACTIVE - recommanded)
docker system prune

# Include volumes (⚠️ DATA LOSS RISK)
docker system prune --volumes

# Include all unused images
docker system prune -a

# Nuclear option (⚠️ MAXIMUM DATA LOSS RISK)
docker system prune -a --volumes

# Non-interactive (for scripts)
docker system prune -f
docker system prune -a -f
docker system prune -a --volumes -f
```

**⚠️ WARNING:**
- `docker system prune` removes: stopped containers, unused networks, dangling images
- `docker system prune -a` additionally removes: all unused images
- `docker system prune --volumes` additionally removes: unused volumes (DATA LOSS!)

### 4. Filtered Cleanup

#### Remove by Time

```bash
# Remove containers created more than 24 hours ago
docker container prune --filter "until=24h"

# Remove images created more than 7 days ago
docker image prune -a --filter "until=168h"

# Remove old build cache
docker builder prune --filter "until=48h"
```

#### Remove by Label

```bash
# Remove containers with specific label
docker container prune --filter "label=temporary"

# Remove images with specific label
docker image prune --filter "label=stage=build"

# Remove volumes with label
docker volume prune --filter "label=backup=false"
```

#### Remove by Size

Find and remove large images:
```bash
# List images sorted by size
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | sort -k3 -h -r

# Find images over 1GB
docker images --format "{{.Repository}}:{{.Tag}} {{.Size}}" | grep GB | head -10

# Remove specific large images
docker rmi LARGE_IMAGE_ID
```

### 5. Automated Cleanup Strategies

#### Automatic Container Removal

Use `--rm` flag for temporary containers:
```bash
# Container auto-removes when stopped
docker run --rm IMAGE_NAME
```

#### Log Rotation

Prevent log files from consuming disk:
```bash
# Set in docker run
docker run \
  --log-driver=json-file \
  --log-opt max-size=10m \
  --log-opt max-file=3 \
  IMAGE_NAME
```

Configure globally in `/etc/docker/daemon.json` (Linux/macOS):
```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

Restart Docker after configuration:
```bash
sudo systemctl restart docker  # Linux
```

#### Scheduled Cleanup (Linux)

Create a cron job:
```bash
# Edit crontab
crontab -e

# Add weekly cleanup (Sundays at 2 AM)
0 2 * * 0 /usr/bin/docker system prune -f

# Add daily cleanup with 7-day retention
0 3 * * * /usr/bin/docker image prune -a -f --filter "until=168h"
```

#### Scheduled Cleanup (Windows)

Create scheduled task with PowerShell:
```powershell
# Create task to run weekly
$action = New-ScheduledTaskAction -Execute 'docker' -Argument 'system prune -f'
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 2am
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "DockerCleanup"
```

#### Scheduled Cleanup (macOS)

Create launchd job:
```bash
# Create ~/Library/LaunchAgents/com.docker.cleanup.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.docker.cleanup</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/docker</string>
        <string>system</string>
        <string>prune</string>
        <string>-f</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Weekday</key>
        <integer>0</integer>
        <key>Hour</key>
        <integer>2</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
</dict>
</plist>

# Load the job
launchctl load ~/Library/LaunchAgents/com.docker.cleanup.plist
```

### 6. Docker Compose Cleanup

```bash
# Stop and remove containers defined in compose file
docker compose down

# Also remove volumes (⚠️ DATA LOSS RISK)
docker compose down -v

# Remove images used by services
docker compose down --rmi all

# Remove everything (⚠️ MAXIMUM CLEANUP)
docker compose down -v --rmi all --remove-orphans

# Remove orphan containers
docker compose down --remove-orphans
```

### 7. Platform-Specific Cleanup

#### macOS Docker Desktop

```bash
# Check Docker Desktop disk usage
# Docker Desktop → Preferences → Resources → Advanced

# Increase disk image size if needed
# Docker Desktop → Preferences → Resources → Disk image size

# Reset Docker Desktop (NUCLEAR OPTION - removes everything)
# Docker Desktop → Troubleshoot → Clean / Purge data
```

#### Windows Docker Desktop

```powershell
# Check disk usage
# Docker Desktop → Settings → Resources

# Clean WSL2 disk image (if using WSL2 backend)
# Stop Docker Desktop first
wsl --shutdown

# Compact VHDX file
Optimize-VHD -Path "$env:LOCALAPPDATA\Docker\wsl\data\ext4.vhdx" -Mode Full

# Or use diskpart
diskpart
select vdisk file="C:\Users\YourName\AppData\Local\Docker\wsl\data\ext4.vhdx"
compact vdisk
exit
```

#### Linux

```bash
# Clean journal logs (if Docker logs to journal)
sudo journalctl --vacuum-time=7d
sudo journalctl --vacuum-size=500M

# Clean old Docker logs manually
sudo find /var/lib/docker/containers/ -name "*.log" -exec truncate -s 0 {} \;

# Clean up old overlay2 data (only if Docker stopped)
sudo systemctl stop docker
sudo rm -rf /var/lib/docker/overlay2/*
sudo systemctl start docker
```

### 8. Safety Checklist Before Major Cleanup

Before running `docker system prune -a --volumes`:

- [ ] Backup important data in volumes
- [ ] Note down images you want to keep
- [ ] Export container configurations if needed
- [ ] Check no critical containers are stopped
- [ ] Verify no important builds in progress
- [ ] Save Dockerfiles for rebuilding images
- [ ] Document volume mount points
- [ ] Commit any important changes

### 9. Recovery Options

If you accidentally deleted something:

**Containers:**
```bash
# Recreate from image
docker run [same-parameters] IMAGE_NAME

# Recreate from compose file
docker compose up -d
```

**Images:**
```bash
# Pull from registry
docker pull IMAGE_NAME:TAG

# Rebuild from Dockerfile
docker build -t IMAGE_NAME .
```

**Volumes (if backed up):**
```bash
# Create new volume
docker volume create VOLUME_NAME

# Restore from backup
docker run --rm -v VOLUME_NAME:/data -v /backup:/backup alpine \
    sh -c "cd /data && tar xvf /backup/backup.tar"
```

### 10. Monitoring Cleanup Impact

```bash
# Before cleanup
docker system df > before-cleanup.txt

# Run cleanup
docker system prune -a

# After cleanup
docker system df > after-cleanup.txt

# Compare
diff before-cleanup.txt after-cleanup.txt

# Show space reclaimed
docker system df
```

## Cleanup Commands Quick Reference

```bash
# Safe progressive cleanup
docker container prune -f           # Remove stopped containers
docker image prune -f               # Remove dangling images
docker network prune -f             # Remove unused networks
docker builder prune -f             # Remove build cache

# Moderate cleanup
docker image prune -a -f            # Remove all unused images
docker system prune -f              # Remove stopped containers, unused networks, dangling images

# Aggressive cleanup (⚠️ CAUTION)
docker volume prune -f              # Remove unused volumes (DATA LOSS RISK)
docker system prune -a --volumes -f # Remove everything unused (MAXIMUM DATA LOSS RISK)

# Filtered cleanup
docker image prune -a -f --filter "until=168h"     # Remove images older than 7 days
docker container prune -f --filter "until=24h"      # Remove containers older than 24 hours

# Specific removal
docker rm $(docker ps -a -q)        # Remove all containers
docker rmi $(docker images -q)      # Remove all images
docker volume rm $(docker volume ls -q)  # Remove all volumes (⚠️ DATA LOSS)
```

## Best Practices

**DO:**
- ✅ Run `docker system df` before and after cleanup
- ✅ Use `--filter` to target specific resources
- ✅ Backup volume data before removal
- ✅ Schedule regular cleanup
- ✅ Configure log rotation
- ✅ Use `--rm` for temporary containers
- ✅ Review what will be deleted first (remove `-f` flag)
- ✅ Keep cleanup logs for audit

**DON'T:**
- ❌ Run `docker system prune -a --volumes -f` without understanding consequences
- ❌ Delete volumes without backups
- ❌ Clean up in production without testing
- ❌ Ignore warnings about data loss
- ❌ Run cleanup during active deployments
- ❌ Clean everything just to save space (rebuild costs time)

## Output

Provide:
1. Current disk usage assessment
2. Recommended cleanup commands based on usage
3. Space to be reclaimed estimate
4. Safety warnings for any destructive operations
5. Backup recommendations
6. Platform-specific cleanup steps
7. Verification commands
8. Post-cleanup disk usage report
