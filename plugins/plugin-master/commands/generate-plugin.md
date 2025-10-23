---
description: Generate a complete, ready-to-use Claude Code plugin with all necessary files and structure
---

# Generate Plugin

## Purpose
This command helps you quickly generate a complete Claude Code plugin, including all necessary files and directory structure. Perfect for both beginners creating their first plugin and experienced developers who want to accelerate plugin creation.

## Instructions

1. **Automatically read the plugin-master skill** to understand the complete plugin creation process and best practices
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
5. **Provide guidance** on:
   - GitHub marketplace publishing (recommended)
   - Local installation (Mac/Linux)
   - Optional: Skill export for claude.ai web app

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
5. **Skills** with SKILL.md files
6. **README.md** with installation guide
7. **Marketplace structure** for GitHub publishing

## Output Format

After generation, provide:
- Complete plugin file structure in your working directory
- Installation instructions (GitHub method recommended)
- Local installation guide (Mac/Linux)
- Quick start guide
- Platform-specific notes
- Optional: Skill export instructions for claude.ai web app
