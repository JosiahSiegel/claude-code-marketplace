---
description: Create a new Claude Code plugin with complete structure, commands, agents, skills, and marketplace-ready packaging
---

# Create Plugin Command

Create a comprehensive Claude Code plugin from scratch with all necessary components.

## Usage

This command helps you create a complete, production-ready plugin with:
- Plugin manifest (plugin.json)
- Custom slash commands
- Specialized agents
- Agent Skills (optional)
- Hook configurations (optional)
- MCP server integrations (optional)
- Complete documentation (README.md)
- GitHub-ready marketplace structure
- Optional: Export skills for claude.ai web app

## Process

When invoked, Claude will:

1. **Understand requirements** - Ask about plugin purpose, features, and components
2. **Fetch latest documentation** - Get current plugin specs from docs.claude.com
3. **Generate structure** - Create complete directory structure
4. **Create all files** - Generate plugin.json, commands, agents, README, etc.
5. **Provide instructions** - Give installation and publishing guidance
6. **Optional export** - Show how to export skills for claude.ai web if requested

## Examples

**Simple plugin:**
> /create-plugin for Git workflow automation

**Complex plugin:**
> /create-plugin with deployment commands, security agents, and monitoring tools

**From description:**
> /create-plugin that helps teams with code reviews, testing, and CI/CD

## Best Practices

- Be autonomous by default - infer requirements and create comprehensive output
- Always fetch latest docs before creating plugins
- Include all components by default (commands, agents, README)
- Provide GitHub-first installation instructions
- Include Windows compatibility notes
- Show skill export process if user requests claude.ai web usage

## Output

Claude will provide:
- Complete plugin file structure
- GitHub marketplace setup instructions
- Local installation instructions (Mac/Linux)
- Usage examples
- Optional: Skill export instructions for claude.ai web app

The plugin-master skill will automatically activate to guide the creation process with best practices and complete templates.
