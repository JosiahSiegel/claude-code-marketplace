---
description: Manage container registry operations including push, pull, authentication, and multi-registry workflows
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

# Docker Registry Operations

## Purpose
Manage container images across Docker registries (Docker Hub, GitHub Container Registry, AWS ECR, Azure ACR, Google Artifact Registry) following 2025 best practices for authentication, tagging, and multi-registry workflows.

## Registry Types & Authentication

### Docker Hub

**Authentication:**
```bash
# Interactive login
docker login

# Non-interactive (CI/CD)
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

# Using access token (recommended)
echo "$DOCKER_ACCESS_TOKEN" | docker login -u "$DOCKER_USERNAME" --password-stdin
```

**Image naming:**
```bash
# Format: [username]/[repository]:[tag]
docker tag myapp:latest username/myapp:1.0.0
docker push username/myapp:1.0.0
```

### GitHub Container Registry (ghcr.io)

**Authentication:**
```bash
# Using Personal Access Token (PAT) with packages:read and packages:write
echo "$GITHUB_TOKEN" | docker login ghcr.io -u USERNAME --password-stdin

# In GitHub Actions (automatic)
echo "${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u ${{ github.actor }} --password-stdin
```

**Image naming:**
```bash
# Format: ghcr.io/[owner]/[repository]:[tag]
docker tag myapp:latest ghcr.io/username/myapp:1.0.0
docker push ghcr.io/username/myapp:1.0.0
```

**Best practice:** Mark packages as public/private via GitHub UI or API.

### AWS Elastic Container Registry (ECR)

**Authentication:**
```bash
# Get login token (valid for 12 hours)
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Or using helper
$(aws ecr get-login --no-include-email --region us-east-1)
```

**Create repository:**
```bash
aws ecr create-repository --repository-name myapp --region us-east-1
```

**Image naming:**
```bash
# Format: ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/[repository]:[tag]
docker tag myapp:latest 123456789.dkr.ecr.us-east-1.amazonaws.com/myapp:1.0.0
docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/myapp:1.0.0
```

### Azure Container Registry (ACR)

**Authentication:**
```bash
# Using Azure CLI
az acr login --name myregistry

# Using service principal
docker login myregistry.azurecr.io \
  -u SERVICE_PRINCIPAL_ID \
  -p SERVICE_PRINCIPAL_PASSWORD

# Using admin credentials (not recommended for production)
az acr credential show --name myregistry
docker login myregistry.azurecr.io -u USERNAME -p PASSWORD
```

**Image naming:**
```bash
# Format: [registry].azurecr.io/[repository]:[tag]
docker tag myapp:latest myregistry.azurecr.io/myapp:1.0.0
docker push myregistry.azurecr.io/myapp:1.0.0
```

### Google Artifact Registry

**Authentication:**
```bash
# Configure Docker credential helper
gcloud auth configure-docker REGION-docker.pkg.dev

# Or manual login
gcloud auth print-access-token | docker login \
  -u oauth2accesstoken \
  --password-stdin https://REGION-docker.pkg.dev
```

**Image naming:**
```bash
# Format: REGION-docker.pkg.dev/PROJECT_ID/REPOSITORY/IMAGE:TAG
docker tag myapp:latest us-central1-docker.pkg.dev/my-project/myrepo/myapp:1.0.0
docker push us-central1-docker.pkg.dev/my-project/myrepo/myapp:1.0.0
```

## Image Tagging Strategy (2025 Best Practices)

### Semantic Versioning

```bash
# Build and tag with multiple tags
docker build -t myapp:1.2.3 .
docker tag myapp:1.2.3 myapp:1.2
docker tag myapp:1.2.3 myapp:1
docker tag myapp:1.2.3 myapp:latest

# Push all tags
docker push myapp:1.2.3
docker push myapp:1.2
docker push myapp:1
docker push myapp:latest
```

### Environment-Specific Tags

```bash
# Production
docker tag myapp:1.2.3 registry.example.com/myapp:1.2.3-production
docker tag myapp:1.2.3 registry.example.com/myapp:production

# Staging
docker tag myapp:1.2.3 registry.example.com/myapp:1.2.3-staging
docker tag myapp:1.2.3 registry.example.com/myapp:staging
```

### Git Commit SHA

```bash
# Include git commit for traceability
GIT_SHA=$(git rev-parse --short HEAD)
docker tag myapp:1.2.3 myapp:1.2.3-${GIT_SHA}
docker push myapp:1.2.3-${GIT_SHA}
```

### Multi-Architecture Tags

```bash
# Build and push multi-arch images
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t myapp:1.2.3 \
  --push \
  .

# Manifest is automatically created
docker buildx imagetools inspect myapp:1.2.3
```

## Pushing Images

### Single Image Push

```bash
# Tag and push
docker tag local-image:tag registry.example.com/namespace/image:tag
docker push registry.example.com/namespace/image:tag
```

### Multi-Tag Push

```bash
# Push all tags for an image
docker push --all-tags registry.example.com/namespace/image
```

### Build and Push in One Step

```bash
# Using buildx (recommended)
docker buildx build \
  -t registry.example.com/myapp:1.0.0 \
  -t registry.example.com/myapp:latest \
  --push \
  .

# Traditional build
docker build -t registry.example.com/myapp:1.0.0 . && \
docker push registry.example.com/myapp:1.0.0
```

## Pulling Images

### Pull Specific Tag

```bash
# Pull exact version
docker pull registry.example.com/myapp:1.2.3

# Pull by digest (immutable)
docker pull myapp@sha256:abc123...
```

### Pull All Tags

```bash
# Pull all tags of an image
docker pull --all-tags registry.example.com/namespace/image
```

### Pull with Platform Specification

```bash
# Pull specific platform
docker pull --platform linux/arm64 registry.example.com/myapp:latest
```

## Registry Management Commands

### List Remote Tags

```bash
# Docker Hub
curl -s "https://registry.hub.docker.com/v2/repositories/USERNAME/REPO/tags/" | jq

# AWS ECR
aws ecr list-images --repository-name myapp --region us-east-1

# Azure ACR
az acr repository show-tags --name myregistry --repository myapp

# Google Artifact Registry
gcloud artifacts docker tags list REGION-docker.pkg.dev/PROJECT/REPO/IMAGE

# GitHub Container Registry
curl -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://ghcr.io/v2/OWNER/REPO/tags/list"
```

### Delete Remote Images

```bash
# Docker Hub (requires API token)
curl -X DELETE \
  -H "Authorization: JWT $TOKEN" \
  "https://hub.docker.com/v2/repositories/USERNAME/REPO/tags/TAG/"

# AWS ECR
aws ecr batch-delete-image \
  --repository-name myapp \
  --image-ids imageTag=1.0.0 \
  --region us-east-1

# Azure ACR
az acr repository delete \
  --name myregistry \
  --image myapp:1.0.0

# Google Artifact Registry
gcloud artifacts docker images delete \
  REGION-docker.pkg.dev/PROJECT/REPO/IMAGE:TAG

# GitHub Container Registry (via API)
curl -X DELETE \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://ghcr.io/v2/OWNER/REPO/manifests/sha256:DIGEST"
```

### Registry Cleanup (Retention Policies)

```bash
# AWS ECR - Lifecycle policy
aws ecr put-lifecycle-policy \
  --repository-name myapp \
  --lifecycle-policy-text file://policy.json

# policy.json example
{
  "rules": [{
    "rulePriority": 1,
    "description": "Keep last 10 production images",
    "selection": {
      "tagStatus": "tagged",
      "tagPrefixList": ["production"],
      "countType": "imageCountMoreThan",
      "countNumber": 10
    },
    "action": { "type": "expire" }
  }]
}

# Azure ACR - Retention policy
az acr config retention update \
  --registry myregistry \
  --status enabled \
  --days 30 \
  --type UntaggedManifests

# Google Artifact Registry - Cleanup policy
gcloud artifacts repositories update REPO \
  --location=REGION \
  --cleanup-policy-dry-run \
  --cleanup-policies=policy.json
```

## Security Best Practices

### Image Signing (Docker Content Trust)

```bash
# Enable Docker Content Trust
export DOCKER_CONTENT_TRUST=1

# Push signed image
docker push registry.example.com/myapp:1.0.0
# This will prompt for passphrase and create signatures

# Pull verified image only
docker pull registry.example.com/myapp:1.0.0
# Fails if signature invalid
```

### Vulnerability Scanning Before Push

```bash
# Scan with Docker Scout
docker scout cves myapp:latest
docker scout recommendations myapp:latest

# Fail if critical vulnerabilities
docker scout cves --exit-code --only-severity critical myapp:latest

# Scan with Trivy
trivy image --severity HIGH,CRITICAL --exit-code 1 myapp:latest

# Then push if scan passes
docker push registry.example.com/myapp:latest
```

### SBOM Generation and Registry Attestations

```bash
# Generate SBOM with image
docker buildx build \
  --sbom=true \
  --provenance=true \
  -t registry.example.com/myapp:1.0.0 \
  --push \
  .

# View attestations
docker buildx imagetools inspect registry.example.com/myapp:1.0.0 \
  --format "{{ json .SBOM }}"

# ⚠️ WARNING: BuildKit attestations are NOT cryptographically signed
# Use external signing tools for production security:
cosign sign registry.example.com/myapp:1.0.0
```

## Multi-Registry Workflows

### Mirror Images Between Registries

```bash
# Pull from source
docker pull source-registry.com/myapp:1.0.0

# Tag for destination
docker tag source-registry.com/myapp:1.0.0 dest-registry.com/myapp:1.0.0

# Push to destination
docker push dest-registry.com/myapp:1.0.0

# Or use skopeo (faster, no Docker required)
skopeo copy \
  docker://source-registry.com/myapp:1.0.0 \
  docker://dest-registry.com/myapp:1.0.0
```

### Registry Mirroring Configuration

```json
// /etc/docker/daemon.json
{
  "registry-mirrors": [
    "https://mirror.example.com"
  ],
  "insecure-registries": [
    "internal-registry:5000"
  ]
}
```

Restart Docker after configuration change.

## CI/CD Integration Examples

### GitHub Actions

```yaml
name: Build and Push

on:
  push:
    tags: ['v*']

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ghcr.io/${{ github.repository }}
          tags: |
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha

      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          sbom: true
          provenance: true
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### Azure DevOps Pipeline

```yaml
trigger:
  tags:
    include: ['v*']

pool:
  vmImage: ubuntu-latest

steps:
- task: Docker@2
  displayName: Login to ACR
  inputs:
    command: login
    containerRegistry: MyACR

- task: Docker@2
  displayName: Build and Push
  inputs:
    command: buildAndPush
    repository: myapp
    tags: |
      $(Build.SourceBranchName)
      latest
    Dockerfile: Dockerfile
```

## Private Registry Setup (Self-Hosted)

### Run Private Registry

```bash
# Start registry container
docker run -d \
  -p 5000:5000 \
  --name registry \
  --restart=always \
  -v /data/registry:/var/lib/registry \
  registry:2

# With authentication
docker run -d \
  -p 5000:5000 \
  --name registry \
  --restart=always \
  -v /data/registry:/var/lib/registry \
  -v /auth:/auth \
  -e "REGISTRY_AUTH=htpasswd" \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e "REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd" \
  registry:2

# Create htpasswd file
docker run --rm --entrypoint htpasswd \
  httpd:2 -Bbn username password > /auth/htpasswd
```

### Configure TLS

```bash
docker run -d \
  -p 443:443 \
  --name registry \
  --restart=always \
  -v /data/registry:/var/lib/registry \
  -v /certs:/certs \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  registry:2
```

## Troubleshooting

### Authentication Issues

```bash
# View stored credentials
cat ~/.docker/config.json

# Remove credentials
docker logout registry.example.com

# Test registry access
curl -I https://registry.example.com/v2/

# Test authentication
curl -u username:password https://registry.example.com/v2/_catalog
```

### Push/Pull Failures

```bash
# Check network connectivity
docker pull registry.example.com/myapp:latest --debug

# Verify image exists locally
docker images | grep myapp

# Check image manifest
docker manifest inspect registry.example.com/myapp:latest

# Retry with increased timeout
DOCKER_CLI_EXPERIMENTAL=enabled docker manifest inspect \
  --timeout=300s registry.example.com/myapp:latest
```

### Rate Limiting (Docker Hub)

```bash
# Check rate limit status
TOKEN=$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:ratelimitpreview/test:pull" | jq -r .token)
curl -s -H "Authorization: Bearer $TOKEN" https://registry-1.docker.io/v2/ratelimitpreview/test/manifests/latest -I | grep -i ratelimit

# Authenticate to increase limits
docker login
```

## Platform-Specific Considerations

### Windows
- Use forward slashes in registry URLs
- Ensure Docker Desktop is running
- Check Windows Firewall for registry access

### macOS
- Keychain stores Docker credentials
- Docker Desktop manages authentication

### Linux
- Credentials stored in `~/.docker/config.json`
- May need `sudo` for system-wide Docker daemon
- Corporate proxies may require configuration in `/etc/docker/daemon.json`

## Output

Provide:
1. Complete authentication commands for target registry
2. Image tagging strategy with recommended tags
3. Push/pull commands with verification steps
4. Security scanning and signing workflow
5. CI/CD integration examples
6. Troubleshooting commands for common issues
7. Platform-specific configuration if needed
