# Bash Mastery Plugin

Empower Claude with comprehensive bash scripting expertise across all platforms. This plugin makes Claude a master of bash scripting best practices, industry standards, cross-platform compatibility, security, and performance optimization.

## 🎯 What This Plugin Does

When installed, Claude becomes an expert in:

- **Cross-platform bash scripting** - Linux, macOS, Windows (Git Bash/WSL), containers
- **Industry best practices** - Google Shell Style Guide, ShellCheck compliance
- **POSIX compliance** - Portable scripts that work everywhere
- **Security** - Input validation, command injection prevention, privilege management
- **Performance** - Optimization techniques, profiling, avoiding common bottlenecks
- **Testing** - Unit testing with BATS, integration testing, CI/CD integration
- **Debugging** - Advanced debugging techniques, logging, troubleshooting
- **Error handling** - Robust error management, exit codes, trap handlers

## 📦 Installation

### Via GitHub Marketplace (Recommended)

```bash
/plugin marketplace add YOUR_USERNAME/claude-code-marketplace
/plugin install bash-mastery@YOUR_USERNAME
```

### Local Installation (Mac/Linux)

⚠️ **Windows users:** Use the GitHub marketplace method instead.

```bash
# Extract to plugins directory
unzip bash-mastery.zip -d ~/.local/share/claude/plugins/
```

## 🚀 Features

### Comprehensive Skill Knowledge

This plugin includes a comprehensive **bash-mastery** skill that teaches Claude:

1. **Platform-Specific Expertise**
   - Linux-specific features (systemd, /proc, package managers)
   - macOS BSD vs GNU command differences
   - Git Bash limitations and workarounds
   - WSL1 vs WSL2 considerations
   - Container environments (Docker, Kubernetes)
   - Cross-platform compatibility patterns

2. **Best Practices & Standards**
   - Script structure templates
   - Safety settings (`set -euo pipefail`)
   - Naming conventions and style guidelines
   - Function design patterns
   - Input validation
   - Documentation standards
   - Production-ready checklists

3. **Common Patterns & Anti-Patterns**
   - Variable handling (quoting, defaults, expansion)
   - Command execution best practices
   - File operations (safe reading, null-delimited files)
   - String processing with parameter expansion
   - Arrays and loops
   - Conditionals and tests
   - Error handling patterns
   - Process management
   - Security patterns

4. **Authoritative Resources**
   - Official documentation (Bash Manual, POSIX standards)
   - Style guides (Google, community standards)
   - Tools (ShellCheck, shfmt, BATS, checkbashisms)
   - Learning resources and tutorials
   - Community resources
   - Books and references
   - Testing frameworks

## 💡 Usage

Once installed, simply ask Claude to help with any bash scripting task:

### Examples

**Create a professional bash script:**
```
Create a bash script that backs up a directory to S3 with error handling,
logging, and proper cleanup
```

Claude will create a script following all best practices, with:
- Proper shebang and safety settings
- Input validation
- Error handling with trap
- Cross-platform compatibility
- ShellCheck compliance
- Comprehensive documentation

**Review existing scripts:**
```
Review this bash script for security issues and best practices
```

Claude will analyze using knowledge of:
- Security vulnerabilities
- Common anti-patterns
- Performance issues
- Platform compatibility problems
- ShellCheck warnings

**Debug platform-specific issues:**
```
This script works on Linux but fails on macOS, can you fix it?
```

Claude will identify and fix:
- GNU vs BSD command differences
- Platform-specific features
- Path handling issues
- Command availability

**Write portable scripts:**
```
Create a POSIX-compliant script that works on any UNIX system
```

Claude will ensure:
- POSIX compliance (no bashisms)
- Portable command usage
- Safe fallbacks
- Cross-platform testing

## 🎓 What Claude Learns

### Script Safety
- Always use `set -euo pipefail`
- Safe IFS settings (`IFS=$'\n\t'`)
- Proper variable quoting
- Trap handlers for cleanup
- Error messages to stderr

### Security
- Input validation patterns
- Command injection prevention
- Path traversal protection
- Privilege management
- Secrets handling
- Secure temporary files

### Performance
- Avoiding unnecessary subshells
- Using bash built-ins
- Efficient loops
- Array operations
- Process substitution

### Testing
- Unit testing with BATS
- Integration testing patterns
- CI/CD integration
- ShellCheck validation
- Cross-platform testing

### Platform Compatibility
- Detecting OS and environment
- GNU vs BSD command differences
- Git Bash limitations
- WSL considerations
- Container-aware scripting

## 📚 Reference Materials

The plugin includes comprehensive reference documentation:

- **platform_specifics.md** - Detailed platform differences and workarounds
- **best_practices.md** - Industry standards and comprehensive guidelines
- **patterns_antipatterns.md** - Common patterns and pitfalls with solutions
- **resources.md** - Authoritative sources and tools directory

## 🔍 Quality Assurance

Every script Claude creates with this plugin will:

- ✅ Pass ShellCheck with no warnings
- ✅ Include proper error handling (`set -euo pipefail`)
- ✅ Quote all variable expansions
- ✅ Work across target platforms
- ✅ Follow industry standards (Google Shell Style Guide)
- ✅ Include appropriate documentation
- ✅ Handle edge cases properly
- ✅ Be secure, robust, and maintainable

## 🌐 Platform Support

- **Linux** - Full support, all features
- **macOS** - Full support with BSD compatibility notes
- **Windows (Git Bash)** - Comprehensive support with known limitations documented
- **Windows (WSL)** - Full Linux support with WSL-specific guidance
- **Containers** - Docker and Kubernetes-aware scripting

## 📖 Example Output

When you ask Claude to create a bash script, you'll get professional-grade code like:

```bash
#!/usr/bin/env bash
#
# Script Name: backup.sh
# Description: Backup directory to S3 with error handling
# Author: Claude (with bash-mastery plugin)
# Version: 1.0.0

set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

# Cleanup on exit
cleanup() {
    local exit_code=$?
    [[ -n "${TEMP_DIR:-}" ]] && rm -rf "$TEMP_DIR"
    exit "$exit_code"
}
trap cleanup EXIT

# ... (complete, professional implementation)
```

## 🛠️ Tools & Standards

This plugin teaches Claude to use and recommend:

- **ShellCheck** - Static analysis for shell scripts
- **shfmt** - Shell script formatter
- **BATS** - Bash Automated Testing System
- **checkbashisms** - POSIX compliance checker
- **Google Shell Style Guide** - Industry-standard practices
- **POSIX standards** - Portable scripting

## 🤝 Contributing

This plugin is part of the claude-code-marketplace. Contributions welcome!

## 📄 License

MIT License - Feel free to use, modify, and distribute.

## 🔗 Resources

- [Bash Manual](https://www.gnu.org/software/bash/manual/)
- [POSIX Shell Standard](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html)
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [ShellCheck](https://www.shellcheck.net/)
- [Bash Pitfalls](https://mywiki.wooledge.org/BashPitfalls)

## 🎯 Next Steps

1. Install the plugin
2. Ask Claude to create or review a bash script
3. Watch Claude apply professional best practices automatically
4. Learn from Claude's comprehensive knowledge of bash scripting

---

**Made with ❤️ for the Claude Code community**

Empower your bash scripting with industry expertise!
