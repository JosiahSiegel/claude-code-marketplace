# Docker Master Plugin

Master Docker across Windows, Linux, and macOS with expert knowledge of best practices, security, optimization, and industry standards.

## Overview

The Docker Master plugin equips Claude Code with comprehensive Docker expertise, enabling you to build, run, optimize, secure, and debug containers following current industry standards across all platforms.

## Features

### Commands

- **`/docker-build`** - Build Docker images following current best practices and industry standards
- **`/docker-run`** - Run Docker containers with proper configuration and best practices
- **`/docker-compose`** - Manage multi-container applications with Docker Compose using best practices
- **`/docker-optimize`** - Optimize Docker images for size, build time, and runtime performance
- **`/docker-security`** - Scan and harden Docker containers following security best practices
- **`/docker-debug`** - Debug Docker containers and troubleshoot common issues across all platforms
- **`/docker-cleanup`** - Clean up Docker resources safely and efficiently across all platforms

### Agents

- **Docker Expert Agent** - A comprehensive Docker expert with knowledge of:
  - Container architecture and internals
  - Cross-platform mastery (Windows, Linux, macOS)
  - Security hardening and compliance
  - Performance optimization
  - Current best practices and industry standards
  - Systematic troubleshooting
  - Production operations

### Skills

- **docker-best-practices** - Comprehensive Docker best practices for images, containers, and production deployments
- **docker-security-guide** - Complete security guidelines and threat mitigation strategies
- **docker-platform-guide** - Platform-specific considerations for Windows, Linux, and macOS

## Installation

### Via Marketplace

```bash
/plugin marketplace add YOUR_USERNAME/claude-code-marketplace
/plugin install docker-master@YOUR_USERNAME
```

## Usage

### Building Optimized Images

```bash
/docker-build
```

Claude will:
1. Check latest Docker best practices
2. Analyze your current Dockerfile
3. Detect target platform (Windows/Linux/macOS)
4. Apply security and optimization best practices
5. Provide build commands with recommended flags
6. Validate the result

### Running Containers Securely

```bash
/docker-run
```

Claude will:
1. Research latest security recommendations
2. Configure proper resource limits
3. Set up network isolation
4. Apply security hardening
5. Implement health checks
6. Provide complete run command

### Managing Multi-Container Apps

```bash
/docker-compose
```

Claude will:
1. Review or create docker-compose.yml
2. Apply current best practices
3. Configure security, networking, and resources
4. Provide platform-specific optimizations

### Optimizing for Performance

```bash
/docker-optimize
```

Claude will:
1. Analyze current image size and layers
2. Implement multi-stage builds
3. Optimize layer caching
4. Reduce image size
5. Improve build performance
6. Provide before/after comparison

### Security Scanning & Hardening

```bash
/docker-security
```

Claude will:
1. Scan for vulnerabilities (CVEs)
2. Check against CIS benchmarks
3. Harden Dockerfile and runtime config
4. Implement secrets management
5. Apply principle of least privilege
6. Provide security audit report

### Debugging Issues

```bash
/docker-debug
```

Claude will:
1. Systematically diagnose the issue
2. Provide platform-specific solutions
3. Show debugging commands
4. Explain root cause
5. Suggest prevention strategies

### Cleaning Up Resources

```bash
/docker-cleanup
```

Claude will:
1. Assess current disk usage
2. Provide safe cleanup commands
3. Warn about data loss risks
4. Show platform-specific cleanup methods
5. Verify space reclaimed

## Expert Consultation

For complex Docker questions or architectural guidance:

```bash
/agent docker-expert
```

The Docker Expert agent can help with:
- Dockerfile reviews and optimization
- Security hardening strategies
- Architecture design for multi-container apps
- CI/CD integration
- Production deployment planning
- Performance troubleshooting
- Platform-specific challenges

## Platform Support

### Linux ✅
- Full native Docker support
- Best performance
- All features available
- SELinux/AppArmor integration
- Production-ready configurations

### macOS ✅
- Docker Desktop support
- Apple Silicon (M1/M2/M3) optimization
- File sharing performance tips
- Development workflow optimization
- Multi-platform build support

### Windows ✅
- Docker Desktop support
- WSL2 and Hyper-V backends
- Path format handling
- Windows containers support
- Cross-platform compatibility

## Key Principles

This plugin ensures Claude always:

1. **Checks Latest Standards** - Searches for current best practices before making recommendations
2. **Platform-Aware** - Provides platform-specific guidance for Windows, Linux, and macOS
3. **Security-First** - Prioritizes security in all recommendations
4. **Explains Why** - Teaches principles, not just commands
5. **Production-Ready** - Provides configurations suitable for production use
6. **Comprehensive** - Covers full Docker lifecycle from build to deployment

## Best Practices Applied

### Images
- Official, minimal base images with exact version tags
- Multi-stage builds for smaller, more secure images
- Efficient layer caching for faster builds
- Comprehensive .dockerignore files
- Vulnerability scanning before deployment

### Security
- Non-root users
- Dropped capabilities
- Read-only filesystems where possible
- Secrets management (no hardcoded secrets)
- Regular vulnerability scanning
- CIS Docker Benchmark compliance

### Performance
- Optimized layer ordering
- BuildKit features for faster builds
- Resource limits and health checks
- Proper logging configuration
- Multi-platform builds when needed

### Production Operations
- Health checks and monitoring
- Proper restart policies
- Network isolation
- Backup strategies
- Update and rollback procedures

## Examples

### Example: Secure Production Deployment

```bash
# 1. Build optimized image
/docker-build

# 2. Scan for security issues
/docker-security

# 3. Create production-ready compose file
/docker-compose

# Result: Secure, optimized, production-ready configuration
```

### Example: Debug Container Issue

```bash
# Container won't start
/docker-debug

# Claude will:
# - Check logs and exit code
# - Test configuration
# - Identify root cause
# - Provide platform-specific fix
# - Show verification commands
```

### Example: Optimize Existing Project

```bash
# 1. Optimize Dockerfile
/docker-optimize

# 2. Improve security
/docker-security

# 3. Clean up old resources
/docker-cleanup

# Result: Smaller, faster, more secure images
```

## Requirements

- Docker Engine 20.10+ (for latest features)
- Docker Compose 2.0+ (for compose commands)
- Platform-specific:
  - **Linux:** Docker CE/EE installed
  - **macOS:** Docker Desktop for Mac
  - **Windows:** Docker Desktop for Windows with WSL2 (recommended)

## Recommended Tools

This plugin references these tools (install as needed):
- **Docker Scout** - Built-in CVE scanning
- **Trivy** - Comprehensive security scanner
- **Dive** - Image layer analyzer
- **docker-bench-security** - CIS compliance checker

## Learning Resources

The plugin provides links to:
- Official Docker documentation
- CIS Docker Benchmark
- OWASP Docker Security Cheat Sheet
- Platform-specific guides
- Security best practices

## Contributing

Found an outdated best practice or want to add a new command? This plugin encourages continuous improvement to stay current with Docker's evolution.

## License

MIT

## Support

For issues or questions:
- Check command outputs for detailed guidance
- Use `/agent docker-expert` for complex questions
- Refer to official Docker documentation
- Check platform-specific sections in skills

---

**Master Docker across all platforms with confidence.** This plugin ensures you follow current best practices, maintain security, optimize performance, and handle platform-specific challenges effectively.
