---
description: Automate Azure resources using PowerShell Az module across all platforms
---

# PowerShell Azure Automation

Manage and automate Azure resources using the Az PowerShell module with cross-platform support.

## When to Use

- Automating Azure resource deployment
- Managing Azure VMs, storage, networks
- Querying Azure resource information
- Creating Azure automation scripts
- Troubleshooting Azure PowerShell issues

## Instructions

### 1. Setup & Authentication

```powershell
# Install Az module
Install-Module -Name Az -Scope CurrentUser -Force

# Or install specific sub-modules
Install-Module -Name Az.Accounts, Az.Compute, Az.Storage -Scope CurrentUser

# Import module
Import-Module Az

# Connect to Azure
Connect-AzAccount

# Connect with specific tenant
Connect-AzAccount -Tenant "tenant-id"

# Connect with service principal (automation)
$credential = Get-Credential
Connect-AzAccount -ServicePrincipal -Credential $credential -Tenant "tenant-id"

# Set subscription context
Set-AzContext -Subscription "subscription-name-or-id"

# List available subscriptions
Get-AzSubscription
```

### 2. Resource Groups

```powershell
# List resource groups
Get-AzResourceGroup

# Create resource group
New-AzResourceGroup -Name "MyResourceGroup" -Location "EastUS"

# Get specific resource group
Get-AzResourceGroup -Name "MyResourceGroup"

# Remove resource group
Remove-AzResourceGroup -Name "MyResourceGroup" -Force
```

### 3. Virtual Machines

```powershell
# List VMs
Get-AzVM

# List VMs in specific resource group
Get-AzVM -ResourceGroupName "MyResourceGroup"

# Get VM details
$vm = Get-AzVM -ResourceGroupName "MyRG" -Name "MyVM"
$vm | Select-Object Name, Location, VmSize, ProvisioningState

# Start VM
Start-AzVM -ResourceGroupName "MyRG" -Name "MyVM"

# Stop VM (deallocate)
Stop-AzVM -ResourceGroupName "MyRG" -Name "MyVM" -Force

# Restart VM
Restart-AzVM -ResourceGroupName "MyRG" -Name "MyVM"

# Get VM status
$status = Get-AzVM -ResourceGroupName "MyRG" -Name "MyVM" -Status
$status.Statuses

# Create new VM (simplified)
New-AzVM -ResourceGroupName "MyRG" `
    -Name "NewVM" `
    -Location "EastUS" `
    -Image "UbuntuLTS" `
    -Size "Standard_B2s" `
    -Credential (Get-Credential)
```

### 4. Storage Accounts

```powershell
# List storage accounts
Get-AzStorageAccount

# Create storage account
$storageParams = @{
    ResourceGroupName = "MyRG"
    Name = "mystorageaccount123"
    Location = "EastUS"
    SkuName = "Standard_LRS"
    Kind = "StorageV2"
}
New-AzStorageAccount @storageParams

# Get storage account
$storage = Get-AzStorageAccount -ResourceGroupName "MyRG" -Name "mystorageaccount"

# Get storage account keys
$keys = Get-AzStorageAccountKey -ResourceGroupName "MyRG" -Name "mystorageaccount"

# Create storage context
$ctx = New-AzStorageContext -StorageAccountName "mystorageaccount" -StorageAccountKey $keys[0].Value

# Work with blobs
Get-AzStorageContainer -Context $ctx
New-AzStorageContainer -Name "mycontainer" -Context $ctx -Permission Blob
Set-AzStorageBlobContent -File "localfile.txt" -Container "mycontainer" -Blob "remotefile.txt" -Context $ctx
```

### 5. Networking

```powershell
# List virtual networks
Get-AzVirtualNetwork

# Create virtual network
$subnet = New-AzVirtualNetworkSubnetConfig -Name "default" -AddressPrefix "10.0.0.0/24"
New-AzVirtualNetwork -Name "MyVNet" -ResourceGroupName "MyRG" -Location "EastUS" -AddressPrefix "10.0.0.0/16" -Subnet $subnet

# Get network security groups
Get-AzNetworkSecurityGroup

# Create NSG rule
$nsgRule = New-AzNetworkSecurityRuleConfig -Name "AllowHTTP" `
    -Protocol Tcp -Direction Inbound -Priority 1000 `
    -SourceAddressPrefix * -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 80 `
    -Access Allow

# List public IP addresses
Get-AzPublicIpAddress
```

### 6. Azure Key Vault

```powershell
# Install Key Vault module
Install-Module -Name Az.KeyVault -Scope CurrentUser

# Create Key Vault
New-AzKeyVault -Name "MyKeyVault" -ResourceGroupName "MyRG" -Location "EastUS"

# Set secret
$secretValue = ConvertTo-SecureString "MySecretPassword" -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName "MyKeyVault" -Name "DatabasePassword" -SecretValue $secretValue

# Get secret
$secret = Get-AzKeyVaultSecret -VaultName "MyKeyVault" -Name "DatabasePassword"
$secret.SecretValue

# List secrets
Get-AzKeyVaultSecret -VaultName "MyKeyVault"
```

### 7. Azure App Service

```powershell
# List App Service plans
Get-AzAppServicePlan

# Create App Service plan
New-AzAppServicePlan -Name "MyAppPlan" -ResourceGroupName "MyRG" -Location "EastUS" -Tier "Basic" -NumberofWorkers 1 -WorkerSize "Small"

# Create Web App
New-AzWebApp -Name "MyWebApp" -ResourceGroupName "MyRG" -Location "EastUS" -AppServicePlan "MyAppPlan"

# Get Web App
Get-AzWebApp -ResourceGroupName "MyRG" -Name "MyWebApp"

# Restart Web App
Restart-AzWebApp -ResourceGroupName "MyRG" -Name "MyWebApp"
```

## Common Automation Scenarios

### Scenario 1: Daily VM Management

```powershell
<#
.SYNOPSIS
    Start/stop VMs on schedule for cost savings

.EXAMPLE
    .\Manage-VMs.ps1 -Action Start -ResourceGroup "MyRG"
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Start", "Stop")]
    [string]$Action,

    [Parameter(Mandatory=$true)]
    [string]$ResourceGroup
)

# Connect to Azure
Connect-AzAccount

# Get all VMs in resource group
$vms = Get-AzVM -ResourceGroupName $ResourceGroup

foreach ($vm in $vms) {
    Write-Host "$Action VM: $($vm.Name)"

    if ($Action -eq "Start") {
        Start-AzVM -ResourceGroupName $ResourceGroup -Name $vm.Name -NoWait
    }
    else {
        Stop-AzVM -ResourceGroupName $ResourceGroup -Name $vm.Name -Force -NoWait
    }
}

Write-Host "All VMs processed"
```

### Scenario 2: Resource Inventory Report

```powershell
# Generate inventory of all resources
$resources = Get-AzResource

$inventory = $resources | Select-Object `
    Name,
    ResourceType,
    ResourceGroupName,
    Location,
    @{Name='Tags';Expression={$_.Tags | ConvertTo-Json -Compress}}

# Export to CSV
$inventory | Export-Csv -Path "azure-inventory.csv" -NoTypeInformation

# Or export to JSON
$inventory | ConvertTo-Json | Out-File "azure-inventory.json"

Write-Host "Inventory exported: $($resources.Count) resources"
```

### Scenario 3: Backup Automation

```powershell
# Backup Azure VMs
$vaultName = "MyBackupVault"
$resourceGroup = "MyRG"

# Get Recovery Services Vault
$vault = Get-AzRecoveryServicesVault -Name $vaultName -ResourceGroupName $resourceGroup

# Set vault context
Set-AzRecoveryServicesVaultContext -Vault $vault

# Get VMs to backup
$vms = Get-AzVM -ResourceGroupName $resourceGroup

foreach ($vm in $vms) {
    # Enable backup
    $policy = Get-AzRecoveryServicesBackupProtectionPolicy -Name "DefaultPolicy"

    Enable-AzRecoveryServicesBackupProtection `
        -ResourceGroupName $resourceGroup `
        -Name $vm.Name `
        -Policy $policy

    Write-Host "Backup enabled for: $($vm.Name)"
}
```

### Scenario 4: Cost Analysis

```powershell
# Get cost and usage data
$subscription = Get-AzSubscription -SubscriptionName "MySubscription"

# Get resource group costs
$resourceGroups = Get-AzResourceGroup

foreach ($rg in $resourceGroups) {
    $resources = Get-AzResource -ResourceGroupName $rg.ResourceGroupName

    [PSCustomObject]@{
        ResourceGroup = $rg.ResourceGroupName
        ResourceCount = $resources.Count
        Location = $rg.Location
    }
}
```

## CI/CD Integration

### GitHub Actions with Azure

```yaml
name: Deploy to Azure

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Deploy resources
        shell: pwsh
        run: |
          Install-Module -Name Az -Force -Scope CurrentUser
          ./deploy-azure.ps1 -ResourceGroup "MyRG" -Location "EastUS"
```

### Azure DevOps with Az Module

```yaml
- task: AzurePowerShell@5
  inputs:
    azureSubscription: 'MyAzureConnection'
    ScriptType: 'InlineScript'
    Inline: |
      # Get VMs
      Get-AzVM

      # Deploy ARM template
      New-AzResourceGroupDeployment `
        -ResourceGroupName "MyRG" `
        -TemplateFile "template.json" `
        -TemplateParameterFile "parameters.json"
    azurePowerShellVersion: 'LatestVersion'
```

## Best Practices

- ✅ Use service principals for automation (not user accounts)
- ✅ Store credentials in Azure Key Vault
- ✅ Use `-WhatIf` to preview changes before executing
- ✅ Tag all resources for tracking and cost management
- ✅ Use resource locks to prevent accidental deletion
- ✅ Implement proper error handling
- ✅ Use `-NoWait` for parallel operations on multiple resources
- ✅ Set Azure context explicitly in scripts
- ✅ Use resource groups for logical organization
- ✅ Always specify `-Force` in automation to avoid prompts

## Troubleshooting

**Issue: Authentication failed**
```powershell
# Clear cached credentials
Clear-AzContext -Force

# Re-authenticate
Connect-AzAccount
```

**Issue: Subscription not found**
```powershell
# List all subscriptions
Get-AzSubscription

# Set specific subscription
Set-AzContext -SubscriptionId "sub-id"
```

**Issue: Insufficient permissions**
```powershell
# Check current user roles
Get-AzRoleAssignment -SignInName (Get-AzContext).Account.Id

# Required roles for common operations:
# - Contributor: Can manage resources
# - Reader: Can view resources
# - Owner: Full access including role assignments
```

**Issue: Module version conflicts**
```powershell
# Uninstall old Az modules
Get-InstalledModule -Name Az -AllVersions |
    Where-Object Version -ne "10.0.0" |
    Uninstall-Module -Force

# Install latest
Install-Module -Name Az -Force
```

## Useful Az Modules

```powershell
# Core modules
Az.Accounts      # Authentication
Az.Compute       # VMs, Scale Sets
Az.Storage       # Storage Accounts
Az.Network       # VNets, NSGs, Load Balancers
Az.Resources     # Resource Groups, Deployments
Az.KeyVault      # Key Vault
Az.Sql           # SQL Databases
Az.Websites      # App Service
Az.Monitor       # Monitoring and Alerts
Az.Automation    # Automation Accounts
Az.RecoveryServices  # Backup and Site Recovery
```

## Quick Reference Commands

```powershell
# List all available Az commands
Get-Command -Module Az.*

# Get help for specific cmdlet
Get-Help Get-AzVM -Full
Get-Help New-AzVM -Examples

# Update Az modules
Update-Module -Name Az
```
