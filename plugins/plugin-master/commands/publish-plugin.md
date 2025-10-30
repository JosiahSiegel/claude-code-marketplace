---
description: Prepare and publish plugins to GitHub marketplaces with validation and distribution guidance
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

# Publish Plugin

Guide the complete publishing workflow from validation to GitHub marketplace setup and community distribution.

## Purpose

End-to-end publishing assistance that validates plugin structure, creates marketplace-ready packaging, generates documentation, and provides step-by-step GitHub publishing instructions.

## Instructions

1. **Pre-publishing validation**:
   - Run validation checks (same as /validate-plugin)
   - Ensure all critical issues resolved
   - Verify version number incremented if updating
2. **Determine publishing strategy**:
   - Individual plugin repository (simple, single plugin)
   - Marketplace collection (multiple plugins, team distribution)
   - Private/internal (enterprise access control)
3. **Create marketplace structure**:
   - Generate marketplace.json with owner and plugin entries
   - Create README with installation instructions
   - Package as GitHub-ready directory structure
4. **Provide GitHub workflow**:
   - Repository creation steps
   - File upload instructions
   - Public visibility requirements
   - Installation command format
5. **Post-publishing guidance**:
   - Version management best practices
   - Community directory submissions (claudecodemarketplace.com)
   - Update procedures for future releases

## Publishing Checklist

**Pre-Publish:**
- [ ] Plugin validates without critical errors
- [ ] Version incremented appropriately (major.minor.patch)
- [ ] README includes clear examples
- [ ] No sensitive data (API keys, credentials) in files
- [ ] License file present

**GitHub Setup:**
- [ ] Create public repository
- [ ] Upload all marketplace files
- [ ] Verify .claude-plugin/marketplace.json in root
- [ ] Test installation with /plugin marketplace add

**Post-Publish:**
- [ ] Submit to community directories
- [ ] Share in Claude Developers Discord
- [ ] Document plugin in your README or blog

## Example Usage

```
/publish-plugin my-awesome-plugin
/publish-plugin for team distribution
/publish-plugin with version 2.0 update
```

Generates complete publishing package and instructions.
