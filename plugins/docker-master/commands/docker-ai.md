---
description: Use Docker AI (Project Gordon) for intelligent container development assistance
---

# Docker AI Assistant (Project Gordon)

## Purpose
Leverage Docker's AI-powered assistant (Project Gordon, available in Docker Desktop 4.38+) for intelligent, context-aware Docker guidance and automation.

## What is Docker AI?

**Docker AI (Project Gordon)** is Docker's 2025 AI-powered assistant integrated into Docker Desktop and CLI. It provides:
- Real-time, context-aware command suggestions
- Intelligent troubleshooting and debugging
- Best practice recommendations based on your specific setup
- Natural language query interface
- Automated Dockerfile optimization

## Availability

**Requires:**
- Docker Desktop 4.38+ (released 2025)
- Beta feature enrollment in Docker Desktop settings

**Platform Support:**
- Windows (WSL2 and Hyper-V)
- macOS (Intel and Apple Silicon)
- Linux (Docker Desktop for Linux)

## Use Cases

### 1. Natural Language Commands

Ask Docker AI in plain English:

```bash
# Enable Docker AI (in Docker Desktop settings)
# Then use natural language:

"How do I optimize my Node.js Dockerfile?"
"Why is my container using so much memory?"
"Show me the best base image for Python 3.12"
"Create a secure nginx configuration"
```

Docker AI analyzes your context and provides tailored recommendations.

### 2. Intelligent Troubleshooting

When containers fail, Docker AI:
- Analyzes logs automatically
- Identifies root causes
- Suggests fixes based on your platform
- Provides step-by-step resolution guidance

```bash
# Container failed to start
# Docker AI will analyze:
# - Exit codes
# - Error logs
# - Resource constraints
# - Network issues
# - Permission problems
```

### 3. Dockerfile Optimization

Docker AI can review and optimize Dockerfiles:

**Input:** Your current Dockerfile
**Docker AI analyzes:**
- Security vulnerabilities
- Layer caching efficiency
- Image size optimization opportunities
- Best practice violations
- Platform-specific improvements

**Output:** Optimized Dockerfile with explanations

### 4. Best Practice Recommendations

Docker AI provides context-aware guidance:
- Suggests appropriate base images for your stack
- Recommends security configurations
- Optimizes resource limits
- Proposes health check strategies
- Advises on multi-stage build opportunities

## Integration with Docker Desktop

### Access Docker AI

**Docker Desktop GUI:**
1. Open Docker Desktop 4.38+
2. Navigate to the AI Assistant panel
3. Type natural language queries
4. View contextual recommendations

**CLI Integration (Beta):**
```bash
# Ask Docker AI via CLI
docker ai ask "How do I reduce my image size?"

# Get troubleshooting help
docker ai debug CONTAINER_NAME

# Optimize Dockerfile
docker ai optimize Dockerfile
```

## Docker AI vs Traditional Approach

### Traditional Workflow:
1. Search documentation
2. Read multiple articles
3. Trial and error with commands
4. Debug issues manually
5. Repeat until working

### With Docker AI:
1. Ask in natural language
2. Get context-aware answer immediately
3. Receive tested commands for your setup
4. Apply recommendations
5. Success

## Privacy and Local Processing

**Docker Model Runner (2025 Feature):**
- Runs AI models locally on your machine
- No cloud API calls required
- Privacy-preserving (data stays local)
- Optimal GPU acceleration
- Works offline

**What Docker AI Knows:**
- Your current Docker configuration
- Running containers and images
- System resources
- Platform (Windows/Linux/macOS)
- Docker version and features

**What Docker AI Does NOT Access:**
- Container contents or application data
- Environment variables or secrets
- Volume data
- Network traffic
- Sensitive logs (unless explicitly shared)

## Best Practices for Using Docker AI

### 1. Be Specific

**Poor query:**
"My container doesn't work"

**Better query:**
"My Node.js container exits with code 137 after 10 seconds, how do I fix out-of-memory issues?"

### 2. Provide Context

Include relevant details:
- Platform (Windows/Linux/macOS)
- Docker version
- Error messages
- What you've already tried

### 3. Verify Recommendations

Docker AI provides excellent guidance, but:
- Always review generated Dockerfiles
- Understand suggested commands before running
- Test in non-production first
- Validate security recommendations

### 4. Combine with Traditional Tools

Use Docker AI alongside:
- Docker Scout for vulnerability scanning
- Trivy for comprehensive security analysis
- docker-bench-security for CIS compliance
- Manual code review

## Example: Complete Dockerfile Optimization with Docker AI

**Original Dockerfile:**
```dockerfile
FROM node:latest
COPY . /app
WORKDIR /app
RUN npm install
CMD node server.js
```

**Docker AI Analysis:**
- Using `latest` tag (unpredictable)
- No multi-stage build (large image)
- Running as root (security risk)
- No health check
- Inefficient layer caching
- No .dockerignore usage

**Docker AI Optimized Dockerfile:**
```dockerfile
# syntax=docker/dockerfile:1

# Build stage
FROM node:20.12.0-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --only=production

# Production stage
FROM node:20.12.0-alpine
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001
WORKDIR /app
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --chown=nodejs:nodejs . .
USER nodejs
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD node healthcheck.js || exit 1
CMD ["node", "server.js"]
```

**Docker AI Explanation:**
- Pinned Node.js version for reproducibility
- Multi-stage build reduces size by ~70%
- Non-root user for security
- BuildKit cache mount for faster builds
- Health check for reliability
- Proper layer ordering for cache efficiency

## Limitations

**Current Docker AI Limitations (2025):**
1. Beta feature - may have occasional inaccuracies
2. Best for common scenarios (edge cases may need manual review)
3. Context limited to Docker-specific tasks
4. May not know very recent changes (check official docs)
5. Cannot access external services or repositories

**When to Use Traditional Methods:**
- Highly specialized or custom setups
- Legacy Docker versions (< 4.38)
- Compliance-critical environments requiring human review
- Complex multi-platform builds with custom frontends
- When offline access to Model Runner isn't available

## Security Considerations

**Docker AI and Security:**
- ✅ Provides security best practice recommendations
- ✅ Suggests vulnerability mitigations
- ✅ Recommends secure base images
- ✅ Identifies common security pitfalls

**Important:**
- Always scan AI-generated Dockerfiles with Docker Scout/Trivy
- Review secrets management recommendations carefully
- Validate runtime security configurations
- Don't trust AI blindly for security-critical applications

## Troubleshooting Docker AI

**Docker AI Not Available:**
- Ensure Docker Desktop 4.38+ installed
- Enable beta features in Docker Desktop settings
- Restart Docker Desktop after enabling
- Check system requirements (GPU acceleration may need drivers)

**Poor Recommendations:**
- Provide more context in queries
- Specify platform and constraints
- Share relevant error messages
- Try rephrasing the question

**Model Runner Performance:**
- Ensure adequate system resources (4GB+ RAM)
- Update GPU drivers for acceleration
- Close resource-intensive applications
- Consider Docker Desktop resource allocation

## Future of Docker AI

**Upcoming Features (2025+):**
- Enhanced security vulnerability detection
- Automated compliance checking
- Integration with CI/CD pipelines
- Multi-container orchestration suggestions
- Kubernetes migration assistance
- Performance profiling and optimization

## Output

When using Docker AI, expect:
1. Context-aware recommendations
2. Tested commands for your platform
3. Explanations of why suggestions work
4. Security considerations
5. Performance implications
6. Alternative approaches when applicable

Docker AI represents the future of container development - intelligent, context-aware, and continuously learning. Use it to accelerate development while maintaining best practices.
