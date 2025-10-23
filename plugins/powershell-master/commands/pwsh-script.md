---
description: Create, review, or optimize PowerShell scripts following best practices and cross-platform standards
---

# PowerShell Script

Create production-ready PowerShell scripts with proper error handling, cross-platform compatibility, and best practices.

## When to Use

- Creating new PowerShell scripts
- Reviewing existing scripts for issues
- Optimizing script performance
- Converting scripts for cross-platform use
- Adding error handling and logging

## Instructions

1. **Understand Requirements**
   - What does the script need to accomplish?
   - Which platforms must it support? (Windows/Linux/macOS)
   - What PowerShell version is available? (7+ or 5.1)
   - Are there any module dependencies?

2. **Check Cross-Platform Compatibility**
   - Use platform detection (`$IsWindows`, `$IsLinux`, `$IsMacOS`)
   - Use `Join-Path` or `[IO.Path]::Combine()` for paths
   - Avoid hardcoded backslashes
   - Consider case-sensitive file systems
   - Use UTF-8 encoding

3. **Apply Best Practices**
   - Add proper comment-based help
   - Use `[CmdletBinding()]` for advanced functions
   - Add parameter validation
   - Use full cmdlet names (no aliases)
   - Include error handling (`try/catch`)
   - Add `#Requires` statements
   - Use `Set-StrictMode -Version Latest`

4. **Structure the Script**
   ```powershell
   <#
   .SYNOPSIS
       Brief description

   .DESCRIPTION
       Detailed description

   .PARAMETER Name
       Parameter description

   .EXAMPLE
       PS> .\script.ps1 -Name "Value"

   .NOTES
       Author: Name
       Version: 1.0.0
   #>

   [CmdletBinding()]
   param(
       [Parameter(Mandatory=$true)]
       [ValidateNotNullOrEmpty()]
       [string]$Name
   )

   Set-StrictMode -Version Latest
   $ErrorActionPreference = "Stop"

   try {
       # Script logic
   }
   catch {
       Write-Error "Error: $_"
       exit 1
   }
   finally {
       # Cleanup
   }
   ```

5. **Test & Validate**
   - Test on all target platforms
   - Run PSScriptAnalyzer if available
   - Test error scenarios
   - Verify logging and output

## Example Output

When user asks: "Create a script to backup files"

```powershell
<#
.SYNOPSIS
    Backs up files from source to destination directory

.DESCRIPTION
    Creates timestamped backups of specified source directory to destination.
    Supports cross-platform operation and validates paths before copying.

.PARAMETER Source
    Source directory to backup

.PARAMETER Destination
    Destination directory for backup

.EXAMPLE
    PS> .\Backup-Files.ps1 -Source "C:\Data" -Destination "D:\Backups"

.NOTES
    Author: Generated
    Version: 1.0.0
    Requires: PowerShell 7.0+
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_ -PathType Container})]
    [string]$Source,

    [Parameter(Mandatory=$true)]
    [string]$Destination
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    # Create destination if needed
    if (-not (Test-Path $Destination)) {
        New-Item -Path $Destination -ItemType Directory -Force | Out-Null
        Write-Verbose "Created destination directory: $Destination"
    }

    # Generate timestamp
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupFolder = Join-Path -Path $Destination -ChildPath "Backup_$timestamp"

    Write-Host "Starting backup from $Source to $backupFolder"

    # Copy files
    Copy-Item -Path $Source -Destination $backupFolder -Recurse -Force

    Write-Host "Backup completed successfully" -ForegroundColor Green
    Write-Host "Backup location: $backupFolder"

    # Return backup path
    return $backupFolder
}
catch {
    Write-Error "Backup failed: $_"
    exit 1
}
```

## Key Considerations

- **Performance:** Use `-Filter` instead of `Where-Object` for large datasets
- **Security:** Never hardcode credentials, use `Get-Credential`
- **Logging:** Use `Write-Verbose` for debug info, `Write-Host` for user output
- **Compatibility:** Test with `pwsh` on Linux/macOS if cross-platform support needed
