---
description: Configure automatic plugin installation for repository teams using .claude/settings.json
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

# Setup Repository Plugins

Configure automatic marketplace and plugin installation at the repository level to ensure consistent tooling across teams.

## Purpose

Enables team-wide plugin standardization by configuring `.claude/settings.json` to automatically install specified marketplaces and plugins when team members trust the repository folder. This is a key 2025 feature for enterprise plugin distribution.

## Instructions

1. **Detect or create `.claude/` directory** at repository root
2. **Create or update `.claude/settings.json`** with marketplace and plugin specifications
3. **Configure `extraKnownMarketplaces`** for automatic marketplace installation:
   ```json
   {
     "extraKnownMarketplaces": [
       "company-org/internal-plugins",
       "team-name/shared-tools"
     ]
   }
   ```
4. **Configure `plugins`** section for automatic plugin enablement:
   ```json
   {
     "plugins": {
       "enabled": [
         "plugin-name-1",
         "plugin-name-2@marketplace-name"
       ]
     }
   }
   ```
5. **Document in README** that team members should trust the repository folder
6. **Commit to version control** so all team members receive the configuration

## Complete Example

```json
{
  "extraKnownMarketplaces": [
    "company/internal-tools",
    "JosiahSiegel/claude-code-marketplace"
  ],
  "plugins": {
    "enabled": [
      "deployment-helper@company",
      "code-review-helper@company",
      "test-master@JosiahSiegel"
    ]
  }
}
```

## Team Onboarding Workflow

When a new team member clones the repository:
1. They open the repository in Claude Code
2. Claude Code prompts them to trust the folder
3. Upon trusting, Claude Code automatically:
   - Adds configured marketplaces
   - Installs specified plugins
   - Enables plugins for the repository

## Security Considerations

- Only trust repositories from known sources
- Review `.claude/settings.json` before trusting
- Use organizational GitHub repositories for internal plugins
- Avoid exposing sensitive information in plugin configurations

## Best Practices

- **Start minimal** - Only include plugins the entire team needs
- **Document purpose** - Add comments explaining why each plugin is included
- **Version control** - Commit settings.json to track changes over time
- **Test first** - Verify configuration works before rolling out to team
- **Update gradually** - Add new plugins incrementally, not all at once

## Example Team README Section

```markdown
## Development Setup

This repository uses Claude Code plugins for consistent tooling.

### First Time Setup

1. Install Claude Code
2. Clone this repository
3. Open the repository folder in Claude Code
4. When prompted, **trust this repository folder**
5. Claude Code will automatically install required plugins

### Included Plugins

- `deployment-helper` - Automated deployment workflows
- `code-review-helper` - Consistent code review processes
- `test-master` - Testing automation and coverage
```

## Troubleshooting

**Plugins not installing automatically:**
- Verify `.claude/settings.json` is at repository root (not in subdirectory)
- Check that repository folder is trusted
- Confirm marketplace names are correct
- Try manual installation: `/plugin marketplace add MARKETPLACE_NAME`

**Permission errors:**
- Ensure marketplaces are public or accessible with current credentials
- Check GitHub authentication if using private repositories
- Verify organization has appropriate repository permissions
