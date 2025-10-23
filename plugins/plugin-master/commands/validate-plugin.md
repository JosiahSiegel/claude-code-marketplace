---
description: Validate Claude Code plugin structure, manifests, and configuration files
---

# Validate Plugin Command

Validate the structure and configuration of a Claude Code plugin to ensure it meets all requirements.

## Usage

Check plugin files for:
- Valid plugin.json structure
- Required fields and proper formatting
- Correct directory structure
- Command file format
- Agent configuration
- Hook definitions
- MCP server configs
- Marketplace compatibility

## Process

Claude will:

1. **Check manifest** - Validate plugin.json syntax and required fields
2. **Verify structure** - Ensure proper directory layout
3. **Test components** - Check commands, agents, hooks, MCP configs
4. **Marketplace check** - Validate marketplace.json if present
5. **Report issues** - Provide actionable feedback on problems
6. **Suggest fixes** - Recommend corrections for any issues found

## Examples

**Validate local plugin:**
> /validate-plugin in current directory

**Check specific plugin:**
> /validate-plugin for my-awesome-plugin

**Pre-publish check:**
> /validate-plugin before publishing to marketplace

## What Gets Checked

- **Required files:** `.claude-plugin/plugin.json` exists
- **JSON syntax:** All JSON files are valid
- **Required fields:** name, version, description present
- **Directory structure:** Correct placement of components
- **Command format:** Markdown files with proper frontmatter
- **Agent format:** Valid agent definitions
- **Paths:** Relative paths start with `./`
- **Environment vars:** Proper use of `${CLAUDE_PLUGIN_ROOT}`

## Output

Validation results showing:
- ✅ What's correct
- ⚠️ Warnings (optional improvements)
- ❌ Errors (must fix before publishing)
- 💡 Suggestions for enhancement
