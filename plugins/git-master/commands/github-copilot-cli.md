---
description: Use GitHub Copilot CLI for AI-powered terminal assistance and model evaluations
---

# GitHub Copilot CLI - AI-Powered Terminal (2025)

## Overview

GitHub Copilot CLI brings the full power of Copilot's coding agent directly to your terminal, providing intelligent command suggestions, explanations, and automation.

**⚠️ Note:** The old `gh-copilot` extension stopped working on October 25, 2025. Use the new GitHub Copilot CLI instead.

## Installation

```bash
# Install GitHub Copilot CLI (replaces gh-copilot extension)
# Requires GitHub Copilot subscription

# Download from GitHub
# Visit: https://github.com/github/copilot-cli

# Verify installation
gh copilot --version

# Authenticate
gh copilot auth
```

## Basic Usage

### Command Suggestions

```bash
# Get command suggestions
gh copilot suggest "create a new branch"

# Example output:
# Suggested commands:
# 1. git checkout -b new-branch
# 2. git switch -c new-branch
# 3. git branch new-branch && git checkout new-branch

# Complex scenarios
gh copilot suggest "find all commits by author in last month"
# Returns: git log --author="username" --since="1 month ago" --oneline

gh copilot suggest "compress all .log files older than 7 days"
# Returns: find . -name "*.log" -mtime +7 -exec gzip {} \;
```

### Command Explanations

```bash
# Explain complex commands
gh copilot explain "git rebase -i HEAD~5"

# Output:
# This command starts an interactive rebase for the last 5 commits:
# - git rebase: Reapply commits on top of another base
# - -i: Interactive mode (allows editing commit history)
# - HEAD~5: The base is 5 commits before current HEAD

gh copilot explain "find . -type f -name '*.js' -exec grep -l 'TODO' {} \;"

# Explains each part of the command in detail
```

### Git-Specific Assistance

```bash
# Git workflow help
gh copilot suggest "squash last 3 commits into one"
# Returns: git rebase -i HEAD~3

gh copilot suggest "undo last commit but keep changes"
# Returns: git reset --soft HEAD~1

gh copilot suggest "create hotfix branch from tag v1.2.3"
# Returns: git checkout -b hotfix/security-patch v1.2.3
```

## GitHub Models Evaluations (June 2025 Feature)

### Run Prompt Evaluations

```bash
# Evaluate prompts from command line
gh models eval

# Evaluate specific prompt file
gh models eval --prompt .prompts/analyze-code.yml

# Run with specific model
gh models eval --model gpt-4 --prompt .prompts/code-review.yml

# Batch evaluation
gh models eval --input-dir .prompts/ --output results.json
```

### Create Evaluation Prompt Files

**.prompts/code-review.yml:**
```yaml
name: code-review
description: Evaluate code review suggestions
prompt: |
  Review the following code for:
  - Security vulnerabilities
  - Performance issues
  - Best practices violations

  Code: {{code}}

evaluators:
  - type: string-match
    expected: "security"

  - type: similarity
    threshold: 0.8
    expected: "comprehensive review with specific suggestions"

  - type: llm-judge
    criteria: "accuracy and helpfulness of review"
```

### Built-in Evaluators

1. **String Match:** Check if output contains expected strings
2. **Similarity:** Measure similarity to expected output (0-1 score)
3. **LLM-as-a-Judge:** Use another LLM to evaluate quality
4. **Custom:** Define your own evaluation logic

### Example: Git Commit Message Evaluation

**.prompts/commit-message.yml:**
```yaml
name: commit-message-generator
description: Generate conventional commit messages
prompt: |
  Generate a commit message for these changes:
  {{git diff --staged}}

evaluators:
  - type: string-match
    expected: "feat|fix|docs|style|refactor|test|chore"
    description: "Must use conventional commit type"

  - type: llm-judge
    criteria: |
      - Follows conventional commits format
      - Clear and concise
      - Explains what and why
      - Under 72 characters for first line
```

**Run evaluation:**
```bash
# Generate and evaluate commit messages
git diff --staged | gh models eval --prompt .prompts/commit-message.yml

# View results
cat evaluation-results.json | jq '.score'
```

## Interactive Mode

```bash
# Start interactive session
gh copilot

# Chat with Copilot about Git
> How do I recover a deleted branch?
> What's the difference between merge and rebase?
> Help me resolve this merge conflict

# Exit with Ctrl+D or 'exit'
```

## Advanced Features

### Script Generation

```bash
# Generate automation scripts
gh copilot generate "bash script to backup git repos daily"

# Output: Complete bash script with comments and error handling
#!/bin/bash
# Daily Git Repository Backup Script
...

gh copilot generate "GitHub Actions workflow for automated testing"

# Output: Complete .github/workflows/test.yml
```

### Workflow Optimization

```bash
# Analyze current workflow
gh copilot analyze

# Suggests improvements:
# - Faster commands
# - Better practices
# - Automation opportunities

# Get workflow suggestions
gh copilot workflow "I want to deploy on every push to main"

# Returns complete GitHub Actions workflow
```

### Integration with GitHub CLI

```bash
# Copilot-assisted PR creation
gh copilot suggest "create PR with auto-generated description"
# Returns: gh pr create --fill

# Copilot-assisted issue triage
gh copilot suggest "list all high-priority bugs assigned to me"
# Returns: gh issue list --label "priority:high,bug" --assignee @me

# Copilot-assisted release
gh copilot suggest "create release with auto-generated notes"
# Returns: gh release create v1.0.0 --generate-notes
```

## Configuration

```bash
# Set preferred shell
gh copilot config set shell bash

# Set verbosity
gh copilot config set verbosity detailed

# Enable/disable telemetry
gh copilot config set telemetry false

# View all settings
gh copilot config list
```

## Use Cases

### 1. Learning Git Commands

```bash
# Instead of searching documentation
gh copilot suggest "how to see commit history for specific file"
# Immediately get: git log --follow -- <file>

gh copilot explain "git log --graph --oneline --all --decorate"
# Get detailed explanation of each flag
```

### 2. Complex Git Operations

```bash
# Get help with advanced operations
gh copilot suggest "rewrite commit author for all commits"
# Returns safe filter-repo command with warnings

gh copilot suggest "split monorepo into separate repositories"
# Returns step-by-step approach with commands
```

### 3. Automation and Scripting

```bash
# Generate maintenance scripts
gh copilot generate "script to clean up merged branches"

# Output: Complete script with safety checks
#!/bin/bash
git branch --merged | grep -v '\*\|main\|develop' | xargs -n 1 git branch -d
```

### 4. Troubleshooting

```bash
# Get help with errors
gh copilot suggest "fix 'fatal: refusing to merge unrelated histories'"
# Returns: git pull --allow-unrelated-histories

gh copilot explain "why am I in detached HEAD state?"
# Explains what it means and how to fix it
```

### 5. CI/CD Optimization

```bash
# Generate optimized CI workflows
gh copilot generate "GitHub Actions workflow with caching and parallel jobs"

# Get workflow improvements
gh copilot analyze .github/workflows/ci.yml
# Suggests: Add caching, use matrix builds, optimize checkout
```

## Best Practices

1. **Use for Learning:**
   ```bash
   # Ask for explanations, not just commands
   gh copilot explain <command>
   ```

2. **Verify Before Executing:**
   ```bash
   # Always review suggested commands
   gh copilot suggest "command" --explain
   # Then decide if you want to run it
   ```

3. **Leverage for Documentation:**
   ```bash
   # Generate documentation
   gh copilot generate "document our git workflow"
   ```

4. **Model Evaluation Workflow:**
   ```bash
   # Create evaluation prompts for repetitive tasks
   # Store in .prompts/ directory
   # Run evaluations to ensure quality
   gh models eval --prompt .prompts/
   ```

5. **Combine with Git Hooks:**
   ```bash
   # Use Copilot to generate pre-commit hooks
   gh copilot generate "pre-commit hook to check commit message format"
   ```

## Differences from Old gh-copilot Extension

| Feature | Old gh-copilot | New Copilot CLI |
|---------|----------------|-----------------|
| Capabilities | Limited suggestions | Full coding agent |
| Context awareness | Basic | Advanced (understands repo context) |
| Explanation quality | Simple | Detailed with examples |
| Script generation | No | Yes |
| Model evaluations | No | Yes (gh models eval) |
| Interactive mode | No | Yes |
| Workflow analysis | No | Yes |
| Status | Deprecated Oct 2025 | Active |

## Troubleshooting

**Command not found:**
```bash
# Ensure Copilot CLI is installed
gh copilot --version

# Update gh CLI
gh extension upgrade copilot
```

**Authentication issues:**
```bash
# Re-authenticate
gh copilot auth logout
gh copilot auth login
```

**Copilot not understanding context:**
```bash
# Provide more context in your query
gh copilot suggest "in this git repository, how do I..."
```

## Resources

- [GitHub Copilot CLI Documentation](https://docs.github.com/en/copilot/cli)
- [Model Evaluations Guide](https://docs.github.com/en/copilot/model-evaluations)
- [Migration from gh-copilot](https://github.blog/changelog/2025-09-25-upcoming-deprecation-of-gh-copilot-cli-extension/)
