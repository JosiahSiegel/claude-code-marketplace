## Windows & Git Bash Compatibility

Azure Data Factory development frequently occurs on Windows with Git Bash (MINGW64). This plugin includes comprehensive guidance for handling path conversion issues common in this environment.

### Quick Fix for Git Bash Path Errors

If npm build commands fail with path errors on Git Bash:

```bash
# Add to your .bashrc or run before ADF commands
export MSYS_NO_PATHCONV=1

# Then run your npm commands
npm run build validate ./adf-resources /subscriptions/.../myFactory
```

### Cross-Platform Features

- **Shell Detection**: Automatic detection of Git Bash, PowerShell, WSL, macOS, Linux
- **Path Conversion Handling**: MSYS_NO_PATHCONV guidance for Git Bash users
- **Cross-Platform Scripts**: PowerShell Core (pwsh) examples work on all platforms
- **CI/CD Compatibility**: GitHub Actions and Azure DevOps patterns tested on multiple shells

### Resources

- **New Skill**: `windows-git-bash-compatibility` - Comprehensive Windows/Git Bash guidance
- **Commands Updated**: All CI/CD commands include shell detection patterns
- **Troubleshooting**: Git Bash-specific issues and solutions documented

---

### 3.3.0 (January 2025) **[WINDOWS/GIT BASH COMPATIBILITY UPDATE]**
- **🆕 NEW SKILL: windows-git-bash-compatibility**
  - Comprehensive Git Bash path conversion guidance for Windows developers
  - Shell detection patterns (Bash, PowerShell, Node.js)
  - MSYS_NO_PATHCONV usage and troubleshooting
  - Cross-platform CI/CD script examples
- **📝 ENHANCED CI/CD COMMANDS**
  - adf-cicd-setup: Added Git Bash path handling and shell detection
  - adf-arm-template: Cross-platform PowerShell script guidance
  - adf-troubleshoot: Windows Git Bash specific troubleshooting section
- **🔧 CI/CD IMPROVEMENTS**
  - Shell detection helpers for multi-platform teams
  - Node.js shell detection for npm scripts
  - Bash wrapper scripts for Git Bash compatibility
  - PowerShell Core (pwsh) cross-platform patterns
- **📚 COMPREHENSIVE DOCUMENTATION**
  - Windows developer workflow guidance
  - Git Bash (MINGW64) path conversion issues and solutions
  - WSL, PowerShell, and native shell compatibility
  - Local development script examples with shell detection
