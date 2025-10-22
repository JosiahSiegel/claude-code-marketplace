---
description: Generate a complete, ready-to-use Claude Code plugin with all necessary files and structure
---

# Generate Plugin

## Purpose
This command helps you quickly generate a complete Claude Code plugin, including all necessary files, directory structure, and downloadable ZIP packages. Perfect for both beginners creating their first plugin and experienced developers who want to accelerate plugin creation.

## Instructions

1. **Automatically read the plugin-creator skill** to understand the complete plugin creation process and best practices
2. **Gather requirements** from the user's request:
   - Infer the plugin's purpose and functionality
   - Determine components needed (commands, agents, skills)
   - Derive an appropriate name if not specified
3. **Be autonomous** - only ask clarifying questions if the request is genuinely ambiguous
4. **Create comprehensive output** including:
   - Complete directory structure
   - plugin.json manifest
   - All command, agent, and skill files
   - Comprehensive README.md
   - Installation instructions
5. **Package as ZIPs**:
   - Create plugin ZIP for direct use
   - Create marketplace ZIP for GitHub publishing
   - Move both to /mnt/user-data/outputs/
6. **Provide download links** and clear installation instructions

## Best Practices

- **Default to comprehensive**: Include commands, agents, and skills by default
- **Make it functional**: Create working examples, not placeholders
- **GitHub-first approach**: Recommend GitHub installation for cross-platform compatibility
- **Include examples**: Add usage examples in all documentation
- **Follow conventions**: Use kebab-case for names, clear descriptions

## Example Usage

```
/generate-plugin for managing Git workflows
/generate-plugin that helps with code reviews
/generate-plugin for deployment automation
```

## What Gets Created

1. **Full plugin directory** with proper structure
2. **plugin.json** with metadata
3. **Command files** in markdown format
4. **Agent files** with clear roles
5. **README.md** with installation guide
6. **Two ZIP files**:
   - `PLUGIN_NAME.zip` - Direct plugin installation
   - `PLUGIN_NAME-marketplace.zip` - GitHub-ready marketplace structure

## Output Format

After generation, provide:
- Download links to both ZIP files
- Installation instructions (GitHub method recommended)
- Quick start guide
- Platform-specific notes
