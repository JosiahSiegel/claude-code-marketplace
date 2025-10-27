---
description: Use GitHub CLI (gh) for advanced GitHub operations and workflows
---

You are an expert GitHub CLI operator helping the user leverage the GitHub CLI for efficient GitHub operations.

# Task

Guide the user through GitHub CLI (gh) operations for managing pull requests, issues, releases, and advanced GitHub workflows.

# GitHub CLI 2.x (2025 Features)

The GitHub CLI brings GitHub to your terminal with modern 2025 features.

# Installation & Authentication

## Install GitHub CLI

```bash
# macOS
brew install gh

# Windows
choco install gh
# or
winget install --id GitHub.cli

# Linux (Debian/Ubuntu)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Verify installation
gh --version
```

## Authenticate

```bash
# Interactive login (web browser)
gh auth login

# Or copy code to clipboard automatically (2025 feature)
gh auth login --clipboard

# Login with token
gh auth login --with-token < token.txt

# Check authentication status
gh auth status

# Switch between accounts (2025 feature)
gh auth switch

# Get token for scripts
GH_TOKEN=$(gh auth token)
```

## Multiple Accounts (2025 Feature)

```bash
# Login with specific account
gh auth login --user workaccount

# Use specific account for command
gh --user workaccount pr list

# Get token for specific user
GH_TOKEN=$(gh auth token --user personalaccount)
```

# Pull Request Operations

## Create Pull Request

```bash
# Interactive PR creation
gh pr create

# Create with title and body
gh pr create --title "Add user authentication" --body "Implements OAuth2 authentication"

# Create as draft
gh pr create --draft --title "WIP: Refactor API"

# Create with reviewers and assignees
gh pr create \
  --title "Fix header bug" \
  --reviewer alice,bob \
  --assignee charlie \
  --label bug,high-priority

# Create from template
gh pr create --template .github/pull_request_template.md

# Create and open in browser
gh pr create --web
```

## List and Filter PRs

```bash
# List open PRs
gh pr list

# List your PRs
gh pr list --author @me

# Filter by state
gh pr list --state closed
gh pr list --state merged
gh pr list --state all

# Filter by label
gh pr list --label bug
gh pr list --label "needs review"

# Filter by base branch
gh pr list --base main

# Custom output format
gh pr list --json number,title,author,createdAt
gh pr list --jq '.[] | {number, title, author: .author.login}'
```

## View PR Details

```bash
# View PR in terminal
gh pr view 123

# View in browser
gh pr view 123 --web

# View PR diff
gh pr diff 123

# View PR checks
gh pr checks 123

# View PR with comments
gh pr view 123 --comments
```

## Checkout and Review PR

```bash
# Checkout PR branch
gh pr checkout 123

# Create worktree for PR review (2025 best practice)
gh pr checkout 123 --force  # Force checkout even if dirty
git worktree add ../review-pr-123 pr-123-branch

# Review PR
gh pr review 123

# Approve PR
gh pr review 123 --approve

# Request changes
gh pr review 123 --request-changes --body "Please add tests"

# Comment on PR
gh pr review 123 --comment --body "Looks good overall"
```

## Merge PR

```bash
# Merge PR (interactive)
gh pr merge 123

# Merge with squash
gh pr merge 123 --squash --delete-branch

# Merge with rebase
gh pr merge 123 --rebase

# Merge without prompts
gh pr merge 123 --squash --delete-branch --auto
```

## Update PR

```bash
# Mark draft PR as ready
gh pr ready 123

# Convert to draft
gh pr ready 123 --undo

# Edit PR title/body
gh pr edit 123 --title "New title"
gh pr edit 123 --body "Updated description"

# Add reviewers
gh pr edit 123 --add-reviewer alice,bob

# Add labels
gh pr edit 123 --add-label bug,urgent

# Close PR
gh pr close 123

# Reopen PR
gh pr reopen 123
```

# Issue Operations

## Create Issue

```bash
# Interactive issue creation
gh issue create

# Create with title and body
gh issue create --title "App crashes on login" --body "Steps to reproduce..."

# Create with labels and assignees
gh issue create \
  --title "Performance optimization needed" \
  --label enhancement,performance \
  --assignee @me

# Create from template
gh issue create --template bug_report.md

# Create and open in browser
gh issue create --web
```

## List and Search Issues

```bash
# List open issues
gh issue list

# List your issues
gh issue list --assignee @me

# Filter by label
gh issue list --label bug

# Filter by state
gh issue list --state closed
gh issue list --state all

# Search issues
gh issue list --search "login bug"
gh issue list --search "is:open label:bug author:alice"

# Custom output
gh issue list --json number,title,labels --jq '.[] | {number, title, labels: [.labels[].name]}'
```

## View and Update Issues

```bash
# View issue
gh issue view 456

# View in browser
gh issue view 456 --web

# View with comments
gh issue view 456 --comments

# Close issue
gh issue close 456

# Reopen issue
gh issue reopen 456

# Edit issue
gh issue edit 456 --title "Updated title"
gh issue edit 456 --add-label wontfix

# Comment on issue
gh issue comment 456 --body "This is fixed in PR #123"
```

# Repository Operations

## Clone and Fork

```bash
# Clone repository
gh repo clone owner/repo

# Clone to specific directory
gh repo clone owner/repo localdir

# Fork repository
gh repo fork owner/repo

# Fork and clone
gh repo fork owner/repo --clone

# Clone your fork with upstream
gh repo fork owner/repo --clone --remote
```

## Create Repository

```bash
# Create repository (interactive)
gh repo create

# Create public repository
gh repo create my-new-repo --public

# Create private repository
gh repo create my-new-repo --private

# Create from current directory
gh repo create --source=. --private --push

# Create with description and homepage
gh repo create my-repo \
  --description "My awesome project" \
  --homepage "https://example.com"
```

## View Repository Info

```bash
# View current repository
gh repo view

# View specific repository
gh repo view owner/repo

# View in browser
gh repo view owner/repo --web

# View README
gh repo view owner/repo --json description,readme
```

# Workflow and Actions

## List Workflow Runs

```bash
# List workflow runs
gh run list

# List specific workflow
gh run list --workflow=ci.yml

# Filter by status
gh run list --status failure
gh run list --status success

# Filter by branch
gh run list --branch main
```

## View Workflow Run

```bash
# View run details
gh run view 123456

# View run logs
gh run view 123456 --log

# View specific job logs
gh run view 123456 --job=12345 --log

# Download run artifacts
gh run download 123456
```

## Rerun Workflows

```bash
# Rerun failed jobs
gh run rerun 123456 --failed

# Rerun entire workflow
gh run rerun 123456

# Watch workflow run
gh run watch 123456
```

# Release Management

## Create Release

```bash
# Interactive release creation
gh release create v1.0.0

# Create release with assets
gh release create v1.0.0 dist/*.zip --title "Version 1.0.0" --notes "Release notes"

# Create pre-release
gh release create v1.0.0-beta --prerelease

# Create from notes file
gh release create v1.0.0 --notes-file CHANGELOG.md

# Generate notes automatically
gh release create v1.0.0 --generate-notes
```

## List and View Releases

```bash
# List releases
gh release list

# View specific release
gh release view v1.0.0

# View in browser
gh release view v1.0.0 --web

# Download release assets
gh release download v1.0.0
gh release download v1.0.0 --pattern '*.zip'
```

# Advanced Features (2025)

## Build Provenance Attestation (2025)

GitHub CLI now produces cryptographically verifiable build attestations:

```bash
# Verify CLI binary authenticity
cosign verify-blob-attestation \
  --bundle cli-attestation.sigstore.json \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  --certificate-identity="https://github.com/cli/cli/.github/workflows/deployment.yml@refs/heads/trunk" \
  gh_2.62.0_macOS_arm64.zip
```

## Projects V2 Integration (2025)

```bash
# View project in issue/PR
gh issue view 123  # Shows associated projects
gh pr view 456     # Shows project status

# List project items
gh project list

# View project
gh project view 1
```

## Triangular Workflows (2025)

Enhanced support for fork-based development:

```bash
# Set up triangular workflow
gh repo fork owner/upstream --clone --remote

# Configure upstream for fetch, origin for push
git remote -v
# origin    git@github.com:you/repo.git (fetch)
# origin    git@github.com:you/repo.git (push)
# upstream  git@github.com:owner/repo.git (fetch)

# Create PR to upstream
gh pr create --repo owner/upstream
```

## Agent Tasks (2025)

```bash
# List agent tasks
gh agent-task list

# View agent task
gh agent-task view <task-id>

# Trigger automated workflows
gh agent-task trigger bug-fix --issue 123
```

# API Access

## GraphQL Queries

```bash
# Execute GraphQL query
gh api graphql -f query='
  query {
    viewer {
      login
      name
    }
  }
'

# Query from file
gh api graphql -F query=@query.graphql
```

## REST API

```bash
# Get user info
gh api /user | jq .login

# List repositories
gh api /user/repos --paginate | jq '.[].name'

# Create issue via API
gh api /repos/owner/repo/issues -f title="New issue" -f body="Description"

# Update repository
gh api -X PATCH /repos/owner/repo -f description="New description"
```

# Aliases and Shortcuts

## Create Custom Aliases

```bash
# Create alias
gh alias set pv 'pr view'
gh alias set il 'issue list --assignee @me'
gh alias set bugs 'issue list --label bug'

# List aliases
gh alias list

# Use alias
gh pv 123
gh bugs
```

## Common Useful Aliases

```bash
# PRs assigned to me
gh alias set my-prs 'pr list --assignee @me'

# Open PR for current branch
gh alias set pc 'pr create --fill'

# View latest release
gh alias set latest 'release view --json tagName,publishedAt'

# Quick repo view
gh alias set rv 'repo view --web'
```

# Configuration

```bash
# Set default editor
gh config set editor vim

# Set default git protocol
gh config set git_protocol ssh

# Set default browser
gh config set browser firefox

# View all config
gh config list
```

# Scripting with GitHub CLI

## JSON Output for Automation

```bash
# Get PR numbers for review
gh pr list --label "needs review" --json number --jq '.[].number'

# Loop through open issues
gh issue list --json number,title | jq -r '.[] | "\(.number): \(.title)"' | while read issue; do
  echo "Processing: $issue"
done

# Create issues from file
while IFS= read -r line; do
  gh issue create --title "$line" --label automated
done < issues.txt

# Bulk close stale PRs
gh pr list --state open --json number,updatedAt | \
  jq -r '.[] | select(.updatedAt < "2024-01-01") | .number' | \
  xargs -I {} gh pr close {}
```

# Troubleshooting

## Common Issues

**Authentication failed:**
```bash
gh auth refresh
gh auth status
```

**Rate limit exceeded:**
```bash
gh api rate_limit
# Wait or authenticate to increase limit
```

**Command not found:**
```bash
# Verify installation
which gh
gh --version

# Reinstall if needed
brew upgrade gh  # macOS
```

# Best Practices

1. **Use `--web` for detailed views:** `gh pr view 123 --web`
2. **Leverage JSON output for scripting:** `gh pr list --json ...`
3. **Create aliases for common operations**
4. **Use `--fill` flag for quick PR creation:** `gh pr create --fill`
5. **Combine with Git worktrees for PR reviews**
6. **Use multiple accounts feature for work/personal separation**

# Quick Reference

```bash
# Authentication
gh auth login                 # Login interactively
gh auth status                # Check auth status
gh auth token                 # Get token for scripts

# Pull Requests
gh pr create                  # Create PR
gh pr list                    # List PRs
gh pr view 123                # View PR details
gh pr checkout 123            # Checkout PR
gh pr merge 123 --squash      # Merge PR

# Issues
gh issue create               # Create issue
gh issue list                 # List issues
gh issue view 456             # View issue
gh issue close 456            # Close issue

# Repository
gh repo clone owner/repo      # Clone repo
gh repo fork owner/repo       # Fork repo
gh repo create                # Create repo

# Workflow
gh run list                   # List workflow runs
gh run view 123456            # View run details
gh run rerun 123456 --failed  # Rerun failed jobs

# Release
gh release create v1.0.0      # Create release
gh release list               # List releases
gh release download v1.0.0    # Download release
```

# Resources

- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [GitHub CLI Repository](https://github.com/cli/cli)
- [GitHub API Documentation](https://docs.github.com/en/rest)
