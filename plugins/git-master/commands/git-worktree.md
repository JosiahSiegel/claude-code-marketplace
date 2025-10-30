---
description: Manage Git worktrees for parallel development workflows
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

You are an expert Git operator helping the user work with Git worktrees for efficient parallel development.

# Task

Guide the user through Git worktree operations for managing multiple working directories from a single repository.

# What Are Worktrees?

Worktrees allow you to have multiple working directories from one repository:
- Work on multiple branches simultaneously
- Review PRs while continuing development
- No need to stash/commit before switching contexts
- Shared .git directory (one fetch updates all)

# Common Worktree Operations

## 1. List Existing Worktrees

```bash
git worktree list
```

## 2. Create New Worktree

**For existing branch:**
```bash
git worktree add <path> <branch-name>

# Example
git worktree add ../myproject-feature feature/user-auth
```

**For new branch:**
```bash
git worktree add -b <new-branch> <path> <start-point>

# Example
git worktree add -b feature/new-api ../myproject-api main
```

**For PR review:**
```bash
git worktree add <path> <remote>/<branch>

# Example for GitHub PR
git fetch origin pull/123/head
git worktree add ../myproject-pr-123 FETCH_HEAD
```

## 3. Remove Worktree

```bash
# Remove and delete directory
git worktree remove <path>

# Force remove (even with uncommitted changes)
git worktree remove --force <path>
```

## 4. Clean Up Stale References

```bash
git worktree prune
```

# Workflow Examples

## Scenario 1: PR Review During Development

**Current situation:** You're working on a feature but need to review a PR.

```bash
# 1. Create worktree for PR review
git worktree add ../myproject-review origin/pull/456/head

# 2. Review in separate terminal/IDE
cd ../myproject-review
# Review code, test, comment

# 3. Return to your feature work
cd -  # Back to original directory

# 4. Clean up when done
git worktree remove ../myproject-review
```

## Scenario 2: Hotfix While Feature Development

**Current situation:** Production bug needs immediate fix.

```bash
# 1. Create worktree from production branch
git worktree add --detach ../myproject-hotfix v1.2.3

cd ../myproject-hotfix

# 2. Create hotfix branch
git switch -c hotfix/critical-bug

# 3. Make fix and push
git add .
git commit -m "fix: resolve critical production bug"
git push -u origin hotfix/critical-bug

# 4. Return to feature work
cd -

# 5. Clean up after hotfix deployed
git worktree remove ../myproject-hotfix
```

## Scenario 3: Multiple Features in Parallel

**Current situation:** Working on several features simultaneously.

```bash
# Create organized worktree structure
mkdir -p ~/worktrees/myproject

# Main development
cd ~/projects/myproject

# Feature A
git worktree add ~/worktrees/myproject/feature-a -b feature/authentication

# Feature B
git worktree add ~/worktrees/myproject/feature-b -b feature/api-integration

# Bug fix
git worktree add ~/worktrees/myproject/bugfix -b fix/header-issue

# Work on each in separate IDE instances
code ~/worktrees/myproject/feature-a
code ~/worktrees/myproject/feature-b
```

# Best Practices

## 1. Organize Directory Structure

**Recommended structure:**
```
~/projects/
  myproject/              # Main worktree (main branch)
  myproject-feature-a/    # Feature A worktree
  myproject-feature-b/    # Feature B worktree
  myproject-review/       # PR review worktree
```

**Or centralized:**
```
~/worktrees/myproject/
  feature-a/
  feature-b/
  review/
  hotfix/
```

## 2. Clean Up Regularly

**Remove merged worktrees:**
```bash
# List all worktrees
git worktree list

# Check if branch is merged
git branch --merged

# Remove worktree if merged
git worktree remove <path>
```

## 3. Use Descriptive Paths

```bash
# ✅ Good: Clear purpose
git worktree add ../myproject-pr-123 origin/pull/123/head
git worktree add ../myproject-feature-auth feature/authentication

# ❌ Bad: Unclear purpose
git worktree add ../temp origin/pull/123/head
git worktree add ../wt2 feature/authentication
```

## 4. Share Fetch/Pull Across Worktrees

```bash
# In any worktree, fetch updates all
git fetch --all

# Changes are visible in all worktrees
cd ../myproject-other-worktree
git branch -r  # Shows newly fetched branches
```

# Common Issues & Solutions

## Issue: "Branch already checked out"

**Error:**
```
fatal: 'feature-branch' is already checked out at '/path/to/worktree'
```

**Solution:**
```bash
# Option 1: Use different branch
git worktree add ../new-path other-branch

# Option 2: Force checkout (use with caution!)
git checkout --ignore-other-worktrees feature-branch
```

## Issue: Locked Worktree

**Error:**
```
fatal: 'worktree' is locked
```

**Solution:**
```bash
git worktree unlock <path>
```

## Issue: Stale Worktree References

**Situation:** Manually deleted worktree directory.

**Solution:**
```bash
# Clean up references
git worktree prune

# Verify
git worktree list
```

## Issue: Different Configuration Needed

**Situation:** Worktree needs different config (e.g., different user.email).

**Solution:**
```bash
cd worktree-path

# Worktree-specific config
git config --worktree user.email work@company.com
git config --worktree core.autocrlf false

# Check config
git config --worktree --list
```

# Advanced Operations

## Create Worktree from Specific Commit

```bash
git worktree add --detach ../myproject-debug abc1234
cd ../myproject-debug
git switch -c debug/investigate-issue
```

## Move Worktree

```bash
git worktree move <old-path> <new-path>

# Example
git worktree move ../myproject-old ../myproject-new
```

## Lock Worktree (Prevent Deletion)

```bash
# Lock to prevent accidental removal
git worktree lock <path>

# Unlock
git worktree unlock <path>
```

# When to Use Worktrees

**✅ Use worktrees when:**
- Need to work on multiple branches simultaneously
- Reviewing PRs while developing
- Building/testing different branches in parallel
- Creating hotfixes during feature work
- Running long operations (tests, builds) on one branch while working on another

**❌ Don't use worktrees when:**
- Low disk space (each worktree needs space)
- Only occasionally switching branches (use git switch)
- Working with submodules (can be complex)
- Team members unfamiliar with worktrees

# Integration with IDEs

## VS Code

```bash
# Open worktree in new VS Code window
code ../myproject-feature

# Or from command palette
# File → Open Folder → Select worktree path
```

## JetBrains IDEs

```bash
# Open worktree as separate project
idea ../myproject-feature

# Or File → Open → Select worktree path
```

# Safety Checks

**Before creating worktree:**
1. Check current worktrees: `git worktree list`
2. Verify branch status: `git status`
3. Ensure clean working directory or commit changes

**Before removing worktree:**
1. Check for uncommitted changes: `cd <worktree> && git status`
2. Verify branch is merged (if applicable): `git branch --merged`
3. Push any unpushed commits: `git push`

**After operations:**
1. Verify worktree list: `git worktree list`
2. Clean up stale references: `git worktree prune`

# Resources

- [Git Worktree Documentation](https://git-scm.com/docs/git-worktree)
- [Worktree Best Practices Guide](https://git-scm.com/docs/git-worktree)

# Summary

Git worktrees enable:
- ✓ Parallel development on multiple branches
- ✓ PR reviews without context switching
- ✓ Hotfixes during feature work
- ✓ Efficient resource usage (shared .git)
- ✓ Reduced stash/commit/switch cycles

Use worktrees to maximize productivity when working on multiple tasks simultaneously!
