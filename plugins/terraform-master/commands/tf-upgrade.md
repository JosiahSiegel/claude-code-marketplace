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


# Upgrade Terraform and Provider Versions

Safely upgrade Terraform core, providers, and handle version migrations with breaking change awareness.

## Your Task

You are helping upgrade Terraform versions or provider versions. Follow systematic upgrade procedures with comprehensive testing.

## Before Upgrading

### 1. Assess Current State

```bash
# Check current Terraform version
terraform version

# Check provider versions
terraform providers

# Review lock file
cat .terraform.lock.hcl

# Check for deprecated features
terraform plan  # Look for deprecation warnings
```

### 2. Review Release Notes

**CRITICAL**: Always review changelogs before upgrading

- **Terraform Core**: https://github.com/hashicorp/terraform/blob/main/CHANGELOG.md
- **Azure Provider**: https://github.com/hashicorp/terraform-provider-azurerm/blob/main/CHANGELOG.md
- **AWS Provider**: https://github.com/hashicorp/terraform-provider-aws/blob/main/CHANGELOG.md
- **Google Provider**: https://github.com/hashicorp/terraform-provider-google/blob/main/CHANGELOG.md

**Look for**:
- Breaking changes
- Deprecated resources/attributes
- New features
- Bug fixes
- Security updates

### 3. Backup

```bash
# Backup state file
terraform state pull > terraform.tfstate.backup-$(date +%Y%m%d-%H%M%S)

# Backup configuration
git commit -am "Pre-upgrade backup"
git tag pre-upgrade-$(date +%Y%m%d)

# Create branch for upgrade
git checkout -b upgrade/terraform-1.7
```

## Upgrading Terraform Core

### Version Migration Paths

**Major Version Upgrades**: Must be done sequentially
```bash
# Cannot jump directly from 0.12 to 1.5
# Must upgrade: 0.12 → 0.13 → 0.14 → 0.15 → 1.x

# Each major version requires:
1. Review upgrade guide
2. Run upgrade command (if available)
3. Update configuration
4. Test thoroughly
```

### Terraform 0.12 → 0.13

```bash
# 1. Upgrade to latest 0.12
terraform init -upgrade
terraform apply

# 2. Install Terraform 0.13
# Download from: https://releases.hashicorp.com/terraform/

# 3. Run upgrade command
terraform 0.13upgrade .

# This creates versions.tf with required_providers block

# 4. Initialize with 0.13
terraform init

# 5. Test
terraform plan
terraform apply
```

**Key Changes**:
- required_providers block mandatory
- Provider source addresses
- Module count/for_each support

### Terraform 0.13 → 0.14

```bash
# 1. Upgrade to latest 0.13
terraform init -upgrade

# 2. Install Terraform 0.14
# 3. Initialize
terraform init

# 4. Review lock file
cat .terraform.lock.hcl
```

**Key Changes**:
- Dependency lock file (.terraform.lock.hcl)
- Sensitive output values
- Provider development improvements

### Terraform 0.14 → 0.15

```bash
# Direct upgrade
terraform init -upgrade
```

**Key Changes**:
- Module expansion (count/for_each in modules)
- Provider configuration in modules
- Upgrade warnings for deprecated features

### Terraform 0.15 → 1.0

```bash
# Direct upgrade (minimal breaking changes)
terraform init -upgrade
```

**Key Changes**:
- Long-term stability commitment
- Minimal breaking changes (mostly removed deprecated features)

### Terraform 1.x Upgrades

**1.0 → 1.1 → 1.2 → 1.3 → 1.4 → 1.5 → 1.6 → 1.7+**

```bash
# Generally safe to upgrade within 1.x
terraform init -upgrade
terraform plan
```

**Notable Features by Version**:

**1.1**:
- refactoring (moved blocks)
- Improved upgrade safety

**1.2**:
- Preconditions and Postconditions
- Lifecycle.replace_triggered_by

**1.3**:
- optional() with defaults
- Moved blocks enhancement

**1.4**:
- `terraform test` command (experimental)

**1.5**:
- Import blocks (config-driven import)
- check blocks
- S3 state locking improvements

**1.6**:
- Enhanced testing framework
- Provider-defined functions

**1.7**:
- removed blocks
- Provider functions generally available

### Installation Methods

**Windows**:
```powershell
# Chocolatey
choco upgrade terraform

# Manual
# Download from https://www.terraform.io/downloads
# Extract to PATH location

# Verify
terraform version
```

**macOS**:
```bash
# Homebrew
brew upgrade terraform

# Or specific version
brew install terraform@1.6

# tfenv (version manager)
brew install tfenv
tfenv install 1.7.0
tfenv use 1.7.0
```

**Linux**:
```bash
# Download and install
wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip
unzip terraform_1.7.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Or use package manager (varies by distro)

# tfenv (version manager)
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc
tfenv install 1.7.0
tfenv use 1.7.0
```

### Version Constraints

**Update versions.tf**:
```hcl
terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}
```

## Upgrading Providers

### Provider Version Upgrade Process

**1. Review Provider Changelog**

Example: AzureRM 2.x → 3.x
- Many resources renamed
- Properties changed
- New authentication methods
- Breaking changes in features block

**2. Update Version Constraint**:
```hcl
# versions.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"  # Update from ~> 2.x
    }
  }
}
```

**3. Upgrade Provider**:
```bash
# Upgrade provider and update lock file
terraform init -upgrade

# Or upgrade specific provider
terraform init -upgrade=hashicorp/azurerm
```

**4. Check for Deprecated Resources/Attributes**:
```bash
# Run plan to see deprecation warnings
terraform plan

# Example warnings:
# Warning: Argument is deprecated
# Warning: Resource is deprecated, use X instead
```

**5. Update Configuration**:

**Example: AzureRM 2.x → 3.x Breaking Changes**

```hcl
# OLD (v2)
resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

# NEW (v3) - Multiple ip_configuration blocks
resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}
```

**6. Handle Resource Renames**:

```bash
# If provider renames resources, use state mv

# Example: azurerm_mssql_server → azurerm_sql_server (hypothetical)
terraform state mv azurerm_mssql_server.example azurerm_sql_server.example

# Update code to match
```

**7. Test**:
```bash
# Validate syntax
terraform validate

# Plan and review
terraform plan

# Should show no changes if upgrade successful
# Apply if needed
terraform apply
```

### Common Provider Upgrades

**AzureRM 3.x → 4.x**:
```bash
# Review: https://github.com/hashicorp/terraform-provider-azurerm/blob/main/CHANGELOG.md

# Key changes (example - check actual changelog):
# - New authentication methods
# - Resource updates
# - Features block changes
```

**AWS 4.x → 5.x**:
```bash
# Review: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/version-5-upgrade

# Key changes:
# - Provider authentication changes
# - Default tags handling
# - Resource updates
# - Deprecated resources removed
```

### Multiple Provider Upgrade

```bash
# Upgrade all providers
terraform init -upgrade

# Review what changed
git diff .terraform.lock.hcl

# Test
terraform plan
```

## Automated Upgrade Testing

### CI/CD Upgrade Testing

**GitHub Actions**:
```yaml
name: Test Terraform Upgrade

on:
  workflow_dispatch:
    inputs:
      terraform_version:
        description: 'Terraform version to test'
        required: true
        default: '1.7.0'

jobs:
  test-upgrade:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Terraform (Current)
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.6.0

      - name: Backup State
        run: terraform state pull > state-backup.json

      - name: Setup Terraform (New Version)
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: ${{ github.event.inputs.terraform_version }}

      - name: Init and Plan
        run: |
          terraform init -upgrade
          terraform plan -detailed-exitcode
        continue-on-error: true

      - name: Report Results
        run: |
          echo "Upgrade test completed"
          # Add notification logic
```

## Handling Breaking Changes

### State Manipulation

**Moving Resources**:
```bash
# Before applying breaking changes
# Move resource in state to match new configuration

# Example: Resource type changed
terraform state mv azurerm_old_resource.example azurerm_new_resource.example

# Example: Resource renamed
terraform state mv module.old_name module.new_name
```

**Import Resources**:
```bash
# If resource needs to be recreated with new structure
# 1. Import existing resource
terraform import azurerm_resource.example /subscriptions/.../resourceGroups/.../providers/...

# 2. Update configuration to match
# 3. Plan should show no changes
terraform plan
```

**Remove from State**:
```bash
# If removing resource management from Terraform
terraform state rm azurerm_resource.example

# Resource still exists in Azure/AWS/GCP, just not managed by Terraform
```

## Rollback Procedures

### Rollback Terraform Version

```bash
# Using tfenv
tfenv use 1.6.0

# Or reinstall specific version
# Download from releases page

# Reinitialize
terraform init
```

### Rollback Provider Version

```hcl
# 1. Update versions.tf to previous version
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.75"  # Rollback from 3.80
    }
  }
}

# 2. Delete lock file
rm .terraform.lock.hcl

# 3. Reinitialize
terraform init

# 4. Restore configuration
git checkout previous-commit
```

### Restore State

```bash
# If upgrade corrupted state
terraform state push terraform.tfstate.backup-20240101
```

## Upgrade Checklist

### Pre-Upgrade
- [ ] Review release notes and changelog
- [ ] Identify breaking changes
- [ ] Backup state file
- [ ] Commit current configuration
- [ ] Create git tag/branch
- [ ] Test in non-production first
- [ ] Plan rollback procedure

### During Upgrade
- [ ] Update version constraints
- [ ] Run `terraform init -upgrade`
- [ ] Review lock file changes
- [ ] Run `terraform plan`
- [ ] Check for deprecation warnings
- [ ] Update configuration for breaking changes
- [ ] Handle resource renames/moves
- [ ] Validate with `terraform validate`

### Post-Upgrade
- [ ] Test in development environment
- [ ] Run full test suite
- [ ] Update documentation
- [ ] Update CI/CD pipelines
- [ ] Train team on new features
- [ ] Monitor for issues
- [ ] Document any workarounds

## Platform-Specific Considerations

**Windows**:
- Update PATH if manual installation
- PowerShell execution policy
- Line ending issues (git config)

**Linux**:
- Update package manager cache
- Check binary permissions
- Update shell configuration

**macOS**:
- Homebrew link management
- Quarantine attributes on binaries

**CI/CD**:
- Update pipeline Terraform version
- Update Docker images
- Update pre-installed tools

## Critical Warnings

- 🔴 NEVER upgrade directly to production
- 🔴 ALWAYS test in dev/staging first
- 🔴 ALWAYS backup state before upgrading
- 🔴 ALWAYS review changelogs for breaking changes
- 🔴 NEVER skip major versions for Terraform core
- ⚠️ PLAN for rollback procedure before upgrading
- ⚠️ TEST thoroughly after upgrade
- ⚠️ UPDATE team before production upgrade

Activate the terraform-expert agent for version-specific upgrade guidance and troubleshooting.
