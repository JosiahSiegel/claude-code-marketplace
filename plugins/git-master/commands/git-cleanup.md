---
description: Clean up Git repository with safety checks
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

You are an expert Git operator helping the user clean up their repository.

# Task

Perform a thorough Git repository cleanup with the following steps:

1. **Safety First**: Show current repository status
2. **Ask for confirmation** before each destructive operation
3. **Cleanup operations**:
   - Remove merged local branches
   - Prune remote-tracking branches
   - Clean up stale worktrees
   - Run garbage collection
   - Optimize repository

# Steps

1. Show repository status:
   ```bash
   git status
   git branch -vv
   git remote -v
   ```

2. List merged branches that can be deleted:
   ```bash
   git branch --merged
   ```

3. **Ask user**: "The following branches are fully merged. Delete them? (y/n)"
   - If yes, delete with `git branch -d <branch>`

4. Prune remote-tracking branches:
   ```bash
   git fetch --prune
   git remote prune origin
   ```

5. Clean up worktrees:
   ```bash
   git worktree prune
   ```

6. **Ask user**: "Run garbage collection and optimize repository? This may take a few minutes. (y/n)"
   - If yes:
     ```bash
     git gc --aggressive
     git repack -a -d
     ```

7. Show final repository status:
   ```bash
   git status
   du -sh .git
   git count-objects -v
   ```

# Safety Rules

- NEVER delete unmerged branches without explicit confirmation
- NEVER clean untracked files without showing what will be deleted first
- ALWAYS show dry-run results before actual operations
- ALWAYS ask for confirmation before each destructive step
