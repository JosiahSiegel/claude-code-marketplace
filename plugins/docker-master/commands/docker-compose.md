---
description: Manage multi-container applications with Docker Compose using best practices
---

# Docker Compose Best Practices

## Purpose
Create and manage multi-container Docker applications following current Docker Compose best practices and industry standards.

## Before Starting

**Check latest standards:**
1. Verify current Docker Compose file format version
2. Review Docker Compose documentation for new features
3. Check platform-specific requirements

## Compose File Analysis

### 1. Review Existing compose.yaml (if exists)
- Check file format version
- Identify security issues
- Note optimization opportunities
- Verify service dependencies are correct

### 2. Best Practices Checklist

#### File Format & Structure
```yaml
# Modern Compose format (2025: version field obsolete)
# No version field needed for Compose v2.40+

services:
  # Service definitions here

networks:
  # Custom networks (preferred over default)

volumes:
  # Named volumes (preferred over bind mounts for production)

configs:
  # Configuration files (for Swarm mode)

secrets:
  # Secrets (for Swarm mode)
```

**Important (2025 Update):** The `version` field is now obsolete in Docker Compose v2.40+. Modern compose files start directly with `services`.

#### Service Configuration Best Practices

**Image Management:**
```yaml
services:
  app:
    # Always specify exact versions
    image: nginx:1.25.3-alpine
    # Or build with context
    build:
      context: ./app
      dockerfile: Dockerfile
      args:
        - BUILD_DATE=${BUILD_DATE}
      cache_from:
        - ${CI_REGISTRY_IMAGE}:latest
```

**Resource Limits:**
```yaml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
```

**Health Checks:**
```yaml
services:
  app:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 40s
```

**Security:**
```yaml
services:
  app:
    # Run as non-root
    user: "1000:1000"
    # Read-only root filesystem
    read_only: true
    # Temporary filesystem for writes
    tmpfs:
      - /tmp
    # Drop capabilities
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
    # Security options
    security_opt:
      - no-new-privileges:true
```

**Logging:**
```yaml
services:
  app:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

**Restart Policy:**
```yaml
services:
  app:
    restart: unless-stopped
    # Or for Swarm mode:
    deploy:
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
```

#### Network Configuration

```yaml
# Create custom networks
networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true  # No external access

services:
  web:
    networks:
      - frontend

  api:
    networks:
      - frontend
      - backend

  database:
    networks:
      - backend  # Database not exposed to frontend
```

#### Volume Configuration

```yaml
# Named volumes (preferred)
volumes:
  db-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /path/on/host

services:
  database:
    volumes:
      # Named volume
      - db-data:/var/lib/postgresql/data
      # Config as read-only bind mount
      - ./config:/etc/config:ro
      # Temporary directory
      - /tmp
```

#### Environment Variables & Secrets

```yaml
services:
  app:
    # Use .env file for non-sensitive config
    env_file:
      - .env
    # Inline for service-specific vars
    environment:
      - NODE_ENV=production
      - LOG_LEVEL=info
    # For Swarm mode secrets
    secrets:
      - db_password

# Define secrets
secrets:
  db_password:
    file: ./secrets/db_password.txt
```

## Complete Example: Production-Ready Compose File

```yaml
# Modern Compose v2.40+ format (no version field)

services:
  nginx:
    image: nginx:1.25.3-alpine
    container_name: nginx-proxy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
      - nginx-logs:/var/log/nginx
    networks:
      - frontend
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/health"]
      interval: 30s
      timeout: 3s
      retries: 3
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    security_opt:
      - no-new-privileges:true

  app:
    build:
      context: ./app
      dockerfile: Dockerfile
      args:
        - NODE_ENV=production
    container_name: app-server
    restart: unless-stopped
    user: "node:node"
    read_only: true
    tmpfs:
      - /tmp
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
    depends_on:
      database:
        condition: service_healthy
      redis:
        condition: service_started
    networks:
      - frontend
      - backend
    environment:
      - NODE_ENV=production
      - DB_HOST=database
      - REDIS_HOST=redis
    env_file:
      - .env
    healthcheck:
      test: ["CMD", "node", "healthcheck.js"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 40s
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  database:
    image: postgres:16.1-alpine
    container_name: postgres-db
    restart: unless-stopped
    user: postgres
    volumes:
      - db-data:/var/lib/postgresql/data
      - ./db/init:/docker-entrypoint-initdb.d:ro
    networks:
      - backend
    environment:
      - POSTGRES_DB=${DB_NAME}
      - POSTGRES_USER=${DB_USER}
      - POSTGRES_PASSWORD_FILE=/run/secrets/db_password
    secrets:
      - db_password
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d ${DB_NAME}"]
      interval: 10s
      timeout: 3s
      retries: 3
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    security_opt:
      - no-new-privileges:true

  redis:
    image: redis:7.2-alpine
    container_name: redis-cache
    restart: unless-stopped
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis-data:/data
    networks:
      - backend
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 3
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    security_opt:
      - no-new-privileges:true

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true

volumes:
  db-data:
    driver: local
  redis-data:
    driver: local
  nginx-logs:
    driver: local

secrets:
  db_password:
    file: ./secrets/db_password.txt
```

## Platform-Specific Considerations

### Windows
- Use forward slashes in paths or escape backslashes
- Check line endings (LF vs CRLF)
- Volume paths must be under shared drives in Docker Desktop
- May need to adjust file permissions

### macOS
- Configure file sharing in Docker Desktop preferences
- Consider `:delegated` or `:cached` for better volume performance
- Be aware of case-sensitivity differences

### Linux
- SELinux may require `:z` or `:Z` flags on volumes
- User namespace remapping considerations
- Native performance (no VM overhead)

## Essential Commands

```bash
# Start services
docker compose up -d

# View logs
docker compose logs -f

# Check status
docker compose ps

# Stop services
docker compose stop

# Stop and remove containers
docker compose down

# Stop, remove containers and volumes
docker compose down -v

# Rebuild and restart
docker compose up -d --build

# Scale a service
docker compose up -d --scale app=3

# Validate compose file
docker compose config

# View resource usage
docker stats $(docker compose ps -q)
```

## Development vs Production

### Development Override

Create `docker-compose.override.yml`:
```yaml
services:
  app:
    build:
      target: development
    volumes:
      # Mount source code for hot reload
      - ./src:/app/src
    environment:
      - NODE_ENV=development
    ports:
      # Expose debugger
      - "9229:9229"
```

### Production Configuration

Create `docker-compose.prod.yml`:
```yaml
services:
  app:
    build:
      target: production
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
      rollback_config:
        parallelism: 1
        delay: 5s
```

Use: `docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d`

## .env File Best Practices

```bash
# .env file structure
# Database
DB_NAME=myapp
DB_USER=appuser
# DON'T put sensitive passwords here - use secrets!

# Application
NODE_ENV=production
LOG_LEVEL=info

# Redis
REDIS_PASSWORD=changeme
```

**IMPORTANT:** Add `.env` to `.gitignore`! Provide `.env.example` instead.

## Validation & Testing

1. Validate syntax: `docker compose config`
2. Check for security issues in images
3. Test startup order and dependencies
4. Verify health checks work
5. Test graceful shutdown: `docker compose down`
6. Verify data persistence after restart
7. Check logs for errors
8. Monitor resource usage

## Output

Provide:
1. Optimized `docker-compose.yml` file
2. Platform-specific notes
3. `.env.example` file
4. Security recommendations
5. Commands for common operations
6. Healthcheck validation
7. Resource usage expectations
