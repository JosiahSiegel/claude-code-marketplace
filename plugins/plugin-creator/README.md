# Plugin Creator

> **Comprehensive plugin development skill for Claude Code**

Give Claude the ability to autonomously create, test, and publish Claude Code plugins with complete structures, following best practices and official documentation.

## 🎯 What This Plugin Does

This plugin teaches Claude how to create plugins by providing:

- **Autonomous plugin generation** - Creates complete structures with sensible defaults
- **Latest documentation fetching** - Always uses current Claude Code specifications
- **ZIP packaging** - Outputs downloadable plugin and marketplace ZIPs
- **Best practices** - Applies proven patterns automatically
- **All component types** - Supports commands, agents, skills, hooks, MCP servers
- **GitHub-ready outputs** - Marketplace structures ready for publishing

## 📦 Installation

### From Marketplace (Recommended)

```bash
# Add the marketplace
/plugin marketplace add JosiahSiegel/claude-code-marketplace

# Install this plugin
/plugin install plugin-creator@JosiahSiegel
```

### Local Installation (Mac/Linux)

```bash
# Clone or download this repository
git clone https://github.com/JosiahSiegel/claude-code-marketplace.git

# Extract just the plugin
cd claude-code-marketplace/plugins
cp -r plugin-creator ~/.local/share/claude/plugins/

# Restart Claude Code
```

**Note for Windows users:** Use the marketplace installation method for best results.

## 🚀 Usage

Once installed, Claude automatically recognizes plugin creation requests:

### Basic Examples

**Create a Git workflow plugin:**
```
"Create a plugin for Git workflows"
```
→ Claude generates complete Git plugin with PR, commit, and branch commands

**Create a deployment plugin:**
```
"Make a deployment automation plugin"
```
→ Claude builds deployment plugin with staging, production, and rollback commands

**Create a code review plugin:**
```
"Build a code review plugin with security focus"
```
→ Claude creates plugin with review commands and security-focused agents

### Advanced Examples

**API integration plugin:**
```
"Create a plugin that integrates with our Stripe API"
```
→ Claude generates plugin with API commands, skills, and MCP server configuration

**Package an existing skill:**
```
"Package this skill as a plugin for my team"
```
→ Claude converts any skill document into a distributable plugin

## 🎁 What You Get

Every plugin Claude creates includes:

### Plugin Files
- ✅ `plugin.json` - Properly configured manifest
- ✅ Commands - Working slash commands in markdown
- ✅ Agents - Specialized subagents when appropriate
- ✅ Skills - Knowledge documents when useful
- ✅ `README.md` - Complete documentation

### Packages
- ✅ **Plugin ZIP** - Ready for local installation
- ✅ **Marketplace ZIP** - Ready for GitHub publishing
- ✅ Download links - Direct access to both ZIPs

### Documentation
- ✅ Installation instructions (GitHub + local)
- ✅ Usage examples
- ✅ Platform compatibility notes
- ✅ Publishing guidelines

## 📋 Available Commands

### `/plugin-creator:create-plugin`
Create a comprehensive Claude Code plugin from scratch with all necessary components.

**Example:**
```
/plugin-creator:create-plugin for Git workflow automation
```

### `/plugin-creator:generate-plugin`
Generate a complete, ready-to-use Claude Code plugin with all necessary files and structure.

**Example:**
```
/plugin-creator:generate-plugin
```

### `/plugin-creator:plugin-guide`
Get comprehensive guidance on creating Claude Code plugins, from basics to advanced topics.

**Example:**
```
/plugin-creator:plugin-guide
```

### `/plugin-creator:publish-plugin`
Prepare and publish Claude Code plugins to GitHub marketplaces with complete documentation.

**Example:**
```
/plugin-creator:publish-plugin
```

### `/plugin-creator:validate-plugin`
Validate Claude Code plugin structure, manifests, and configuration files.

**Example:**
```
/plugin-creator:validate-plugin
```

## 🤖 Available Agents

### plugin-architect
Expert in Claude Code plugin architecture, design patterns, and best practices. Specializes in creating production-ready plugins.

**Invoke via Task tool:**
```
Task: plugin-architect agent for design review
```

**Capabilities:**
- Plugin architecture design
- Component selection and organization
- Best practices implementation
- Performance optimization
- Cross-platform compatibility
- Marketplace publishing strategy

## 🧠 Included Skills

### plugin-creator
Comprehensive beginner's guide providing step-by-step guidance for creating Claude Code plugins.

**Covers:**
- What Claude Code plugins are
- Your first plugin in 10 minutes
- Creating plugin structures
- Publishing to marketplaces
- Testing workflows
- Best practices
- Troubleshooting

This skill is automatically available when the plugin is installed.

## 🔧 Plugin Creation Workflow

When you ask Claude to create a plugin, it follows this process:

1. **Fetch Documentation** - Gets latest plugin specs from official docs
2. **Infer Requirements** - Determines components needed from your request
3. **Create Structure** - Builds complete directory hierarchy
4. **Generate Files** - Creates plugin.json, commands, agents, skills, README
5. **Package ZIPs** - Outputs plugin.zip and marketplace.zip
6. **Provide Instructions** - Gives installation and publishing guidance

## 🎯 Use Cases

### For Individual Developers
- **Rapid prototyping** - Test plugin ideas quickly
- **Learning** - See working examples of plugin structures
- **Templates** - Generate baseline plugins to customize

### For Teams
- **Standardization** - Ensure consistent plugin structures
- **Knowledge sharing** - Package team expertise as plugins
- **Workflow automation** - Create custom commands for common tasks

### For Organizations
- **Internal tools** - Package proprietary workflows
- **Best practices** - Enforce standards through plugins
- **Onboarding** - Create plugins for new team members

## 🌐 Platform Notes

- ✅ **Windows:** Marketplace installation recommended (local paths may have issues)
- ✅ **macOS:** All installation methods work
- ✅ **Linux:** All installation methods work

## 📚 Documentation

This plugin includes comprehensive documentation:

- **Beginner's guide** - Learn plugin development from scratch
- **Step-by-step tutorials** - Create your first plugin in 10 minutes
- **Component guides** - Commands, agents, skills, hooks, MCP servers
- **Publishing guide** - Get your plugin on GitHub
- **Best practices** - Security, naming, structure conventions
- **Troubleshooting** - Common issues and solutions

## 🔍 Technical Details

**Plugin Name:** plugin-creator
**Version:** 1.0.1
**Author:** Josiah Siegel
**License:** MIT
**Repository:** https://github.com/JosiahSiegel/claude-code-marketplace

**Components:**
- 5 slash commands
- 1 specialized agent
- 1 comprehensive skill

## 🤝 Contributing

Contributions welcome! Areas for improvement:

- Additional plugin templates
- More examples
- Platform-specific optimizations
- Documentation enhancements
- New commands or agents

## 🆘 Support

For help:
- Check the included comprehensive guide
- Review [official Claude Code docs](https://docs.claude.com/en/docs/claude-code/plugins)
- Join Claude Developers Discord
- File [issues on GitHub](https://github.com/JosiahSiegel/claude-code-marketplace/issues)

## 📄 License

MIT License - free to use, modify, and distribute.

## 🎓 Credits

Created by Josiah Siegel. Built on the Claude Skills system and Claude Code plugin framework by Anthropic.

---

**Start creating plugins today!** Install this plugin and ask Claude to build something amazing.
