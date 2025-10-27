# Bash Master Plugin

Empower Claude with comprehensive bash scripting expertise across all platforms with **Bash 5.3 features** and **2025 security-first practices**. This plugin makes Claude a master of modern bash scripting, cloud-native automation, and production-ready DevOps patterns.

## 🎯 What This Plugin Does

When installed, Claude becomes an expert in:

### 2025 New Features
- **Bash 5.3 Features** - In-shell command substitution (${ }), REPLY variable syntax (${| }), enhanced read/source/compgen, GLOBSORT variable
- **Security-First Patterns** - Mandatory input validation (60%+ exploits from poor validation), injection prevention, path traversal protection
- **Container-Aware Scripting** - Docker/Kubernetes detection, health checks, PID 1 signal handling, minimal Alpine scripts
- **Cloud Provider Integration** - AWS/Azure helpers, secrets management (Secrets Manager/Key Vault), cloud-native patterns
- **Modern CI/CD** - GitHub Actions, Azure DevOps, GitLab CI integration, multi-platform detection
- **DevOps Automation** - Blue-green deployments, canary releases, parallel processing (GNU Parallel/job pools)

### Core Capabilities
- **Cross-platform bash scripting** - Linux, macOS, Windows (Git Bash/WSL), containers
- **Industry best practices** - Google Shell Style Guide (50-line scripts), ShellCheck mandatory validation
- **POSIX compliance** - Portable scripts that work everywhere
- **Performance optimization** - Bash 5.3 no-fork substitution (~40% faster), built-in optimizations
- **Testing** - Unit testing with BATS, integration testing, CI/CD integration
- **Error handling** - Robust error management (set -euo pipefail), exit codes, trap handlers

## 📦 Installation

### Via GitHub Marketplace (Recommended)

```bash
/plugin marketplace add JosiahSiegel/claude-code-marketplace
/plugin install bash-master@claude-code-marketplace
```

### Local Installation (Mac/Linux)

⚠️ **Windows users:** Use the GitHub marketplace method instead.

```bash
# Extract to plugins directory
unzip bash-master.zip -d ~/.local/share/claude/plugins/
```

## 🚀 Features

### Comprehensive Skill Knowledge

This plugin includes comprehensive bash-master skills that teach Claude:

1. **Bash 5.3 Features (2025)**
   - In-shell command substitution (${ command; })
   - REPLY variable substitution (${| command; })
   - Enhanced read builtin with -E option (readline support)
   - Enhanced source builtin with -p PATH option
   - compgen variable output option
   - GLOBSORT variable for sorting glob results
   - fltexpr loadable builtin for floating-point arithmetic
   - Performance improvements (~40% faster in benchmarks)

2. **Security-First Patterns (2025)**
   - Mandatory input validation (pattern matching, length checks)
   - Command injection prevention (no eval, array usage, -- separator)
   - Path traversal protection (sanitization, validation)
   - Secure temporary file handling (mktemp, proper permissions)
   - Secrets management (no hardcoding, cloud secret managers)
   - Privilege management (least privilege, root rejection)
   - Environment variable sanitization
   - Automated security scanning patterns

3. **Modern Automation Patterns (2025)**
   - Container-aware scripting (Docker/Kubernetes detection)
   - Health check patterns (quick probes, HTTP endpoints)
   - CI/CD platform helpers (GitHub Actions, Azure DevOps, GitLab)
   - Cloud provider integration (AWS, Azure helpers)
   - Parallel processing (GNU Parallel, job pools)
   - Deployment patterns (blue-green, canary)
   - Structured logging (JSON logs)

4. **ShellCheck CI/CD Integration (2025)**
   - Mandatory validation in pipelines
   - GitHub Actions integration patterns
   - Azure DevOps integration patterns
   - Git hook pre-commit validation
   - VS Code integration
   - Docker build validation

5. **Platform-Specific Expertise**
   - Linux-specific features (systemd, /proc, package managers)
   - macOS BSD vs GNU command differences
   - Git Bash limitations and workarounds
   - WSL1 vs WSL2 considerations
   - Container environments (Docker, Kubernetes)
   - Cross-platform compatibility patterns

6. **Best Practices & Standards**
   - Script structure templates (with 2025 standards)
   - Safety settings (set -euo pipefail)
   - Naming conventions and style guidelines
   - Function design patterns
   - Input validation
   - Documentation standards
   - Production-ready checklists

## 💡 Usage

Once installed, simply ask Claude to help with any bash scripting task:

### Examples

**Create a professional bash script:**
```
Create a bash script that backs up a directory to S3 with error handling,
logging, and proper cleanup
```

Claude will create a script following all 2025 best practices, with:
- Bash 5.3 features (if applicable)
- Proper shebang and safety settings
- Security-first input validation
- Error handling with trap
- Cross-platform compatibility
- ShellCheck compliance
- Comprehensive documentation

**Create container-aware script:**
```
Create a health check script for my Docker container
```

Claude will create:
- Container environment detection
- Quick health checks (< 1 second)
- Proper PID 1 signal handling
- HTTP endpoint validation
- File-based readiness checks

**Create CI/CD helper:**
```
Create a script that works in both GitHub Actions and Azure DevOps
```

Claude will implement:
- Multi-platform CI detection
- Universal output/error functions
- Platform-specific annotations
- Job summaries and logs

**Review existing scripts:**
```
Review this bash script for security issues and best practices
```

Claude will analyze using knowledge of:
- Security vulnerabilities (60%+ exploit patterns)
- Common anti-patterns
- Performance issues
- Platform compatibility problems
- ShellCheck warnings

## 🎓 What Claude Learns

### Script Safety (2025)
- Always use `set -euo pipefail`
- Safe IFS settings (`IFS=$'\n\t'`)
- Proper variable quoting
- Trap handlers for cleanup
- Error messages to stderr

### Security-First (2025)
- Mandatory input validation with regex
- Maximum length enforcement
- Command injection prevention (no eval, arrays, --)
- Path traversal protection
- Secure temporary files (mktemp + chmod 600)
- Secrets from secure storage (not hardcoded)
- Privilege management (no root unless necessary)

### Performance (2025)
- Bash 5.3 in-shell substitution (~40% faster)
- Avoiding unnecessary subshells
- Using bash built-ins
- Efficient loops
- Array operations
- Process substitution

### Container Awareness (2025)
- Detecting Docker/Kubernetes environments
- PID 1 signal handling
- Health check patterns
- Minimal Alpine scripts (/bin/sh)
- Container-specific paths

### Cloud Integration (2025)
- AWS helpers (Secrets Manager, S3, STS)
- Azure helpers (Key Vault, Blob Storage, Managed Identity)
- Cloud-native patterns
- Retry logic with backoff

### CI/CD Integration (2025)
- GitHub Actions outputs and annotations
- Azure DevOps logging and variables
- GitLab CI patterns
- Multi-platform detection
- Structured logging

### Testing
- Unit testing with BATS
- Integration testing patterns
- CI/CD integration
- ShellCheck validation
- Cross-platform testing

## 📚 Reference Materials

The plugin includes comprehensive reference documentation:

- **bash-53-features.md** - Complete Bash 5.3 feature guide with examples
- **security-first-2025.md** - Security-first patterns and mandatory validation
- **modern-automation-patterns.md** - Container, cloud, and CI/CD patterns
- **shellcheck-cicd-2025.md** - ShellCheck integration for 2025 workflows
- **platform_specifics.md** - Detailed platform differences and workarounds
- **best_practices.md** - Industry standards and comprehensive guidelines
- **patterns_antipatterns.md** - Common patterns and pitfalls with solutions
- **resources.md** - Authoritative sources and tools directory

## 🔍 Quality Assurance

Every script Claude creates with this plugin will:

- ✅ Pass ShellCheck with no warnings
- ✅ Include mandatory input validation (security-first)
- ✅ Include proper error handling (`set -euo pipefail`)
- ✅ Quote all variable expansions
- ✅ Use Bash 5.3 features where applicable (with fallbacks)
- ✅ Work across target platforms
- ✅ Follow industry standards (Google Shell Style Guide)
- ✅ Include appropriate documentation
- ✅ Handle edge cases properly
- ✅ Be secure, robust, and maintainable

## 🌐 Platform Support

- **Linux** - Full support, all features (Bash 5.3 on Ubuntu 24.04+)
- **macOS** - Full support with BSD compatibility notes (Bash 5.3 via Homebrew)
- **Windows (Git Bash)** - Comprehensive support with known limitations documented
- **Windows (WSL)** - Full Linux support with WSL-specific guidance
- **Containers** - Docker and Kubernetes-aware scripting (Alpine/Debian/Ubuntu)

## 🛠️ Tools & Standards

This plugin teaches Claude to use and recommend:

- **Bash 5.3** - Latest bash features (July 2025)
- **ShellCheck** - Static analysis for shell scripts (mandatory in 2025)
- **shfmt** - Shell script formatter
- **BATS** - Bash Automated Testing System
- **checkbashisms** - POSIX compliance checker
- **Google Shell Style Guide** - Industry-standard practices (50-line recommendation)
- **POSIX standards** - Portable scripting
- **Security scanners** - Custom security linting patterns

## 🤝 Contributing

This plugin is part of the claude-code-marketplace. Contributions welcome!

## 📄 License

MIT License - Feel free to use, modify, and distribute.

## 🔗 Resources

- [Bash 5.3 Release Notes](https://lists.gnu.org/archive/html/bash-announce/2025-07/msg00000.html)
- [Bash Manual](https://www.gnu.org/software/bash/manual/)
- [POSIX Shell Standard](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html)
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [ShellCheck](https://www.shellcheck.net/)
- [Bash Pitfalls](https://mywiki.wooledge.org/BashPitfalls)
- [Container Best Practices](https://cloud.google.com/architecture/best-practices-for-building-containers)

## 🎯 Next Steps

1. Install the plugin
2. Ask Claude to create or review a bash script
3. Watch Claude apply professional 2025 best practices automatically
4. Learn from Claude's comprehensive knowledge of modern bash scripting

---

**Made with ❤️ for the Claude Code community**

Empower your bash scripting with Bash 5.3 and 2025 security-first expertise!
