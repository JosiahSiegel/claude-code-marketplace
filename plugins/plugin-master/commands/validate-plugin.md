---
description: Comprehensive validation of plugin structure, manifests, and configuration against 2025 standards
---

# Validate Plugin

Systematically validate plugin files against current Claude Code requirements and best practices.

## Purpose

Pre-publishing validation that checks plugin.json schema, directory structure, component files, and marketplace compatibility. Identifies errors, warnings, and optimization opportunities.

## Instructions

1. **Locate plugin** - Use current directory or specified path
2. **Validate plugin.json** (2025 standards):
   - Required field: `name`
   - Schema validation: `author` as object, `version` as string, `keywords` as array
   - Recommended fields: description, license, homepage, repository
   - Check paths use ${CLAUDE_PLUGIN_ROOT} for portability
   - Verify MCP servers use proper configuration format
3. **Check directory structure**:
   - `.claude-plugin/` contains plugin.json (and optionally .mcp.json)
   - Component directories (commands/, agents/, skills/) at plugin root
   - Files properly named (kebab-case, .md extensions)
   - Hook configuration (hooks/hooks.json or inline in plugin.json)
4. **Validate components** (2025 features):
   - Commands have frontmatter with description
   - Agents have proper frontmatter with capabilities
   - Agent Skills have SKILL.md with name and description
   - Hooks have valid event types (PreToolUse, PostToolUse, SessionStart, etc.)
   - MCP servers reference valid commands and args
5. **Check 2025 best practices**:
   - Use of Agent Skills for dynamic knowledge loading
   - Hooks configured for automated workflows
   - Environment variables properly used (${CLAUDE_PLUGIN_ROOT})
   - Repository-level configuration support (.claude/settings.json template)
6. **Check marketplace.json** if present:
   - Validate owner structure
   - Check plugin entries have required fields
   - Verify source paths are correct (relative paths start with ./)
   - Confirm descriptions and keywords are synchronized
7. **Report findings** with severity levels and actionable fixes

## Validation Checklist

**Critical (Must Fix):**
- plugin.json exists and has valid JSON
- name field present
- author is object not string
- version is string not number
- keywords is array not string

**Warnings (Should Fix):**
- Missing recommended fields (description, license)
- Inconsistent naming conventions
- Missing frontmatter in components

**Suggestions (Nice to Have):**
- Add homepage and repository URLs
- Expand keywords for better discovery
- Add examples to README

## Example Usage

```
/validate-plugin
/validate-plugin in plugins/my-plugin
/validate-plugin before publishing
```

Returns structured validation report with pass/fail status.
