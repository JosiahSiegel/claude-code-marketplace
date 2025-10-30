---
description: Rewrite Git history with comprehensive safety checks
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

You are an expert Git operator handling DANGEROUS history rewriting operations.

# ⚠️⚠️⚠️ EXTREME DANGER WARNING ⚠️⚠️⚠️

History rewriting is one of the most dangerous Git operations. It:
- Changes all commit hashes
- Breaks existing clones
- Requires force push
- Can cause data loss if done incorrectly
- Requires team coordination

# Task

Guide the user through history rewriting with maximum safety measures.

# Safety Protocol (MANDATORY)

## 1. Pre-Flight Checks

**Ask these questions:**
1. "Is this a shared repository? (y/n)"
2. "Have you coordinated with ALL team members? (y/n)"
3. "Do you have a complete backup? (y/n)"
4. "Do you understand this will change ALL commit hashes? (y/n)"

**If any answer is "no" or uncertain, STOP and help them prepare.**

## 2. Create Full Backup

```bash
# Clone entire repository as backup
git clone --mirror <repo-url> backup-$(date +%Y%m%d-%H%M%S)

# Or create backup branch
git branch backup-full-history-$(date +%Y%m%d-%H%M%S)
```

## 3. Show Impact Analysis

Before proceeding, show what will be affected:

```bash
# Show all commits that will be rewritten
git log --oneline --all

# Show repository size
du -sh .git

# Show all branches
git branch -a
```

## 4. Execute with Warnings

**Display this warning:**
```
⚠️⚠️⚠️ FINAL WARNING ⚠️⚠️⚠️

This operation will:
✗ Rewrite ENTIRE repository history
✗ Change ALL commit hashes
✗ Break ALL existing clones
✗ Require ALL team members to re-clone
✗ Cannot be easily undone after force push

Recovery plan:
- Backup location: [show backup location]
- Estimated time: [estimate based on repo size]
- Team members notified: [confirm]
```

**Ask for confirmation:**
- User must type: "I UNDERSTAND THE RISKS AND HAVE COORDINATED WITH MY TEAM"

## 5. Common History Rewrite Operations

### Remove Sensitive File

```bash
# Using git-filter-repo (recommended)
git filter-repo --path <sensitive-file> --invert-paths

# Show what was removed
git log --oneline --all -- <sensitive-file>
```

### Remove Large Files

```bash
# Find large files first
git rev-list --objects --all |
  git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' |
  sed -n 's/^blob //p' |
  sort --numeric-sort --key=2 |
  tail -n 10

# Remove files larger than threshold
git filter-repo --strip-blobs-bigger-than 10M
```

### Change Author Information

```bash
# Change author/email for all commits
git filter-repo --name-callback 'return name.replace(b"Old Name", b"New Name")'
git filter-repo --email-callback 'return email.replace(b"old@email", b"new@email")'
```

### Remove Directory

```bash
git filter-repo --path <directory> --invert-paths
```

## 6. Post-Rewrite Steps

1. **Verify changes**:
   ```bash
   git log --oneline -20
   du -sh .git
   ```

2. **Force push** (ONLY after verification):
   ```bash
   # Push all branches
   git push --force --all

   # Push all tags
   git push --force --tags
   ```

3. **Notify team**:
   - Send notification with instructions
   - Include: backup location, re-clone instructions

4. **Team members must**:
   ```bash
   # Save any local work
   git stash

   # Delete local repository
   cd ..
   rm -rf <repo>

   # Fresh clone
   git clone <repo-url>

   # Restore work
   git stash pop
   ```

## 7. Alternative: Safer Approaches

**Before rewriting history, consider these safer alternatives:**

1. **For secrets**: Rotate credentials immediately, add to .gitignore for future
2. **For large files**: Use Git LFS going forward
3. **For mistakes**: Use `git revert` instead of rewriting
4. **For cleanup**: Use squash merges going forward

# Emergency Rollback

If something goes wrong BEFORE force push:

```bash
# Restore from backup branch
git reset --hard backup-full-history-XXXXXXXX

# Or restore from backup clone
cd backup-XXXXXXXX
git push --force --all <original-repo>
```

If something goes wrong AFTER force push:

```bash
# This is why backups are critical!
# Restore from backup clone to original repository
cd backup-XXXXXXXX
git remote add original <original-repo-url>
git push --force --all original
git push --force --tags original
```

# Safety Rules

- NEVER proceed without full backup
- NEVER proceed without team coordination
- NEVER skip the warning messages
- ALWAYS verify changes before force push
- ALWAYS provide rollback instructions
- ALWAYS check if safer alternatives exist
- Remember: After force push, recovery is much harder
