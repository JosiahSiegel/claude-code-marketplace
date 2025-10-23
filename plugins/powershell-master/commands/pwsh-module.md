---
description: Find, install, and manage PowerShell modules from PSGallery or other sources
---

# PowerShell Module Management

Discover, install, update, and manage PowerShell modules efficiently across all platforms.

## When to Use

- Need to find modules for specific functionality
- Installing new modules from PSGallery
- Updating existing modules
- Troubleshooting module import issues
- Managing module dependencies

## Instructions

1. **Search for Modules**
   ```powershell
   # Find modules by name
   Find-Module -Name "*Azure*"

   # Find by tag/keyword
   Find-Module -Tag "Security"
   Find-Module -Tag "AWS"

   # Get detailed info
   Find-Module -Name Az | Select-Object Name, Version, Description

   # Find commands within modules
   Find-Command -Name Get-AzVM
   ```

2. **Install Modules**
   ```powershell
   # Install for current user (no admin needed)
   Install-Module -Name ModuleName -Scope CurrentUser -Force

   # Install specific version
   Install-Module -Name Az -RequiredVersion 10.0.0

   # Install for all users (requires elevation)
   Install-Module -Name Pester -Scope AllUsers

   # Install without prompts
   Install-Module -Name PnP.PowerShell -Force -SkipPublisherCheck
   ```

3. **Manage Installed Modules**
   ```powershell
   # List installed modules
   Get-InstalledModule
   Get-Module -ListAvailable

   # Import module
   Import-Module -Name ModuleName

   # Update modules
   Update-Module -Name ModuleName
   Update-Module  # Updates all

   # Uninstall module
   Uninstall-Module -Name ModuleName -AllVersions
   ```

4. **Common Modules to Know**

   **Azure (Az):**
   ```powershell
   Install-Module -Name Az -Scope CurrentUser
   # Sub-modules: Az.Accounts, Az.Compute, Az.Storage, Az.Network
   ```

   **Microsoft Graph:**
   ```powershell
   Install-Module -Name Microsoft.Graph -Scope CurrentUser
   # For Microsoft 365, Teams, SharePoint, Users, Groups
   ```

   **AWS Tools:**
   ```powershell
   Install-Module -Name AWS.Tools.Installer
   Install-AWSToolsModule AWS.Tools.EC2, AWS.Tools.S3
   ```

   **PnP PowerShell (SharePoint/Teams):**
   ```powershell
   Install-Module -Name PnP.PowerShell -Scope CurrentUser
   ```

   **Testing & Quality:**
   ```powershell
   Install-Module -Name Pester  # Testing framework
   Install-Module -Name PSScriptAnalyzer  # Code analysis
   ```

   **Utilities:**
   ```powershell
   Install-Module -Name ImportExcel  # Excel without Excel
   Install-Module -Name Microsoft.PowerShell.PSResourceGet  # Modern package mgmt
   ```

5. **Troubleshooting**

   **Module not found after install:**
   ```powershell
   # Check PSModulePath
   $env:PSModulePath -split [IO.Path]::PathSeparator

   # Manually add path (if needed)
   $env:PSModulePath += ";C:\CustomModules"
   ```

   **Version conflicts:**
   ```powershell
   # List all versions
   Get-InstalledModule -Name ModuleName -AllVersions

   # Uninstall old versions
   Get-InstalledModule -Name ModuleName -AllVersions |
       Where-Object Version -ne "10.0.0" |
       Uninstall-Module -Force
   ```

   **TLS 1.2 error:**
   ```powershell
   # Enable TLS 1.2
   [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
   ```

## Example: Finding & Installing Module

**User Request:** "I need to work with Azure virtual machines"

**Response:**
```powershell
# Search for Azure VM-related modules
Find-Command -Name "*VM*" | Where-Object ModuleName -like "Az.*"

# Install the Azure Compute module
Install-Module -Name Az.Compute -Scope CurrentUser -Force

# Also need authentication module
Install-Module -Name Az.Accounts -Scope CurrentUser -Force

# Import modules
Import-Module Az.Accounts
Import-Module Az.Compute

# Connect to Azure
Connect-AzAccount

# Get VMs
Get-AzVM

# Available VM commands
Get-Command -Module Az.Compute -Noun *VM*
```

## Offline Installation

For air-gapped systems:

```powershell
# On internet-connected machine, save module
Save-Module -Name Az -Path C:\SavedModules

# Transfer C:\SavedModules to offline machine

# On offline machine, install from saved location
$modulePath = "C:\SavedModules\Az\10.0.0"
Copy-Item -Path $modulePath -Destination $env:PSModulePath.Split(';')[0] -Recurse
Import-Module Az
```

## CI/CD Module Installation

**GitHub Actions:**
```yaml
- name: Install PowerShell modules
  shell: pwsh
  run: |
    Install-Module -Name Pester -Force -Scope CurrentUser
    Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser
```

**Azure DevOps:**
```yaml
- task: PowerShell@2
  inputs:
    targetType: 'inline'
    script: |
      Install-Module -Name Az -Force -Scope CurrentUser
      Import-Module Az
```

## Best Practices

- ✅ Use `-Scope CurrentUser` to avoid needing admin rights
- ✅ Add `-Force` in CI/CD to skip prompts
- ✅ Pin versions in production scripts
- ✅ Check module availability with `Get-Module -ListAvailable`
- ✅ Update help files: `Update-Help -Force -ErrorAction SilentlyContinue`
- ✅ Use `Import-Module` explicitly in scripts
