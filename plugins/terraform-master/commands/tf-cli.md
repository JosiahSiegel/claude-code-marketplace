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


# Terraform CLI Reference and Advanced Usage

Comprehensive guide to Terraform CLI commands, flags, options, and advanced usage patterns across all platforms.

## Your Task

You are helping with Terraform CLI usage, flags, and advanced command patterns. Provide comprehensive guidance with platform-specific examples.

## Global Options

### -chdir=DIR

Change working directory before executing any command. **Recommended over using cd in scripts.**

**Usage**:
```bash
terraform -chdir=path/to/config <command>
```

**Examples**:
```bash
# Relative path
terraform -chdir=../production plan
terraform -chdir=environments/prod apply

# Absolute path (Linux/macOS)
terraform -chdir=/home/user/terraform/prod init

# Absolute path (Windows)
terraform -chdir="C:\terraform\production" plan

# In scripts (Linux/macOS)
#!/bin/bash
ENVIRONMENT=$1
terraform -chdir="environments/$ENVIRONMENT" plan

# In scripts (Windows PowerShell)
param([string]$Environment)
terraform -chdir="environments\$Environment" plan
```

**Why use -chdir instead of cd**:
- ✅ Works in all shells without shell-specific syntax
- ✅ Safer in CI/CD (no state carried between commands)
- ✅ Clearer intent in logs
- ✅ Avoids directory navigation errors
- ✅ Platform-agnostic

**Multi-Directory Workflows**:
```bash
# Initialize all environments
for env in dev staging prod; do
  terraform -chdir="environments/$env" init
done

# Plan all layers in order
terraform -chdir=01-foundation plan -out=foundation.tfplan
terraform -chdir=02-platform plan -out=platform.tfplan
terraform -chdir=03-applications plan -out=apps.tfplan
```

### Other Global Flags

```bash
terraform -version          # Show Terraform version
terraform -help             # Show help
terraform -help <command>   # Show command-specific help
terraform -chdir=DIR -help plan  # Help for command in specific directory
```

## Command-Specific Flags

### terraform init

**Purpose**: Initialize Terraform working directory, download providers and modules.

**Common Flags**:
```bash
-backend-config=KEY=VALUE   # Override backend configuration
-backend=false              # Skip backend initialization
-reconfigure                # Ignore existing backend config
-migrate-state              # Migrate state to new backend
-upgrade                    # Upgrade providers and modules
-get=false                  # Don't download modules
-plugin-dir=DIR             # Custom plugin directory
-lockfile=MODE              # Lock file handling (readonly/ignore)
```

**Examples**:
```bash
# Basic initialization
terraform init

# With backend configuration
terraform init -backend-config="key=prod.tfstate"
terraform init -backend-config="resource_group_name=terraform-rg"

# Multiple backend configs
terraform init \
  -backend-config="resource_group_name=tfstate-rg" \
  -backend-config="storage_account_name=tfstate" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=prod.tfstate"

# Upgrade providers within constraints
terraform init -upgrade

# Reconfigure backend (force new configuration)
terraform init -reconfigure

# Migrate to new backend
terraform init -migrate-state

# Skip backend (local state only)
terraform init -backend=false

# In different directory
terraform -chdir=production init -backend-config="key=prod.tfstate"

# Read-only lock file (CI/CD)
terraform init -lockfile=readonly
```

### terraform plan

**Purpose**: Generate execution plan showing what Terraform will do.

**Output Options**:
```bash
-out=FILE                   # Save plan to file
-json                       # Output in JSON format
-no-color                   # Disable colored output
-compact-warnings           # Compact warning output
```

**State Options**:
```bash
-refresh=false              # Skip refreshing state
-refresh-only               # Only refresh, don't plan changes
-state=PATH                 # Path to state file
-lock=false                 # Don't acquire state lock
-lock-timeout=DURATION      # How long to wait for lock (e.g., "10m")
```

**Variable Options**:
```bash
-var='KEY=VALUE'            # Set a variable
-var-file=FILE              # Load variables from file
```

**Targeting**:
```bash
-target=RESOURCE            # Focus on specific resource
-replace=RESOURCE           # Plan to replace resource
```

**Other**:
```bash
-parallelism=N              # Number of concurrent operations (default 10)
-detailed-exitcode          # Exit 0=no changes, 2=changes, 1=error
-input=false                # Don't prompt for input
```

**Examples**:
```bash
# Basic plan
terraform plan

# Save plan for apply
terraform plan -out=tfplan

# With variables
terraform plan -var='environment=prod' -var='region=eastus'
terraform plan -var-file="environments/prod.tfvars"

# Fast plan (skip refresh)
terraform plan -refresh=false

# Only refresh state
terraform plan -refresh-only

# Target specific resource
terraform plan -target=azurerm_resource_group.main
terraform plan -target=module.networking

# Plan to replace resource
terraform plan -replace=azurerm_virtual_machine.web

# CI/CD optimized
terraform plan \
  -chdir=terraform \
  -var-file="prod.tfvars" \
  -out=tfplan \
  -lock-timeout=5m \
  -no-color \
  -detailed-exitcode

# Performance optimized
terraform plan \
  -refresh=false \
  -parallelism=20 \
  -out=tfplan

# JSON output for parsing
terraform plan -json | jq '.resource_changes'
```

### terraform apply

**Purpose**: Apply changes from plan or configuration.

**Common Flags**:
```bash
-auto-approve               # Skip interactive approval
-input=false                # Don't prompt for input
-no-color                   # Disable colors
-lock-timeout=DURATION      # Lock timeout
-parallelism=N              # Concurrent operations
-var='KEY=VALUE'            # Set variable
-var-file=FILE              # Variable file
-target=RESOURCE            # Target specific resource
-replace=RESOURCE           # Force replacement
```

**Examples**:
```bash
# Apply saved plan (recommended)
terraform apply tfplan

# Direct apply with approval
terraform apply

# Auto-approve (CI/CD only!)
terraform apply -auto-approve

# With variables
terraform apply -var-file="prod.tfvars"

# Target specific resource
terraform apply -target=azurerm_storage_account.data

# Force replace
terraform apply -replace=azurerm_virtual_machine.web

# Production apply with safety
terraform apply \
  -lock-timeout=30m \
  -input=false \
  tfplan

# Different directory
terraform -chdir=production apply tfplan

# Slow down for rate limiting
terraform apply -parallelism=5
```

### terraform destroy

**Purpose**: Destroy Terraform-managed infrastructure.

**Flags**:
```bash
-auto-approve               # Skip confirmation
-target=RESOURCE            # Destroy specific resource
-var='KEY=VALUE'            # Set variable
-var-file=FILE              # Variable file
-parallelism=N              # Concurrent operations
```

**Examples**:
```bash
# Destroy with confirmation
terraform destroy

# Auto-approve (dangerous!)
terraform destroy -auto-approve

# Destroy specific resource
terraform destroy -target=azurerm_virtual_machine.temp

# With variables
terraform destroy -var-file="dev.tfvars"

# Destroy in specific directory
terraform -chdir=temp-environment destroy -auto-approve
```

### terraform validate

**Purpose**: Validate configuration syntax and consistency.

**Flags**:
```bash
-json                       # JSON output
-no-color                   # Disable colors
```

**Examples**:
```bash
# Basic validation
terraform validate

# JSON output for CI/CD
terraform validate -json

# Validate module
terraform -chdir=modules/networking validate

# In CI/CD pipeline
terraform validate -json | jq '.valid'
```

### terraform fmt

**Purpose**: Format Terraform configuration files.

**Flags**:
```bash
-check                      # Check if files are formatted (exit 3 if not)
-diff                       # Show formatting differences
-recursive                  # Process subdirectories
-write=false                # Don't write changes
-list=false                 # Don't list modified files
```

**Examples**:
```bash
# Format all files
terraform fmt

# Format recursively
terraform fmt -recursive

# Check only (CI/CD)
terraform fmt -check -recursive

# Show what will change
terraform fmt -diff -recursive

# Check without modifying
terraform fmt -check -diff -write=false

# CI/CD validation
if ! terraform fmt -check -recursive; then
  echo "Files are not formatted"
  exit 1
fi
```

### terraform state

**Purpose**: Advanced state management operations.

**Subcommands**:
```bash
terraform state list        # List resources
terraform state show        # Show resource details
terraform state mv          # Move/rename resource
terraform state rm          # Remove resource from state
terraform state pull        # Download state
terraform state push        # Upload state
terraform state replace-provider # Replace provider
```

**Examples**:
```bash
# List all resources
terraform state list

# Show specific resource
terraform state show 'azurerm_resource_group.main'

# Move/rename resource
terraform state mv azurerm_rg.old azurerm_rg.new

# Move to module
terraform state mv azurerm_vnet.main module.networking.azurerm_vnet.main

# Remove from state
terraform state rm azurerm_resource_group.temp

# Pull state for backup
terraform state pull > backup.tfstate

# Different directory
terraform -chdir=prod state list
```

### terraform import

**Purpose**: Import existing infrastructure into Terraform.

**Flags**:
```bash
-config=PATH                # Configuration directory
-input=false                # Don't prompt
-lock-timeout=DURATION      # Lock timeout
-var='KEY=VALUE'            # Set variable
-var-file=FILE              # Variable file
```

**Examples**:
```bash
# Import Azure resource
terraform import azurerm_resource_group.main /subscriptions/.../resourceGroups/my-rg

# Import with variables
terraform import -var-file="prod.tfvars" aws_instance.web i-1234567890

# Different directory
terraform -chdir=networking import azurerm_vnet.main /subscriptions/.../virtualNetworks/vnet
```

### terraform output

**Purpose**: Read output values from state.

**Flags**:
```bash
-json                       # JSON format
-raw                        # Raw string (no quotes)
-no-color                   # Disable colors
-state=PATH                 # State file path
```

**Examples**:
```bash
# All outputs
terraform output

# Specific output
terraform output resource_group_name

# JSON format
terraform output -json

# Raw value (for scripts)
VM_IP=$(terraform output -raw vm_ip_address)

# Save to file
terraform output -json > outputs.json

# Different directory
terraform -chdir=networking output -json
```

### terraform workspace

**Purpose**: Manage workspaces.

**Commands**:
```bash
terraform workspace list            # List workspaces
terraform workspace show            # Show current
terraform workspace new NAME        # Create workspace
terraform workspace select NAME     # Switch workspace
terraform workspace delete NAME     # Delete workspace
```

**Examples**:
```bash
# Create and switch to dev workspace
terraform workspace new dev

# Switch to production
terraform workspace select prod

# List all workspaces
terraform workspace list

# Show current workspace
terraform workspace show

# Different directory
terraform -chdir=project workspace list
```

## Environment Variables

### Logging

```bash
# Set log level
export TF_LOG=TRACE     # Most verbose
export TF_LOG=DEBUG
export TF_LOG=INFO
export TF_LOG=WARN
export TF_LOG=ERROR

# Log to file
export TF_LOG_PATH="terraform.log"

# Windows PowerShell
$env:TF_LOG = "DEBUG"
$env:TF_LOG_PATH = "terraform-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

# Provider-specific logging
export TF_LOG_PROVIDER=TRACE
```

### CLI Configuration

```bash
# Global CLI arguments
export TF_CLI_ARGS="-no-color"

# Command-specific arguments
export TF_CLI_ARGS_plan="-out=tfplan"
export TF_CLI_ARGS_apply="-auto-approve"

# Windows
$env:TF_CLI_ARGS_plan = "-out=tfplan -var-file=prod.tfvars"
```

### Plugin Cache

```bash
# Enable plugin cache (speeds up init)
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
mkdir -p $TF_PLUGIN_CACHE_DIR

# Windows
$env:TF_PLUGIN_CACHE_DIR = "$env:USERPROFILE\.terraform.d\plugin-cache"
New-Item -ItemType Directory -Force -Path $env:TF_PLUGIN_CACHE_DIR
```

### Input Control

```bash
# Disable all interactive prompts
export TF_INPUT=false

# Windows
$env:TF_INPUT = "false"
```

## Advanced Patterns

### CI/CD Pipeline Pattern

```bash
# Comprehensive CI/CD command
terraform plan \
  -chdir=terraform \
  -var-file="environments/${ENVIRONMENT}.tfvars" \
  -out=tfplan \
  -lock-timeout=5m \
  -no-color \
  -input=false \
  -detailed-exitcode

# Check exit code
if [ $? -eq 2 ]; then
  echo "Changes detected, proceeding to apply"

  terraform apply \
    -chdir=terraform \
    -lock-timeout=10m \
    -no-color \
    -input=false \
    -auto-approve \
    tfplan
fi
```

### Multi-Environment Management

```bash
#!/bin/bash
# deploy.sh

ENVIRONMENT=$1

terraform -chdir="environments/$ENVIRONMENT" init \
  -backend-config="key=${ENVIRONMENT}.tfstate"

terraform -chdir="environments/$ENVIRONMENT" plan \
  -var-file="${ENVIRONMENT}.tfvars" \
  -out=tfplan

terraform -chdir="environments/$ENVIRONMENT" apply \
  -auto-approve \
  tfplan
```

### Performance Optimization

```bash
# Fast plan for large infrastructure
terraform plan \
  -refresh=false \          # Skip refresh
  -parallelism=50 \         # High parallelism
  -out=tfplan

# Targeted apply for specific changes
terraform apply \
  -target=module.specific_module \
  -parallelism=20
```

## Platform-Specific Usage

### Windows PowerShell

```powershell
# Multi-line commands (backtick)
terraform plan `
  -chdir="C:\terraform\prod" `
  -var-file="prod.tfvars" `
  -out=tfplan `
  -no-color

# With splatting
$planArgs = @(
  '-chdir=C:\terraform\prod'
  '-var-file=prod.tfvars'
  '-out=tfplan'
  '-no-color'
)
terraform plan @planArgs

# In scripts
param(
  [string]$Environment = "dev"
)

terraform -chdir="environments\$Environment" init
terraform -chdir="environments\$Environment" plan -var-file="$Environment.tfvars" -out=tfplan
terraform -chdir="environments\$Environment" apply tfplan
```

### Linux/macOS Bash

```bash
# Multi-line commands (backslash)
terraform plan \
  -chdir=/home/user/terraform/prod \
  -var-file="prod.tfvars" \
  -out=tfplan \
  -no-color

# With arrays
PLAN_ARGS=(
  -chdir=/home/user/terraform/prod
  -var-file=prod.tfvars
  -out=tfplan
  -no-color
)
terraform plan "${PLAN_ARGS[@]}"

# In scripts
#!/bin/bash
set -euo pipefail

ENVIRONMENT=${1:-dev}

terraform -chdir="environments/$ENVIRONMENT" init
terraform -chdir="environments/$ENVIRONMENT" plan -var-file="$ENVIRONMENT.tfvars" -out=tfplan
terraform -chdir="environments/$ENVIRONMENT" apply tfplan
```

### Git Bash on Windows

**Important**: Git Bash automatically converts Unix-style paths, which can break Terraform commands.

```bash
# ❌ BAD - Path conversion breaks this
terraform -chdir=/c/terraform/prod plan

# ✅ GOOD - Use Windows-style paths (forward slashes work)
terraform -chdir=C:/terraform/prod plan

# ✅ GOOD - Use Windows-style paths (backslashes, quoted)
terraform -chdir="C:\terraform\prod" plan

# ✅ GOOD - Disable MSYS path conversion
export MSYS_NO_PATHCONV=1
terraform -chdir=/c/terraform/prod plan

# ✅ GOOD - Use relative paths
cd /c/terraform
terraform -chdir=prod plan
```

**Cross-Platform Script Pattern**:
```bash
#!/bin/bash
set -euo pipefail

# Detect shell environment and adjust paths
if [ -n "$MSYSTEM" ]; then
  # Git Bash on Windows - use Windows paths
  BASE_DIR="C:/terraform"
  export MSYS_NO_PATHCONV=1
else
  # Linux/macOS - use Unix paths
  BASE_DIR="/home/user/terraform"
fi

ENVIRONMENT=${1:-dev}

terraform -chdir="$BASE_DIR/environments/$ENVIRONMENT" init
terraform -chdir="$BASE_DIR/environments/$ENVIRONMENT" plan \
  -var-file="$ENVIRONMENT.tfvars" \
  -out=tfplan
terraform -chdir="$BASE_DIR/environments/$ENVIRONMENT" apply tfplan
```

**Git Bash Best Practices**:
```bash
# 1. Always use Windows-style paths with -chdir
terraform -chdir=C:/terraform/prod plan  # ✅ Works everywhere

# 2. Set MSYS_NO_PATHCONV for scripts with many paths
export MSYS_NO_PATHCONV=1
terraform -chdir=/c/terraform/prod plan
terraform plan -var-file=/c/terraform/prod.tfvars

# 3. Use relative paths when possible
terraform -chdir=../prod plan  # ✅ No conversion issues

# 4. Test path conversion with echo
echo /c/terraform  # Shows what Git Bash will convert to

# 5. Use cygpath for path conversion
WIN_PATH=$(cygpath -w "/c/terraform/prod")  # → C:\terraform\prod
terraform -chdir="$WIN_PATH" plan
```

## Exit Codes

Terraform uses standard exit codes:

- **0**: Success (no changes with -detailed-exitcode)
- **1**: Error
- **2**: Success with changes (with -detailed-exitcode on plan)

```bash
# CI/CD usage
terraform plan -detailed-exitcode
EXIT_CODE=$?

case $EXIT_CODE in
  0)
    echo "No changes needed"
    ;;
  1)
    echo "Plan failed"
    exit 1
    ;;
  2)
    echo "Changes detected, proceeding to apply"
    terraform apply tfplan
    ;;
esac
```

## Best Practices

1. **Use -chdir instead of cd** in all scripts and automation
2. **Save plans with -out** and apply saved plans
3. **Use -detailed-exitcode** in CI/CD for change detection
4. **Set -lock-timeout** for production (e.g., 10m or 30m)
5. **Use -no-color** in CI/CD logs for readability
6. **Enable plugin cache** with TF_PLUGIN_CACHE_DIR
7. **Use -parallelism** to optimize performance (10-50 depending on infrastructure)
8. **Use -refresh=false** when you know state is current
9. **Never use -auto-approve** manually in production
10. **Always specify -var-file** explicitly rather than relying on defaults

## Common Pitfalls

❌ **Using cd instead of -chdir**:
```bash
# Bad
cd terraform/prod
terraform plan

# Good
terraform -chdir=terraform/prod plan
```

❌ **Not saving plans**:
```bash
# Bad
terraform plan
terraform apply  # Different plan!

# Good
terraform plan -out=tfplan
terraform apply tfplan
```

❌ **No lock timeout**:
```bash
# Bad - fails immediately if locked
terraform apply

# Good - waits for lock
terraform apply -lock-timeout=10m tfplan
```

❌ **Missing -detailed-exitcode in CI/CD**:
```bash
# Bad - can't detect changes
terraform plan

# Good - exit code 2 if changes
terraform plan -detailed-exitcode
```

## Quick Reference

```bash
# Initialize
terraform init [-upgrade] [-reconfigure]

# Plan
terraform plan [-out=FILE] [-var-file=FILE] [-target=RESOURCE]

# Apply
terraform apply [tfplan] [-auto-approve]

# Destroy
terraform destroy [-target=RESOURCE] [-auto-approve]

# State
terraform state list|show|mv|rm|pull|push

# Import
terraform import RESOURCE ID

# Output
terraform output [-json] [-raw] [NAME]

# Format
terraform fmt [-check] [-recursive]

# Validate
terraform validate [-json]

# Workspace
terraform workspace list|show|new|select|delete
```

Activate the terraform-expert agent for comprehensive CLI guidance and advanced usage patterns.
