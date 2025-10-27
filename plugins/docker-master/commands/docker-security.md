---
description: Scan and harden Docker containers following security best practices
---

# Docker Security Scanning & Hardening

## Purpose
Identify and fix security vulnerabilities in Docker images and containers following current security best practices and compliance standards.

## Security Assessment Process

### 1. Pre-Scan Research

**Check latest security standards:**
1. Review Docker security best practices (current year - **CIS Docker Benchmark v1.7.0** as of 2025)
2. Check current CVE databases and vulnerability trends
3. Review OWASP Docker Security Cheat Sheet
4. Understand platform-specific security features (SELinux, AppArmor, Windows Defender)

### 2. Vulnerability Scanning

#### Image Scanning Tools

**Docker Scout (built-in, recommended):**
```bash
# Analyze image for vulnerabilities
docker scout cves IMAGE_NAME

# Get recommendations
docker scout recommendations IMAGE_NAME

# Compare with another image
docker scout compare --to IMAGE_NAME:latest IMAGE_NAME:new

# View detailed CVE information
docker scout cves --format sarif IMAGE_NAME > report.sarif
```

**Trivy (comprehensive, recommended):**
```bash
# Scan image for vulnerabilities
trivy image IMAGE_NAME

# Scan for specific severities (fail on critical)
trivy image --severity HIGH,CRITICAL --exit-code 1 IMAGE_NAME

# Generate SBOM during scan
trivy image --format spdx-json --output sbom.spdx.json IMAGE_NAME

# Scan for secrets (MANDATORY 2025)
trivy image --scanners secret IMAGE_NAME
trivy fs --scanners secret .

# Scan Dockerfile for misconfigurations
trivy config Dockerfile

# Generate comprehensive report
trivy image --format json --output security-report.json IMAGE_NAME
```

**Grype (Anchore):**
```bash
# Scan image
grype IMAGE_NAME

# Specific severity
grype IMAGE_NAME --fail-on critical

# Output formats
grype IMAGE_NAME -o json
grype IMAGE_NAME -o cyclonedx
```

**Snyk (commercial, free tier available):**
```bash
snyk container test IMAGE_NAME
snyk container monitor IMAGE_NAME
```

### 3. Security Hardening Checklist

#### Base Image Security

**2025 RECOMMENDED BASE IMAGES (by security level):**

1. **Maximum Security (Zero-CVE goal):**
   - Wolfi/Chainguard Images: `cgr.dev/chainguard/{node|python|go|etc}:latest`
   - Built-in SBOM, nightly security patches, minimal attack surface
   - Ideal for: Production, compliance, security-critical apps

2. **High Security (Minimal):**
   - Distroless: `gcr.io/distroless/{static|base|...}` (~2MB)
   - Alpine: `alpine:3.19` (~7MB)
   - Ideal for: Standard production workloads

3. **Standard Security:**
   - Slim variants: `python:3.12-slim`, `node:20-slim` (~70MB)
   - Ideal for: Development, compatibility requirements

**DO:**
- ✅ Use official images from trusted sources
- ✅ Specify exact version tags (never `latest`)
- ✅ **2025:** Prefer Wolfi/Chainguard for security-critical workloads
- ✅ Scan base images regularly
- ✅ Keep base images updated

**DON'T:**
- ❌ Use unverified images from Docker Hub
- ❌ Use `latest` or no tag
- ❌ Use full OS images when unnecessary
- ❌ Ignore base image vulnerabilities

#### Dockerfile Security Hardening

**Secure Dockerfile template:**
```dockerfile
# syntax=docker/dockerfile:1

# Use specific version
FROM node:20.11.0-alpine3.19

# Security: Add labels for metadata
LABEL org.opencontainers.image.source="https://github.com/user/repo"
LABEL org.opencontainers.image.description="Application description"
LABEL org.opencontainers.image.licenses="MIT"

# Security: Create non-root user early
RUN addgroup -g 1001 -S appuser && \
    adduser -S appuser -u 1001

# Set working directory
WORKDIR /app

# Security: Copy only necessary files
COPY --chown=appuser:appuser package*.json ./

# Security: Install only production dependencies
RUN npm ci --only=production && \
    npm cache clean --force && \
    # Remove npm completely if not needed at runtime
    rm -rf /usr/local/lib/node_modules/npm

# Copy application code
COPY --chown=appuser:appuser . .

# Security: Run as non-root
USER appuser

# Security: Use exec form to avoid shell
ENTRYPOINT ["node"]
CMD ["server.js"]

# Security: Don't expose unnecessary ports
EXPOSE 3000

# Security: Add health check
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD node healthcheck.js || exit 1
```

#### Runtime Security Configuration

**Secure docker run command:**
```bash
docker run \
  # Security: Drop all capabilities
  --cap-drop=ALL \
  # Add only needed capabilities
  --cap-add=NET_BIND_SERVICE \
  # Security: Read-only root filesystem
  --read-only \
  # Temporary writable directories
  --tmpfs /tmp:noexec,nosuid,size=64M \
  --tmpfs /var/run:noexec,nosuid,size=64M \
  # Security: No new privileges
  --security-opt="no-new-privileges:true" \
  # Security: AppArmor profile (Linux)
  --security-opt="apparmor=docker-default" \
  # Security: Seccomp profile
  --security-opt="seccomp=default" \
  # Resource limits
  --memory="512m" \
  --cpus="1.0" \
  --pids-limit=100 \
  # Network security
  --network=custom-network \
  # Don't use privileged mode
  # --privileged  # NEVER use unless absolutely necessary!
  IMAGE_NAME
```

#### Secrets Management

**NEVER DO THIS:**
```dockerfile
# ❌ Don't hardcode secrets
ENV API_KEY=secret123
RUN git clone https://user:password@github.com/repo.git
```

**DO THIS INSTEAD:**

**Option 1: Build secrets (BuildKit):**
```dockerfile
# syntax=docker/dockerfile:1

FROM alpine
RUN --mount=type=secret,id=github_token \
    git clone https://$(cat /run/secrets/github_token)@github.com/repo.git
```

```bash
# Build with secret
docker build --secret id=github_token,src=token.txt .
```

**Option 2: Runtime secrets:**
```bash
# Create secret
echo "secret_value" | docker secret create my_secret -

# Use in service
docker service create \
  --secret my_secret \
  IMAGE_NAME
```

**Option 3: Environment files:**
```bash
# Never commit .env files!
docker run --env-file .env IMAGE_NAME
```

**Option 4: Mounted config files:**
```bash
docker run -v /secure/path/config.json:/app/config.json:ro IMAGE_NAME
```

### 4. Security Best Practices by Category

#### Network Security

```yaml
# docker-compose.yml
services:
  web:
    # Only expose what's needed
    ports:
      # Bind to localhost only
      - "127.0.0.1:8080:8080"
    networks:
      - frontend

  api:
    # No ports exposed to host
    networks:
      - frontend
      - backend

  database:
    # Isolated backend network
    networks:
      - backend

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true  # No external access
```

#### File System Security

```dockerfile
# Make filesystem read-only
# Configure writable directories at runtime with tmpfs

# At runtime:
docker run \
  --read-only \
  --tmpfs /tmp:noexec,nosuid \
  --tmpfs /var/run:noexec,nosuid \
  IMAGE_NAME
```

#### Logging Security

```yaml
services:
  app:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    # Or use centralized logging
    # logging:
    #   driver: "syslog"
    #   options:
    #     syslog-address: "tcp://192.168.1.100:514"
```

**Important:** Ensure logs don't contain sensitive data!

#### User Namespace Remapping (Linux)

```json
// /etc/docker/daemon.json
{
  "userns-remap": "default"
}
```

Restart Docker daemon after configuration.

### 5. SBOM Generation (2025 MANDATORY)

**Why SBOM is Critical:**
- Supply chain transparency and security
- Vulnerability tracking and rapid response
- Compliance (Executive Order 14028, NIST, etc.)
- License compliance
- Incident response readiness

**Generate SBOM:**
```bash
# Using Docker Scout (built-in)
docker scout sbom IMAGE_NAME --format spdx > sbom.spdx.json
docker scout sbom IMAGE_NAME --format cyclonedx > sbom.cyclonedx.json

# Using Syft (industry standard, recommended)
syft IMAGE_NAME -o spdx-json > sbom.spdx.json
syft IMAGE_NAME -o cyclonedx-json > sbom.cyclonedx.json

# Build with SBOM attestation (WARNING: not cryptographically signed)
docker buildx build --sbom=true --provenance=true -t IMAGE_NAME .

# Scan SBOM for vulnerabilities (faster than scanning image)
grype sbom:sbom.spdx.json --fail-on high
trivy sbom sbom.spdx.json
```

**SBOM in CI/CD:**
- Generate SBOM for every production build
- Store SBOM alongside image in registry
- Fail builds if SBOM generation fails
- Continuously scan SBOM for new vulnerabilities

### 6. Compliance & Benchmarking

#### CIS Docker Benchmark v1.7.0 (2025)

Run automated checks:
```bash
# Docker Bench for Security (checks ~140 controls)
git clone https://github.com/docker/docker-bench-security.git
cd docker-bench-security
sudo sh docker-bench-security.sh

# Or run as container (preferred)
docker run --rm --net host --pid host --userns host --cap-add audit_control \
    -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
    -v /var/lib:/var/lib:ro \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v /usr/lib/systemd:/usr/lib/systemd:ro \
    -v /etc:/etc:ro \
    --label docker_bench_security \
    docker/docker-bench-security
```

#### Docker Content Trust

Enable image signing:
```bash
# Enable Docker Content Trust
export DOCKER_CONTENT_TRUST=1

# Pull verified images only
docker pull IMAGE_NAME

# Push signed images
docker push IMAGE_NAME
```

### 6. Security Monitoring

#### Runtime Security Monitoring

```bash
# Monitor container processes
docker top CONTAINER_NAME

# Check for unexpected processes
docker exec CONTAINER_NAME ps aux

# Review logs for suspicious activity
docker logs CONTAINER_NAME | grep -i "error\|unauthorized\|failed"

# Monitor resource usage (detect crypto mining)
docker stats CONTAINER_NAME
```

#### File Integrity Monitoring

```bash
# Export filesystem
docker export CONTAINER_NAME > container.tar

# Compare with known good state
diff <(tar -tf container-good.tar | sort) <(tar -tf container-current.tar | sort)
```

### 7. Platform-Specific Security

#### Windows Containers

```powershell
# Run with process isolation (more secure)
docker run --isolation=process IMAGE_NAME

# Check for Windows updates in base image
docker run IMAGE_NAME systeminfo | findstr "Hotfix"
```

#### Linux with SELinux

```bash
# Enable SELinux labels
docker run --security-opt label=type:container_t IMAGE_NAME

# Use with volumes
docker run -v /host/path:/container/path:z IMAGE_NAME
```

#### macOS Docker Desktop

```bash
# Check for security updates
docker version

# Review resource access in Docker Desktop settings
# Limit file sharing to only necessary directories
```

### 8. Security Audit Report Template

After scanning and hardening, provide:

```markdown
# Docker Security Audit Report

## Image: IMAGE_NAME:TAG

### Vulnerability Summary
- Critical: X
- High: X
- Medium: X
- Low: X

### Top Vulnerabilities
1. CVE-XXXX-XXXX - Description - Severity: CRITICAL
   - Impact: ...
   - Fix: Update package X to version Y

### Security Hardening Applied
- [x] Non-root user configured
- [x] Read-only filesystem enabled
- [x] Capabilities dropped
- [x] Security options set
- [x] Secrets removed from layers
- [x] Minimal base image used

### Compliance
- CIS Docker Benchmark Score: X/100
- Failed checks: [List]

### Recommendations
1. Update base image to address CVE-XXXX-XXXX
2. Remove unnecessary package X
3. Implement runtime monitoring
4. Enable Docker Content Trust

### Next Steps
- [ ] Update Dockerfile
- [ ] Rebuild image
- [ ] Re-scan for vulnerabilities
- [ ] Deploy to staging for testing
```

## Common Security Pitfalls

**❌ DON'T:**
- Run as root
- Use `--privileged` mode
- Mount Docker socket (`/var/run/docker.sock`)
- Hardcode secrets
- Use `latest` tag
- Disable security features
- Expose unnecessary ports
- Skip vulnerability scanning
- Use unverified images

**✅ DO:**
- Run as non-root user
- Drop capabilities
- Use secrets management
- Specify exact versions
- Enable security options
- Follow principle of least privilege
- Scan regularly
- Monitor runtime behavior
- Keep images updated

## Security Tools Reference

| Tool | Purpose | Command |
|------|---------|---------|
| Docker Scout | CVE scanning | `docker scout cves IMAGE` |
| Trivy | Comprehensive scanning | `trivy image IMAGE` |
| Grype | Vulnerability detection | `grype IMAGE` |
| Docker Bench | CIS compliance | `docker-bench-security.sh` |
| Snyk | Commercial scanning | `snyk container test IMAGE` |
| Clair | Static analysis | Via API |
| Falco | Runtime security | System monitoring |

## Output

Provide:
1. Vulnerability scan results with severity levels
2. Hardened Dockerfile with security improvements
3. Secure runtime configuration
4. Security audit report
5. Compliance check results
6. Prioritized remediation steps
7. Platform-specific security recommendations
8. Monitoring and detection strategies
