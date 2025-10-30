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


# Import Existing Resources into Terraform

Import existing cloud infrastructure into Terraform management with comprehensive strategies for single resources, bulk imports, and migration from manual deployments.

## Your Task

You are helping import existing infrastructure into Terraform. Provide systematic guidance for importing resources across all cloud providers and platforms.

## Import Strategies

### 1. Single Resource Import (Traditional Method)

**Basic Syntax**:
```bash
terraform import <RESOURCE_TYPE>.<NAME> <RESOURCE_ID>
```

**Azure Examples**:
```bash
# Resource Group
terraform import azurerm_resource_group.example /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg

# Virtual Network
terraform import azurerm_virtual_network.example /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/my-vnet

# Storage Account
terraform import azurerm_storage_account.example /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.Storage/storageAccounts/mystorageaccount

# Virtual Machine
terraform import azurerm_linux_virtual_machine.example /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.Compute/virtualMachines/my-vm
```

**AWS Examples**:
```bash
# VPC
terraform import aws_vpc.example vpc-a01106c2

# EC2 Instance
terraform import aws_instance.example i-1234567890abcdef0

# S3 Bucket
terraform import aws_s3_bucket.example my-bucket-name

# RDS Instance
terraform import aws_db_instance.example mydb
```

**GCP Examples**:
```bash
# GCS Bucket
terraform import google_storage_bucket.example my-bucket

# Compute Instance
terraform import google_compute_instance.example projects/my-project/zones/us-central1-a/instances/my-instance

# VPC Network
terraform import google_compute_network.example projects/my-project/global/networks/my-network
```

### 2. Import Blocks (Terraform 1.5+)

**Modern Declarative Import**:
```hcl
# import.tf
import {
  to = azurerm_resource_group.example
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg"
}

import {
  to = azurerm_virtual_network.vnet
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/my-vnet"
}

import {
  to = azurerm_storage_account.storage
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.Storage/storageAccounts/mystorageaccount"
}
```

**Workflow**:
```bash
# 1. Create import blocks
# 2. Generate configuration
terraform plan -generate-config-out=generated.tf

# 3. Review generated configuration
cat generated.tf

# 4. Move to appropriate files
mv generated.tf main.tf

# 5. Execute import
terraform apply

# 6. Verify
terraform plan  # Should show no changes
```

**Advantages**:
- Declarative approach
- Configuration generation
- Version controlled imports
- Repeatable process
- Easier to review

## Import Process

### Step 1: Inventory Existing Resources

**Azure**:
```bash
# List all resources in subscription
az resource list --query "[].{name:name, type:type, id:id}" -o table

# List resources in resource group
az resource list --resource-group my-rg -o table

# Export resource group details
az group show --name my-rg

# List specific resource types
az network vnet list -o table
az vm list -o table
az storage account list -o table
```

**AWS**:
```bash
# List EC2 instances
aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,Tags[?Key==`Name`].Value|[0]]' --output table

# List S3 buckets
aws s3 ls

# List VPCs
aws ec2 describe-vpcs --query 'Vpcs[].[VpcId,Tags[?Key==`Name`].Value|[0]]' --output table

# List RDS instances
aws rds describe-db-instances --query 'DBInstances[].[DBInstanceIdentifier,Engine]' --output table
```

**GCP**:
```bash
# List all resources
gcloud asset search-all-resources --scope=projects/my-project

# List compute instances
gcloud compute instances list

# List storage buckets
gcloud storage buckets list

# List networks
gcloud compute networks list
```

### Step 2: Get Resource IDs

**Azure Resource ID Format**:
```
/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/{provider-namespace}/{resource-type}/{resource-name}
```

**Get Azure Resource IDs**:
```bash
# Specific resource
az resource show --resource-group my-rg --name my-vnet --resource-type "Microsoft.Network/virtualNetworks" --query id -o tsv

# All resources in RG
az resource list --resource-group my-rg --query "[].id" -o tsv
```

**Get AWS Resource IDs**:
```bash
# EC2 instance
aws ec2 describe-instances --filters "Name=tag:Name,Values=my-instance" --query 'Reservations[0].Instances[0].InstanceId' --output text

# VPC
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=my-vpc" --query 'Vpcs[0].VpcId' --output text
```

### Step 3: Create Terraform Configuration

**Before importing, create matching configuration**:

```hcl
# main.tf
resource "azurerm_resource_group" "example" {
  name     = "my-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "my-vnet"
  address_space       = ["10.0.0.0/16"]  # Must match existing!
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}
```

**Important**: Configuration must match existing resource exactly, or Terraform will plan changes.

### Step 4: Execute Import

**Traditional Import**:
```bash
# Import resources one by one
terraform import azurerm_resource_group.example /subscriptions/.../resourceGroups/my-rg
terraform import azurerm_virtual_network.vnet /subscriptions/.../providers/Microsoft.Network/virtualNetworks/my-vnet
```

**Import Blocks (Terraform 1.5+)**:
```bash
# With import blocks defined
terraform plan -generate-config-out=generated.tf
terraform apply
```

### Step 5: Verify Import

```bash
# Check state
terraform state list

# Verify specific resource
terraform state show azurerm_resource_group.example

# Plan should show no changes
terraform plan

# If changes appear, configuration doesn't match
# Update configuration to match existing resource
```

## Bulk Import Strategies

### Using Scripts

**PowerShell Script for Azure**:
```powershell
# bulk-import-azure.ps1
param(
    [string]$ResourceGroupName,
    [string]$SubscriptionId
)

# Get all resources
$resources = az resource list --resource-group $ResourceGroupName | ConvertFrom-Json

foreach ($resource in $resources) {
    $resourceType = $resource.type
    $resourceName = $resource.name
    $resourceId = $resource.id

    # Map Azure type to Terraform resource type
    $tfResourceType = switch ($resourceType) {
        "Microsoft.Network/virtualNetworks" { "azurerm_virtual_network" }
        "Microsoft.Compute/virtualMachines" { "azurerm_linux_virtual_machine" }
        "Microsoft.Storage/storageAccounts" { "azurerm_storage_account" }
        # Add more mappings...
        default { $null }
    }

    if ($tfResourceType) {
        $tfResourceName = $resourceName -replace '[^a-zA-Z0-9_]', '_'

        Write-Host "Importing $resourceType $resourceName as ${tfResourceType}.${tfResourceName}"

        # Execute import
        terraform import "${tfResourceType}.${tfResourceName}" $resourceId

        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Successfully imported $resourceName" -ForegroundColor Green
        } else {
            Write-Host "✗ Failed to import $resourceName" -ForegroundColor Red
        }
    }
}
```

**Bash Script for AWS**:
```bash
#!/bin/bash
# bulk-import-aws.sh

# Import all EC2 instances with specific tag
for instance_id in $(aws ec2 describe-instances \
    --filters "Name=tag:ManagedBy,Values=Terraform" \
    --query 'Reservations[].Instances[].InstanceId' \
    --output text); do

    instance_name=$(aws ec2 describe-instances \
        --instance-ids $instance_id \
        --query 'Reservations[0].Instances[0].Tags[?Key==`Name`].Value' \
        --output text | tr '[:upper:]' '[:lower:]' | tr ' ' '_')

    echo "Importing EC2 instance: $instance_name ($instance_id)"
    terraform import "aws_instance.${instance_name}" "$instance_id"
done

# Import all S3 buckets
for bucket in $(aws s3 ls | awk '{print $3}'); do
    bucket_name=$(echo $bucket | tr '-' '_')
    echo "Importing S3 bucket: $bucket_name"
    terraform import "aws_s3_bucket.${bucket_name}" "$bucket"
done
```

### Using Terraformer

**Installation**:
```bash
# macOS
brew install terraformer

# Linux
curl -LO https://github.com/GoogleCloudPlatform/terraformer/releases/download/$(curl -s https://api.github.com/repos/GoogleCloudPlatform/terraformer/releases/latest | grep tag_name | cut -d '"' -f 4)/terraformer-linux-amd64
chmod +x terraformer-linux-amd64
sudo mv terraformer-linux-amd64 /usr/local/bin/terraformer

# Windows (Chocolatey)
choco install terraformer
```

**Azure Import**:
```bash
# Import entire resource group
terraformer import azure --resources=resource_group,virtual_network,network_interface,virtual_machine \
    --resource-group=my-rg \
    --subscription-id=00000000-0000-0000-0000-000000000000

# Import specific resources
terraformer import azure --resources=virtual_machine \
    --resource-group=my-rg \
    --filter="Name=name;Value=my-vm"
```

**AWS Import**:
```bash
# Import VPC and related resources
terraformer import aws --resources=vpc,subnet,security_group,route_table \
    --regions=us-east-1 \
    --filter="Name=tags.Environment;Value=production"

# Import EC2 instances
terraformer import aws --resources=ec2_instance \
    --regions=us-east-1,us-west-2 \
    --profile=my-profile
```

**GCP Import**:
```bash
# Import compute resources
terraformer import google --resources=gcs,instances,networks \
    --projects=my-project \
    --regions=us-central1
```

### Using Azure Terraform Export (Azure-specific)

```bash
# Install aztfexport
go install github.com/Azure/aztfexport@latest

# Export resource group
aztfexport resource-group my-rg

# Export specific resource
aztfexport resource /subscriptions/.../resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/my-vnet

# Query mode (interactive)
aztfexport query --interactive
```

## Common Import Scenarios

### Scenario 1: Import Single VM with Dependencies

**Azure**:
```bash
# 1. Resource Group
terraform import azurerm_resource_group.rg /subscriptions/.../resourceGroups/my-rg

# 2. Virtual Network
terraform import azurerm_virtual_network.vnet /subscriptions/.../providers/Microsoft.Network/virtualNetworks/my-vnet

# 3. Subnet
terraform import azurerm_subnet.subnet /subscriptions/.../providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/my-subnet

# 4. Network Interface
terraform import azurerm_network_interface.nic /subscriptions/.../providers/Microsoft.Network/networkInterfaces/my-nic

# 5. Virtual Machine
terraform import azurerm_linux_virtual_machine.vm /subscriptions/.../providers/Microsoft.Compute/virtualMachines/my-vm
```

### Scenario 2: Import Entire Environment

```bash
# Use Terraformer or aztfexport for bulk import
aztfexport resource-group production-rg

# Or use import blocks with generated config
# 1. Create import blocks for all resources
# 2. Generate configuration
terraform plan -generate-config-out=generated.tf

# 3. Organize generated files
# 4. Apply imports
terraform apply
```

### Scenario 3: Migrate from ARM Templates

```bash
# 1. Export ARM template
az group export --name my-rg > template.json

# 2. Use aztfexport or manually create Terraform config

# 3. Import resources
aztfexport resource-group my-rg

# 4. Compare and validate
terraform plan
```

## Troubleshooting Import Issues

### Issue: Configuration Doesn't Match

```bash
# Symptom: After import, plan shows changes

# Solution 1: Use terraform show to see state
terraform state show azurerm_resource_group.example

# Solution 2: Update configuration to match
# Copy values from state to configuration

# Solution 3: Use generated config (Terraform 1.5+)
terraform plan -generate-config-out=reference.tf
# Use reference.tf to update your configuration
```

### Issue: Resource Already in State

```bash
# Error: Resource already managed by Terraform

# Solution: Remove from state first
terraform state rm azurerm_resource_group.example

# Then re-import
terraform import azurerm_resource_group.example /subscriptions/.../resourceGroups/my-rg
```

### Issue: Wrong Resource ID Format

```bash
# Error: invalid resource ID

# Solution: Get correct ID format
# Azure
az resource show --resource-group my-rg --name my-resource --query id

# AWS
aws ec2 describe-instances --instance-ids i-1234567890abcdef0 --query 'Reservations[0].Instances[0].InstanceId'

# GCP
gcloud compute instances describe my-instance --zone=us-central1-a --format='value(selfLink)'
```

### Issue: Provider Authentication

```bash
# Ensure authenticated before import

# Azure
az account show

# AWS
aws sts get-caller-identity

# GCP
gcloud auth list
```

## Import Best Practices

### Pre-Import Checklist
- [ ] Inventory all resources to import
- [ ] Document resource dependencies
- [ ] Determine import order (dependencies first)
- [ ] Backup existing state (if any)
- [ ] Test import in non-production first

### During Import
- [ ] Import in dependency order
- [ ] Verify each import with terraform state show
- [ ] Check for configuration drift
- [ ] Document any issues

### Post-Import
- [ ] Run terraform plan (should show no changes)
- [ ] Organize code into appropriate files
- [ ] Add variable validation
- [ ] Add outputs
- [ ] Format code (terraform fmt)
- [ ] Commit to version control
- [ ] Test in isolated environment

### Configuration Tips
- Start with minimal required attributes
- Use terraform state show to see all attributes
- Add computed attributes gradually
- Use data sources for referenced resources
- Document any deviations from defaults

## Platform-Specific Considerations

### Windows
```powershell
# Escape paths in PowerShell
terraform import 'azurerm_resource_group.example' '/subscriptions/.../resourceGroups/my-rg'

# Or use backtick
terraform import `
    azurerm_resource_group.example `
    /subscriptions/.../resourceGroups/my-rg
```

### Linux/macOS
```bash
# Use quotes for IDs with special characters
terraform import 'azurerm_resource_group.example' '/subscriptions/.../resourceGroups/my-rg'
```

### CI/CD
```yaml
# Import in pipeline (use import blocks)
- name: Terraform Import
  run: |
    terraform apply -auto-approve  # With import blocks

# Verify no drift
- name: Verify No Changes
  run: |
    terraform plan -detailed-exitcode  # Exit 0 if no changes
```

## Import vs. Adopt vs. Refactor

**Import**: Bring existing resources under Terraform management
- Use when: Resources created manually or by other tools
- Result: Resources now managed by Terraform

**Adopt**: Take over management from other Terraform state
- Use when: Splitting/merging states
- Result: Resources moved between states

**Refactor**: Restructure Terraform code
- Use when: Improving code organization
- Result: Same resources, better structure

## Critical Warnings

- ⚠️ ALWAYS backup state before importing
- ⚠️ VERIFY configuration matches exactly before applying
- ⚠️ IMPORT in dependency order (dependencies first)
- ⚠️ TEST import process in non-production first
- ⚠️ NEVER import into production state without testing
- ⚠️ CHECK for drift after import (terraform plan should show no changes)

## Resource ID References

### Azure Resource ID Patterns
```
Resource Group: /subscriptions/{sub}/resourceGroups/{rg}
Virtual Network: /subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Network/virtualNetworks/{name}
Subnet: /subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Network/virtualNetworks/{vnet}/subnets/{name}
VM: /subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Compute/virtualMachines/{name}
Storage: /subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Storage/storageAccounts/{name}
```

### AWS Resource ID Patterns
```
VPC: vpc-xxxxxxxx
Subnet: subnet-xxxxxxxx
EC2 Instance: i-xxxxxxxxxxxxxxxxx
S3 Bucket: bucket-name
RDS: database-name
ELB: arn:aws:elasticloadbalancing:region:account-id:loadbalancer/name
```

### GCP Resource ID Patterns
```
Project: projects/{project-id}
Instance: projects/{project}/zones/{zone}/instances/{name}
Network: projects/{project}/global/networks/{name}
Bucket: bucket-name
```

Activate the terraform-expert agent for comprehensive import guidance and troubleshooting.
