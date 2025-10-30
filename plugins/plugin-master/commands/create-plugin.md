---
description: Create a comprehensive Claude Code plugin with all necessary components and marketplace structure
---

## 🚨 CRITICAL GUIDELINES

### Windows File Path Requirements

**MANDATORY: Always Use Backslashes on Windows for File Paths**

When using Edit or Write tools on Windows, you MUST use backslashes (`\`) in file paths, NOT forward slashes (`/`).

**Examples:**
- ❌ WRONG: `D:/repos/project/file.tsx`
- ✅ CORRECT: `D:\repos\project\file.tsx`

This applies to:
- Edit tool file_path parameter
- Write tool file_path parameter
- All file operations on Windows systems


### Documentation Guidelines

**NEVER create new documentation files unless explicitly requested by the user.**

- **Priority**: Update existing README.md files rather than creating new documentation
- **Repository cleanliness**: Keep repository root clean - only README.md unless user requests otherwise
- **Style**: Documentation should be concise, direct, and professional - avoid AI-generated tone
- **User preference**: Only create additional .md files when user specifically asks for documentation


---

# Create Plugin

Autonomously create production-ready Claude Code plugins with complete structure, documentation, and marketplace packaging.

## Purpose

Guides Claude through the complete plugin creation workflow: fetching latest docs, generating all files (plugin.json, commands, agents, skills, README), creating marketplace structure, and providing installation instructions.

## Instructions

1. **Fetch latest documentation** from docs.claude.com (plugins-reference, plugin-marketplaces)
2. **Detect repository context** - Check git config for author info and marketplace.json existence
3. **Infer requirements** from user request - Only ask questions if genuinely ambiguous
4. **Create comprehensive structure**:
   - Plugin manifest with all appropriate metadata fields
   - Commands, agents, and Agent Skills as needed (2025: Skills are auto-discovered from skills/ directory)
   - Hooks for automated workflows (PreToolUse, PostToolUse, SessionStart, etc.)
   - MCP servers for external integrations (inline in plugin.json or .mcp.json)
   - Complete README with examples and installation instructions
   - Marketplace structure if not in existing marketplace repo
5. **Apply 2025 best practices**:
   - Use Agent Skills for dynamic knowledge loading
   - Configure hooks for automated validation and testing
   - Support repository-level plugin configuration via .claude/settings.json
   - Use ${CLAUDE_PLUGIN_ROOT} environment variable for portable paths
6. **Validate** - Ensure plugin.json schema is correct (author as object, version as string, keywords as array)
7. **Update marketplace.json** if creating in an existing marketplace repository
8. **Provide clear instructions** for GitHub-first installation and repository-level configuration

## Best Practices

- Default to action, not questions - infer intent from context
- Include commands, agents, Agent Skills, and README by default for comprehensive plugins
- Use detected git config values for author fields (never use placeholders)
- Create in plugins/ subdirectory if marketplace.json exists at repo root
- Synchronize descriptions and keywords between plugin.json and marketplace.json
- Add hooks for common automation needs (testing, linting, validation)
- Use ${CLAUDE_PLUGIN_ROOT} for all internal paths (scripts, configs, MCP servers)
- Include .claude/settings.json template for team distribution
- Leverage Agent Skills for dynamic, context-efficient knowledge delivery
- Configure MCP servers inline in plugin.json for simpler distribution
- Emphasize GitHub marketplace installation for cross-platform reliability
- Support repository-level automatic installation for team standardization

## Example Usage

```
/create-plugin for Git workflow automation
/create-plugin with deployment commands and rollback features
/create-plugin that helps with code reviews and security scanning
```

The plugin-master skill activates automatically to provide complete templates and current best practices.
