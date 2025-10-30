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


# Manage Terraform State

Comprehensive state management operations including moving, removing, inspecting, and manipulating Terraform state across all platforms.

## Your Task

You are helping manage Terraform state. Provide systematic guidance for state operations with safety checks and platform-specific considerations.

## State Commands Overview

```bash
terraform state list              # List all resources in state
terraform state show <address>    # Show detailed resource information
terraform state mv <source> <dest> # Move/rename resource in state
terraform state rm <address>      # Remove resource from state
terraform state pull              # Download and display state
terraform state push <file>       # Upload state file (dangerous!)
terraform state replace-provider  # Replace provider in state
```

## State Inspection

### List Resources

**Basic List**:
```bash
# List all resources
terraform state list

# Example output:
# azurerm_resource_group.example
# azurerm_virtual_network.vnet
# azurerm_subnet.subnet[0]
# azurerm_subnet.subnet[1]
# module.networking.azurerm_network_security_group.nsg
```

**Filter List**:
```bash
# List specific resource type
terraform state list | grep azurerm_virtual_network

# List resources in module
terraform state list | grep "module.networking"

# List resources with index
terraform state list | grep "\\[0\\]"
```

**Platform-Specific**:
```powershell
# Windows PowerShell
terraform state list | Select-String "azurerm_virtual_machine"

# Linux/macOS
terraform state list | grep "aws_instance"
```

### Show Resource Details

**Show Specific Resource**:
```bash
# Show resource attributes
terraform state show azurerm_resource_group.example

# Example output:
# azurerm_resource_group.example:
# resource "azurerm_resource_group" "example" {
#     id       = "/subscriptions/.../resourceGroups/my-rg"
#     location = "eastus"
#     name     = "my-rg"
#     tags     = {}
# }
```

**Show Resource in Module**:
```bash
terraform state show 'module.networking.azurerm_virtual_network.vnet'
```

**Show Indexed Resource**:
```bash
terraform state show 'azurerm_subnet.subnet[0]'
terraform state show 'azurerm_subnet.subnet["app"]'
```

### Pull State

**Download State**:
```bash
# Pull current state
terraform state pull > current-state.json

# View state
cat current-state.json | jq .

# Extract specific information
cat current-state.json | jq '.resources[] | select(.type=="azurerm_virtual_network")'
```

**Platform-Specific**:
```powershell
# Windows PowerShell
terraform state pull | Out-File -Encoding UTF8 current-state.json
Get-Content current-state.json | ConvertFrom-Json | ConvertTo-Json -Depth 10
```

## Moving Resources

### Rename Resource

**Simple Rename**:
```bash
# Rename resource
terraform state mv azurerm_resource_group.old azurerm_resource_group.new

# Verify
terraform state list | grep azurerm_resource_group
```

**Rename with Quotes** (special characters):
```bash
terraform state mv 'azurerm_subnet.subnet[0]' 'azurerm_subnet.app_subnet[0]'
```

### Move Between Modules

**Move to Module**:
```bash
# Move resource into module
terraform state mv azurerm_virtual_network.vnet module.networking.azurerm_virtual_network.vnet
```

**Move out of Module**:
```bash
# Move resource out of module
terraform state mv module.networking.azurerm_virtual_network.vnet azurerm_virtual_network.vnet
```

**Move Between Modules**:
```bash
# Move from one module to another
terraform state mv module.old_networking.azurerm_vnet.main module.new_networking.azurerm_vnet.main
```

### Move with Count/For_Each

**Count to For_Each**:
```bash
# Old: resource with count
# resource "azurerm_subnet" "subnet" {
#   count = 2
# }

# New: resource with for_each
# resource "azurerm_subnet" "subnet" {
#   for_each = {
#     app = {...}
#     db  = {...}
#   }
# }

# Move count[0] to for_each["app"]
terraform state mv 'azurerm_subnet.subnet[0]' 'azurerm_subnet.subnet["app"]'
terraform state mv 'azurerm_subnet.subnet[1]' 'azurerm_subnet.subnet["db"]'
```

**For_Each to For_Each** (rename keys):
```bash
# Rename for_each key
terraform state mv 'azurerm_subnet.subnet["old_key"]' 'azurerm_subnet.subnet["new_key"]'
```

### Move Between States

**Export from One State**:
```bash
# In source directory
terraform state pull > resource-to-move.json

# Extract specific resource (manual JSON editing or jq)
cat resource-to-move.json | jq '.resources[] | select(.type=="azurerm_resource_group")' > rg.json
```

**Move Resource to Different State**:
```bash
# Source state
terraform state rm azurerm_resource_group.example

# Target state (different directory/workspace)
cd ../target-terraform
terraform import azurerm_resource_group.example /subscriptions/.../resourceGroups/my-rg
```

**Platform-Specific Multi-State Move**:
```powershell
# Windows PowerShell
# Source
Push-Location source-terraform
terraform state rm azurerm_resource_group.example
$resourceId = "/subscriptions/.../resourceGroups/my-rg"
Pop-Location

# Target
Push-Location target-terraform
terraform import azurerm_resource_group.example $resourceId
Pop-Location
```

## Removing Resources

### Remove from State

**Remove Single Resource**:
```bash
# Remove resource from state (resource still exists in cloud)
terraform state rm azurerm_resource_group.example

# Verify removal
terraform state list | grep azurerm_resource_group
```

**Remove Multiple Resources**:
```bash
# Remove multiple resources
terraform state rm azurerm_subnet.subnet[0] azurerm_subnet.subnet[1]

# Remove all resources of type
terraform state list | grep azurerm_subnet | xargs terraform state rm
```

**Remove Module**:
```bash
# Remove entire module
terraform state rm module.networking

# Or specific resources in module
terraform state rm $(terraform state list | grep "module.networking")
```

**Platform-Specific Bulk Remove**:
```powershell
# Windows PowerShell
terraform state list | Select-String "azurerm_subnet" | ForEach-Object { terraform state rm $_.Line }

# Linux/macOS
terraform state list | grep "azurerm_subnet" | xargs -I {} terraform state rm {}
```

### When to Remove

**Use Cases**:
- Resource deleted manually outside Terraform
- Moving resource to different state
- Decomissioning infrastructure
- Splitting monolithic state
- Resource no longer needed in Terraform management

**Important**: `terraform state rm` only removes from state, not from cloud provider!

## State Backup and Recovery

### Manual Backup

**Before Major Changes**:
```bash
# Backup state before risky operations
terraform state pull > terraform.tfstate.backup-$(date +%Y%m%d-%H%M%S)

# Platform-specific
# Windows PowerShell
terraform state pull | Out-File "terraform.tfstate.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

# Verify backup
ls -lh terraform.tfstate.backup-*
```

### Restore from Backup

**Push State**:
```bash
# ⚠️ DANGEROUS - Overwrites current state
terraform state push terraform.tfstate.backup-20240101-120000

# With confirmation
terraform state push -lock=true terraform.tfstate.backup-20240101-120000
```

**Restore from Backend Versioning**:

**Azure Storage**:
```bash
# List versions
az storage blob list --account-name tfstate --container-name tfstate --prefix terraform.tfstate --include snapshots

# Download specific version
az storage blob download \
  --account-name tfstate \
  --container-name tfstate \
  --name terraform.tfstate \
  --version-id "2024-01-01T12:00:00.0000000Z" \
  --file terraform.tfstate.backup

# Push restored state
terraform state push terraform.tfstate.backup
```

**AWS S3**:
```bash
# List versions
aws s3api list-object-versions --bucket terraform-state --prefix terraform.tfstate

# Download specific version
aws s3api get-object \
  --bucket terraform-state \
  --key terraform.tfstate \
  --version-id "VersionId123" \
  terraform.tfstate.backup

# Push restored state
terraform state push terraform.tfstate.backup
```

## Advanced State Operations

### Replace Provider

**Change Provider Configuration**:
```bash
# When migrating provider namespaces
terraform state replace-provider registry.terraform.io/-/azurerm hashicorp/azurerm

# When changing provider source
terraform state replace-provider registry.terraform.io/hashicorp/azurerm registry.terraform.io/custom/azurerm
```

### State Locking

**Check Lock Status**:
```bash
# Lock should happen automatically
# If locked, you'll see:
# Error: Error acquiring the state lock
# Lock Info:
#   ID:        xxxxx
#   Path:      terraform.tfstate
#   Operation: OperationTypeApply
#   Who:       user@hostname
#   Created:   2024-01-01 12:00:00 UTC
```

**Force Unlock** (⚠️ Use with extreme caution):
```bash
# Only use if you're certain no other process is running
terraform force-unlock <LOCK_ID>

# Example
terraform force-unlock a1b2c3d4-5678-90ab-cdef-1234567890ab
```

**Platform-Specific Lock Management**:

**Azure Storage** (Blob Lease):
```bash
# Check blob lease status
az storage blob show \
  --account-name tfstate \
  --container-name tfstate \
  --name terraform.tfstate \
  --query properties.lease

# Break lease (emergency only)
az storage blob lease break \
  --account-name tfstate \
  --container-name tfstate \
  --blob-name terraform.tfstate
```

**AWS DynamoDB**:
```bash
# Check lock table
aws dynamodb get-item \
  --table-name terraform-locks \
  --key '{"LockID":{"S":"terraform-state/terraform.tfstate-md5"}}'

# Delete lock (emergency only)
aws dynamodb delete-item \
  --table-name terraform-locks \
  --key '{"LockID":{"S":"terraform-state/terraform.tfstate-md5"}}'
```

## State Migration Scenarios

### Scenario 1: Split Monolithic State

**Process**:
```bash
# 1. Backup original state
terraform state pull > monolithic-backup.json

# 2. Create new state directories
mkdir networking compute storage

# 3. Move resources
# In original directory
terraform state rm azurerm_virtual_network.vnet azurerm_subnet.subnet

# In networking directory
cd networking
terraform import azurerm_virtual_network.vnet /subscriptions/.../virtualNetworks/my-vnet
terraform import azurerm_subnet.subnet /subscriptions/.../subnets/my-subnet

# 4. Verify each state
terraform plan  # Should show no changes
```

### Scenario 2: Merge States

**Process**:
```bash
# 1. Backup all states
cd state1 && terraform state pull > state1-backup.json
cd ../state2 && terraform state pull > state2-backup.json

# 2. Remove from source state
cd ../state2
terraform state rm azurerm_resource_group.example

# 3. Import to target state
cd ../state1
terraform import azurerm_resource_group.example /subscriptions/.../resourceGroups/my-rg

# 4. Verify
terraform plan
```

### Scenario 3: Refactor Module Structure

**Old Structure**:
```hcl
# main.tf
resource "azurerm_virtual_network" "vnet" {}
resource "azurerm_subnet" "subnet" {}
```

**New Structure**:
```hcl
# main.tf
module "networking" {
  source = "./modules/networking"
}

# modules/networking/main.tf
resource "azurerm_virtual_network" "vnet" {}
resource "azurerm_subnet" "subnet" {}
```

**Migration**:
```bash
# Move resources to module
terraform state mv azurerm_virtual_network.vnet module.networking.azurerm_virtual_network.vnet
terraform state mv azurerm_subnet.subnet module.networking.azurerm_subnet.subnet

# Verify
terraform plan  # Should show no changes
```

### Scenario 4: Rename Resources

**Process**:
```bash
# 1. Update configuration
# OLD: resource "azurerm_resource_group" "rg"
# NEW: resource "azurerm_resource_group" "main"

# 2. Move in state
terraform state mv azurerm_resource_group.rg azurerm_resource_group.main

# 3. Verify
terraform plan  # Should show no changes
```

## State File Format

**Structure**:
```json
{
  "version": 4,
  "terraform_version": "1.7.0",
  "serial": 123,
  "lineage": "uuid",
  "outputs": {},
  "resources": [
    {
      "mode": "managed",
      "type": "azurerm_resource_group",
      "name": "example",
      "provider": "provider[\"registry.terraform.io/hashicorp/azurerm\"]",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "id": "/subscriptions/.../resourceGroups/my-rg",
            "location": "eastus",
            "name": "my-rg"
          }
        }
      ]
    }
  ]
}
```

**Key Fields**:
- `version`: State format version
- `terraform_version`: Terraform version that created state
- `serial`: Incremented on each state change
- `lineage`: Unique ID for state file lifecycle
- `resources`: Array of all resources

## Troubleshooting State Issues

### Issue: State Drift

**Diagnosis**:
```bash
# Check for drift
terraform plan -refresh-only

# Shows resources changed outside Terraform
```

**Fix**:
```bash
# Option 1: Update state to match reality
terraform apply -refresh-only

# Option 2: Update infrastructure to match state
terraform apply
```

### Issue: Resource in State But Deleted in Cloud

**Diagnosis**:
```bash
# Plan shows error: resource not found
terraform plan
```

**Fix**:
```bash
# Remove from state
terraform state rm azurerm_resource_group.deleted

# Or refresh state (removes missing resources)
terraform apply -refresh-only
```

### Issue: Duplicate Resources

**Diagnosis**:
```bash
# Plan shows resource already exists
terraform plan
# Error: A resource with the ID "..." already exists
```

**Fix**:
```bash
# Import existing resource
terraform import azurerm_resource_group.example /subscriptions/.../resourceGroups/my-rg

# Or remove and recreate in Terraform
terraform state rm azurerm_resource_group.example
terraform apply  # Creates new resource
```

### Issue: State Locked

**Diagnosis**:
```bash
terraform apply
# Error: Error acquiring the state lock
```

**Fix**:
```bash
# 1. Wait for lock to release (another operation running)

# 2. Check if process is stuck
# Kill stuck process if necessary

# 3. Force unlock (last resort)
terraform force-unlock <LOCK_ID>
```

### Issue: Corrupted State

**Diagnosis**:
```bash
terraform plan
# Error: Failed to load state
# Error: state snapshot was created by Terraform vX, but this is vY
```

**Fix**:
```bash
# Restore from backup
terraform state push terraform.tfstate.backup

# Or restore from backend versioning
# (Azure Storage, S3, etc.)
```

## State Best Practices

### Safety Checklist
- [ ] ALWAYS backup state before major operations
- [ ] TEST state moves in non-production first
- [ ] VERIFY with terraform plan after state operations
- [ ] USE version control for state backups
- [ ] ENABLE backend versioning (S3, Azure Storage)
- [ ] RESTRICT state access (IAM/RBAC)
- [ ] NEVER manually edit state JSON
- [ ] USE state locking always

### Regular Maintenance
- [ ] Review state size (keep under 100MB)
- [ ] Remove orphaned resources
- [ ] Clean up old backups
- [ ] Audit state access logs
- [ ] Test state restore procedures
- [ ] Document state structure

### Migration Best Practices
- [ ] Plan migration carefully
- [ ] Document all state moves
- [ ] Backup before every operation
- [ ] Verify after each move
- [ ] Test in non-production first
- [ ] Communicate with team
- [ ] Update documentation

## Platform-Specific Scripts

### Bulk State Operations (PowerShell)

```powershell
# Remove all resources of specific type
function Remove-TerraformResourceType {
    param([string]$ResourceType)

    $resources = terraform state list | Select-String $ResourceType

    foreach ($resource in $resources) {
        Write-Host "Removing $($resource.Line)"
        terraform state rm $resource.Line
    }
}

# Usage
Remove-TerraformResourceType "azurerm_subnet"
```

### Bulk State Operations (Bash)

```bash
#!/bin/bash
# Remove all resources of specific type

remove_resource_type() {
    local resource_type=$1

    terraform state list | grep "$resource_type" | while read -r resource; do
        echo "Removing $resource"
        terraform state rm "$resource"
    done
}

# Usage
remove_resource_type "aws_security_group_rule"
```

## Critical Warnings

- 🔴 NEVER manually edit state JSON files
- 🔴 ALWAYS backup state before operations
- 🔴 VERIFY changes with terraform plan
- 🔴 TEST in non-production first
- 🔴 NEVER force-unlock unless certain no other process running
- 🔴 NEVER push state without verification
- ⚠️ State rm only removes from state, not from cloud
- ⚠️ State mv can break references if not careful
- ⚠️ State push overwrites remote state

## State Command Reference

```bash
# Inspection
terraform state list                          # List all resources
terraform state show <address>                # Show resource details
terraform state pull                          # Download state

# Modification
terraform state mv <source> <dest>            # Move/rename resource
terraform state rm <address>                  # Remove resource
terraform state push <file>                   # Upload state (dangerous!)
terraform state replace-provider <old> <new>  # Replace provider

# Recovery
terraform force-unlock <LOCK_ID>              # Force unlock (caution!)
```

Activate the terraform-expert agent for comprehensive state management guidance and troubleshooting.
