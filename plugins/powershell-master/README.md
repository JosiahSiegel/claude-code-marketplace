# PowerShell Master Plugin

Complete PowerShell expertise across all platforms (Windows, Linux, macOS) for scripting, automation, CI/CD, and cloud management.

## 🎯 What This Plugin Does

This plugin makes Claude a PowerShell expert with knowledge of:

- **Cross-Platform PowerShell** - Windows, Linux, macOS compatibility
- **PowerShell 7+** - Latest features, performance, parallel execution
- **Module Management** - PSGallery discovery, installation, updates
- **Popular Modules** - Az, Microsoft.Graph, PnP, AWS Tools, Pester
- **CI/CD Integration** - GitHub Actions, Azure DevOps, Bitbucket Pipelines
- **Cloud Automation** - Azure, AWS, Microsoft 365 management
- **Best Practices** - Security, performance, code quality
- **Script Development** - Functions, error handling, testing

## 📦 Installation

### Via GitHub Marketplace (Recommended)

```bash
/plugin marketplace add JosiahSiegel/claude-code-marketplace
/plugin install powershell-master@claude-code-marketplace
```

### Local Installation (Mac/Linux)

⚠️ **Windows users:** Use the GitHub marketplace method instead.

```bash
# Extract to plugins directory
unzip powershell-master.zip -d ~/.local/share/claude/plugins/
```

## 🚀 Features

### Comprehensive PowerShell Knowledge

This plugin includes expert knowledge of:

1. **PowerShell Syntax & Cmdlets**
   - Full cmdlet reference
   - Operators and control flow
   - Functions and pipelines
   - Error handling patterns

2. **Cross-Platform Best Practices**
   - Path handling across OS
   - Platform detection
   - Text encoding (UTF-8)
   - Case sensitivity awareness

3. **Module Ecosystem**
   - **Azure (Az):** Complete Azure resource management
   - **Microsoft.Graph:** Microsoft 365, Teams, SharePoint
   - **PnP.PowerShell:** SharePoint Online automation
   - **AWS.Tools:** AWS resource management
   - **Pester:** Testing framework
   - **PSScriptAnalyzer:** Code quality analysis

4. **CI/CD Integration**
   - GitHub Actions workflows
   - Azure DevOps Pipelines
   - Bitbucket Pipelines
   - Cross-platform testing
   - Artifact publishing

5. **Security & Performance**
   - Credential management
   - Input validation
   - Performance optimization
   - Parallel execution (PS 7+)
   - Code signing

## 📋 Available Commands

### `/pwsh-script`
Create or review PowerShell scripts with best practices, error handling, and cross-platform compatibility.

**Example:**
```
/pwsh-script to backup files with retention policy
```

### `/pwsh-module`
Find, install, and manage PowerShell modules from PSGallery or other sources.

**Example:**
```
/pwsh-module to work with Azure VMs
```

### `/pwsh-cicd`
Set up PowerShell in CI/CD pipelines (GitHub Actions, Azure DevOps, Bitbucket).

**Example:**
```
/pwsh-cicd for cross-platform testing
```

### `/pwsh-azure`
Automate Azure resources using the Az PowerShell module.

**Example:**
```
/pwsh-azure to deploy virtual machines
```

## 🤖 PowerShell Expert Agent

The plugin includes a specialized **powershell-expert** agent with comprehensive PowerShell knowledge.

**Automatically activates for:**
- Any PowerShell script creation or review
- Module discovery and management
- CI/CD pipeline setup
- Cloud automation (Azure/AWS/M365)
- Script debugging and optimization

**Invoke explicitly via Task tool:**
```
Use powershell-expert agent to create Azure automation script
```

## 💡 Usage Examples

### Example 1: Create Cross-Platform Script

**Request:** "Create a script to find large files"

**Result:** Production-ready script with:
- Cross-platform path handling
- Parameter validation
- Error handling
- Comment-based help
- Performance optimization

### Example 2: Azure Automation

**Request:** "Show me how to manage Azure VMs with PowerShell"

**Result:** Complete guide including:
- Az module installation
- Authentication methods
- VM operations (start/stop/create)
- Service principal setup for automation
- CI/CD integration examples

### Example 3: CI/CD Setup

**Request:** "Set up PowerShell testing in GitHub Actions"

**Result:** Full workflow with:
- Multi-platform matrix
- Pester test execution
- PSScriptAnalyzer code quality checks
- Test result publishing
- Module caching for speed

### Example 4: Module Discovery

**Request:** "I need to work with Microsoft Teams"

**Result:**
- Relevant modules identified (Microsoft.Graph)
- Installation instructions
- Common operations examples
- Authentication guidance
- Best practices for automation

## 🌐 Platform Support

- ✅ **Windows:** PowerShell 7+ and Windows PowerShell 5.1
- ✅ **Linux:** PowerShell 7+ (Ubuntu, RHEL, Debian, Alpine)
- ✅ **macOS:** PowerShell 7+ (Intel and Apple Silicon)

All examples and scripts are tested for cross-platform compatibility.

## 🔧 Common Use Cases

### Script Development
- Creating new PowerShell scripts
- Converting Windows PowerShell to PowerShell 7+
- Adding error handling and logging
- Performance optimization
- Code review and refactoring

### Module Management
- Finding modules on PSGallery
- Installing and updating modules
- Resolving version conflicts
- Creating custom modules
- Offline module installation

### Cloud Automation
- Azure resource deployment and management
- AWS infrastructure automation
- Microsoft 365 administration
- Multi-cloud orchestration
- Cost management and reporting

### CI/CD
- GitHub Actions workflows
- Azure DevOps Pipelines
- Bitbucket Pipelines
- Cross-platform testing
- Automated deployments

### DevOps
- Infrastructure as Code
- Configuration management
- Log analysis and monitoring
- Backup and recovery automation
- Security compliance checks

## 📚 Knowledge Base

The plugin includes comprehensive documentation on:

- PowerShell 7+ features and syntax
- 50+ popular PowerShell modules
- CI/CD integration patterns
- Azure, AWS, and M365 automation
- Security best practices
- Performance optimization techniques
- Cross-platform compatibility
- Testing with Pester
- Code quality with PSScriptAnalyzer

## 🎓 Learning Resources

Claude will guide you through:
- PowerShell fundamentals
- Advanced scripting techniques
- Module development
- CI/CD best practices
- Cloud automation patterns
- Security considerations
- Performance tuning

And always refers to:
- Latest PowerShell documentation
- Module-specific documentation
- Platform-specific guides
- Community best practices

## ⚡ Quick Start

After installation, just ask Claude:

```
"Create a PowerShell script to..."
"How do I install the Az module?"
"Set up PowerShell in GitHub Actions"
"Automate Azure resource deployment"
"Find modules for Microsoft Teams"
```

The plugin will automatically activate and provide expert guidance with working examples.

## 🔍 Technical Details

**Plugin Name:** powershell-master
**Version:** 1.0.2
**Author:** Josiah Siegel
**License:** MIT

**Components:**
- 1 comprehensive skill (powershell-master)
- 4 specialized commands
- 1 expert agent

**Supported PowerShell Versions:**
- PowerShell 7.0+  (Recommended)
- Windows PowerShell 5.1 (Legacy support)

## 🤝 Contributing

Contributions welcome! Areas for improvement:
- Additional command examples
- More module coverage
- Platform-specific optimizations
- CI/CD platform additions
- Best practice updates

## 🆘 Support

For help:
- Check the comprehensive skill documentation
- Review [official PowerShell docs](https://learn.microsoft.com/powershell)
- Visit [PowerShell Gallery](https://www.powershellgallery.com)
- Explore [PSGallery modules](https://www.powershellgallery.com/packages)

## 📄 License

MIT License - free to use, modify, and distribute.

## 🎓 Credits

Created by Josiah Siegel. Built on PowerShell best practices and community knowledge.

---

**Start automating with PowerShell today!** Install this plugin and unleash the power of cross-platform PowerShell scripting, automation, and cloud management.
