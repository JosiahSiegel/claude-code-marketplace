---
description: Manage Azure DevOps repositories, branches, and Git operations
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

# Azure DevOps Repository Management

## Purpose
Manage Azure DevOps Git repositories, branches, pull requests, and policies using best practices.

## Before Managing Repos

**Check latest documentation:**
1. Azure Repos documentation
2. Git best practices for Azure DevOps
3. Branch policy recommendations
4. Latest security features

## Common Repository Operations

### Branch Management

**Create feature branch:**
```bash
# Using Git
git checkout -b feature/new-feature
git push -u origin feature/new-feature

# Using Azure DevOps CLI
az repos ref create \
  --name refs/heads/feature/new-feature \
  --repository myrepo \
  --object-id $(git rev-parse HEAD)
```

**Branch policies:**
```yaml
# In Azure DevOps UI
# Project Settings → Repositories → Branches → main → Branch Policies

Require:
- Minimum number of reviewers: 2
- Check for linked work items
- Check for comment resolution
- Build validation
- Limit merge types (squash only)
```

### Pull Request Workflow

**Create PR:**
```bash
# Using CLI
az repos pr create \
  --repository myrepo \
  --source-branch feature/new-feature \
  --target-branch main \
  --title "Add new feature" \
  --description "Implements feature X" \
  --work-items 123 456 \
  --reviewers user1@example.com user2@example.com
```

**PR best practices:**
- Link work items
- Write clear descriptions
- Keep PRs focused and small
- Respond to feedback promptly
- Resolve all comments
- Ensure builds pass

### Repository Settings

**Clone strategies:**
```bash
# Shallow clone for CI/CD
git clone --depth 1 https://dev.azure.com/org/project/_git/repo

# Full clone for development
git clone https://dev.azure.com/org/project/_git/repo
```

**Security:**
- Enable required reviewers
- Protect main branches
- Scan for secrets
- Use branch policies
- Audit access regularly
