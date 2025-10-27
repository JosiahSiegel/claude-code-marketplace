---
name: git-2025-features
description: Git 2.47+ features including reftables, sparse-checkout, partial clone, and worktrees
---

# Git 2025 Features - Advanced Capabilities

## Git 2.48 (Released January 2025)

### Reftables Migration

**What:** New reference storage format replacing loose ref files and packed-refs.

**Benefits:**
- Faster ref operations (50-80% improvement)
- Atomic ref updates
- Better scalability for repositories with many refs
- Reflogs now fully migratable

**Migration:**

```bash
# Check current ref storage format
git config core.refStorage

# Migrate to reftables
git refs migrate --ref-storage=reftables

# Verify migration
git fsck --full
git log --oneline -5

# Roll back if needed (before critical operations)
git refs migrate --ref-storage=files
```

**When to use:**
- Repositories with 10,000+ refs
- High-frequency branch operations
- CI/CD systems creating many temporary refs
- Monorepos with extensive branching

### Memory Leak Free Milestone

Git 2.48 achieved memory leak free status. Benefit automatically in long-running operations:

- Large repository clones
- Extended rebase sessions
- Bulk operations (filter-repo, GC)

## Sparse-Checkout (Enhanced in 2.48)

**What:** Check out only a subset of files from repository.

**Use cases:**
- Monorepos (work on one service)
- Large repositories (reduce disk usage)
- Build systems (fetch only needed files)

**Cone Mode (Default - Recommended):**

```bash
# Clone with sparse-checkout
git clone --filter=blob:none --sparse <repo-url>
cd <repo>

# Initialize sparse-checkout in cone mode
git sparse-checkout init --cone

# Add directories to checkout
git sparse-checkout set src/api src/shared docs

# Add more directories
git sparse-checkout add tests/integration

# View current patterns
git sparse-checkout list

# Check what would be matched
git sparse-checkout check-rules src/api/users.ts

# Disable sparse-checkout
git sparse-checkout disable
```

**Advanced Patterns (Non-Cone Mode):**

```bash
# Enable pattern mode
git sparse-checkout init --no-cone

# Add patterns (one per line)
git sparse-checkout set \
  "*.md" \
  "src/api/*" \
  "!src/api/legacy/*"

# Read patterns from file
git sparse-checkout set --stdin < patterns.txt
```

**Reapply Rules:**

```bash
# After merge/rebase that materialized unwanted files
git sparse-checkout reapply
```

## Partial Clone

**What:** Clone repository without downloading all objects initially.

**Filters:**

1. **blob:none** - Defer all blobs (fastest, smallest)
2. **tree:0** - Defer all trees and blobs
3. **blob:limit=1m** - Defer blobs larger than 1MB

**Usage:**

```bash
# Clone without blobs (fetch on demand)
git clone --filter=blob:none <repo-url>

# Clone without large files
git clone --filter=blob:limit=10m <repo-url>

# Combine with sparse-checkout
git clone --filter=blob:none --sparse <repo-url>
cd <repo>
git sparse-checkout set src/api

# Convert existing repository to partial clone
git config extensions.partialClone origin
git config remote.origin.promisor true
git fetch --filter=blob:none

# Prefetch all missing objects
git fetch --unshallow
```

**Combine Partial Clone + Sparse-Checkout:**

```bash
# Ultimate efficiency: Only objects for specific directories
git clone --filter=blob:none --sparse <repo-url>
cd <repo>
git sparse-checkout set --cone src/api
git checkout main

# Result: Only have objects for src/api
```

**Check promisor objects:**

```bash
# Verify partial clone status
git config extensions.partialClone

# See promisor packfiles
ls -lah .git/objects/pack/*.promisor

# Force fetch specific object
git rev-list --objects --missing=print HEAD | grep "^?"
```

## Git Worktrees

**What:** Multiple working directories from one repository.

**Benefits:**
- Work on multiple branches simultaneously
- No need to stash/commit before switching
- Parallel work (review PR while coding)
- Shared .git (one fetch updates all)

**Basic Operations:**

```bash
# List worktrees
git worktree list

# Create worktree for existing branch
git worktree add ../project-feature feature-branch

# Create worktree with new branch
git worktree add -b new-feature ../project-new-feature

# Create worktree from remote branch
git worktree add ../project-fix origin/fix-bug

# Remove worktree
git worktree remove ../project-feature

# Clean up stale worktree references
git worktree prune
```

**Advanced Patterns:**

```bash
# Worktree for PR review while coding
git worktree add ../myproject-pr-123 origin/pull/123/head
cd ../myproject-pr-123
# Review PR in separate directory
cd -
# Continue coding in main worktree

# Worktree for hotfix
git worktree add --detach ../myproject-hotfix v1.2.3
cd ../myproject-hotfix
# Make hotfix
git switch -c hotfix/security-patch
git commit -am "fix: patch vulnerability"
git push -u origin hotfix/security-patch

# Worktree organization
mkdir -p ~/worktrees/myproject
git worktree add ~/worktrees/myproject/feature-a -b feature-a
git worktree add ~/worktrees/myproject/feature-b -b feature-b
git worktree add ~/worktrees/myproject/pr-review origin/pull/42/head
```

**Best Practices:**

1. **Organize directory structure:**
```bash
~/projects/
  myproject/           # Main worktree
  myproject-feature/   # Feature worktree
  myproject-review/    # Review worktree
```

2. **Clean up regularly:**
```bash
# Remove merged worktrees
git worktree list | grep feature | while read wt branch commit; do
  if git branch --merged | grep -q "$branch"; then
    git worktree remove "$wt"
  fi
done
```

3. **Shared configuration:**
- .git/config applies to all worktrees
- .git/info/exclude applies to all worktrees
- Each worktree has own index and HEAD

## Scalar (Large Repository Tool)

**What:** Tool for optimizing very large repositories (Microsoft-developed).

```bash
# Install scalar (comes with Git 2.47+)
scalar register <path>

# Clone with scalar optimizations
scalar clone --branch main <repo-url>

# Enables automatically:
# - Sparse-checkout (cone mode)
# - Partial clone (blob:none)
# - Multi-pack-index
# - Commit-graph
# - Background maintenance

# Unregister
scalar unregister <path>

# Delete repository
scalar delete <path>
```

## Git Backfill (Experimental)

**What:** Background process to fetch missing objects in partial clone.

```bash
# Fetch missing blobs in background
git backfill

# Configure batch size
git backfill --min-batch-size=1000

# Respect sparse-checkout patterns
git backfill --sparse
```

## Performance Comparison

**Traditional Clone:**
```bash
git clone large-repo
# Size: 5GB, Time: 10 minutes
```

**Sparse-Checkout:**
```bash
git clone --sparse large-repo
git sparse-checkout set src/api
# Size: 500MB, Time: 3 minutes
```

**Partial Clone:**
```bash
git clone --filter=blob:none large-repo
# Size: 100MB, Time: 1 minute
```

**Partial Clone + Sparse-Checkout:**
```bash
git clone --filter=blob:none --sparse large-repo
git sparse-checkout set src/api
# Size: 50MB, Time: 30 seconds
```

## When to Use Each Feature

**Sparse-Checkout:**
- ✓ Monorepos
- ✓ Working on specific services/modules
- ✓ Limited disk space
- ✗ Need entire codebase often

**Partial Clone:**
- ✓ CI/CD pipelines
- ✓ Large repositories
- ✓ Good network connectivity
- ✗ Offline work frequently

**Worktrees:**
- ✓ Parallel development
- ✓ PR reviews during work
- ✓ Multiple branch testing
- ✗ Low disk space

**Combine All:**
- ✓ Massive monorepos (Google scale)
- ✓ Multiple simultaneous tasks
- ✓ Minimal local storage
- ✓ Fast network connection

## Troubleshooting

**Sparse-checkout not working:**
```bash
# Verify configuration
git config core.sparseCheckout
git config core.sparseCheckoutCone

# Re-apply patterns
git sparse-checkout reapply

# Check patterns
git sparse-checkout list
```

**Missing objects in partial clone:**
```bash
# Fetch specific object
git fetch origin <commit>

# Fetch all missing
git fetch --unshallow

# Verify promisor config
git config extensions.partialClone
```

**Worktree issues:**
```bash
# Locked worktree
git worktree unlock <path>

# Corrupted worktree
git worktree remove --force <path>
git worktree prune

# Branch already checked out
git checkout --ignore-other-worktrees <branch>
```

## Migration Guide

**From traditional to optimized workflow:**

```bash
# 1. Current large clone
cd large-project
du -sh .git  # 5GB

# 2. Create optimized new clone
cd ..
git clone --filter=blob:none --sparse large-project-new
cd large-project-new
git sparse-checkout set src/api src/shared

# 3. Verify size
du -sh .git  # 50MB

# 4. Switch workflow
cd ../large-project-new

# 5. Delete old clone when comfortable
rm -rf ../large-project
```

## Resources

- [Git Partial Clone Documentation](https://git-scm.com/docs/partial-clone)
- [Git Sparse-Checkout Guide](https://github.blog/open-source/git/bring-your-monorepo-down-to-size-with-sparse-checkout/)
- [Git Worktree Best Practices](https://git-scm.com/docs/git-worktree)
- [Scalar Documentation](https://github.com/microsoft/scalar)
