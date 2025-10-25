#Requires -Version 7.0
<#
.SYNOPSIS
    Azure Infrastructure Extractor for Docker Compose Migration

.DESCRIPTION
    This script extracts all configuration details from Azure resources
    to generate a docker-compose.yml for local development.

.PARAMETER ResourceGroupName
    The name of the Azure resource group to extract

.PARAMETER OutputDirectory
    The directory where extracted data will be saved (default: ./azure-export)

.EXAMPLE
    .\azure-infrastructure-extractor.ps1 -ResourceGroupName "my-rg"

.EXAMPLE
    .\azure-infrastructure-extractor.ps1 -ResourceGroupName "my-rg" -OutputDirectory "C:\exports"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $false)]
    [string]$OutputDirectory = ".\azure-export"
)

$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"

# Configuration
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$ExportDir = Join-Path $OutputDirectory "${ResourceGroupName}_${Timestamp}"

# Logging functions
function Write-InfoLog {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-SuccessLog {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-WarningLog {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-ErrorLog {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Validate prerequisites
function Test-Prerequisites {
    Write-InfoLog "Validating prerequisites..."

    # Check Azure CLI
    if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
        Write-ErrorLog "Azure CLI is not installed. Install from: https://aka.ms/InstallAzureCLI"
        exit 1
    }

    # Check authentication
    try {
        $null = az account show 2>$null
    }
    catch {
        Write-ErrorLog "Not logged in to Azure. Run: az login"
        exit 1
    }

    # Check resource group
    $rgExists = az group exists --name $ResourceGroupName | ConvertFrom-Json
    if (-not $rgExists) {
        Write-ErrorLog "Resource group '$ResourceGroupName' does not exist"
        exit 1
    }

    Write-SuccessLog "Prerequisites validated"
}

# Create directory structure
function New-DirectoryStructure {
    Write-InfoLog "Setting up directory structure..."

    $dirs = @(
        "$ExportDir\webapps",
        "$ExportDir\databases",
        "$ExportDir\storage",
        "$ExportDir\redis",
        "$ExportDir\keyvault",
        "$ExportDir\appinsights",
        "$ExportDir\misc",
        "$ExportDir\scripts\init",
        "$ExportDir\scripts\seed",
        "$ExportDir\docker\dockerfiles",
        "$ExportDir\docker\configs"
    )

    foreach ($dir in $dirs) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    Write-SuccessLog "Directory structure created at: $ExportDir"
}

# Extract all resources
function Export-AllResources {
    Write-InfoLog "Extracting all resources from '$ResourceGroupName'..."

    az resource list `
        --resource-group $ResourceGroupName `
        --output json | Out-File -FilePath "$ExportDir\all-resources.json" -Encoding UTF8

    az resource list `
        --resource-group $ResourceGroupName `
        --query "[].{Name:name, Type:type, Location:location}" `
        --output table | Out-File -FilePath "$ExportDir\resource-summary.txt" -Encoding UTF8

    Write-SuccessLog "Resource list exported"
}

# Extract App Service Plans
function Export-AppServicePlans {
    Write-InfoLog "Extracting App Service Plans..."

    $plans = az appservice plan list `
        --resource-group $ResourceGroupName `
        --query "[].name" `
        --output tsv

    if (-not $plans) {
        Write-WarningLog "No App Service Plans found"
        return
    }

    foreach ($plan in $plans) {
        Write-InfoLog "  Extracting plan: $plan"

        az appservice plan show `
            --name $plan `
            --resource-group $ResourceGroupName `
            --output json | Out-File -FilePath "$ExportDir\misc\appservice-plan-$plan.json" -Encoding UTF8

        az appservice plan show `
            --name $plan `
            --resource-group $ResourceGroupName `
            --query "{name:name, sku:sku.name, tier:sku.tier, location:location, numberOfWorkers:sku.capacity, kind:kind}" `
            --output json | Out-File -FilePath "$ExportDir\misc\appservice-plan-$plan-summary.json" -Encoding UTF8
    }

    Write-SuccessLog "App Service Plans extracted"
}

# Extract Web Apps
function Export-WebApps {
    Write-InfoLog "Extracting Web Apps..."

    $webapps = az webapp list `
        --resource-group $ResourceGroupName `
        --query "[].name" `
        --output tsv

    if (-not $webapps) {
        Write-WarningLog "No Web Apps found"
        return
    }

    foreach ($webapp in $webapps) {
        Write-InfoLog "  Extracting webapp: $webapp"

        $webappDir = Join-Path $ExportDir "webapps\$webapp"
        New-Item -ItemType Directory -Path $webappDir -Force | Out-Null

        # Full configuration
        az webapp show `
            --name $webapp `
            --resource-group $ResourceGroupName `
            --output json | Out-File -FilePath "$webappDir\config.json" -Encoding UTF8

        # Runtime stack
        az webapp show `
            --name $webapp `
            --resource-group $ResourceGroupName `
            --query "{runtime:siteConfig.linuxFxVersion, nodeVersion:siteConfig.nodeVersion, pythonVersion:siteConfig.pythonVersion, phpVersion:siteConfig.phpVersion, netFrameworkVersion:siteConfig.netFrameworkVersion, javaVersion:siteConfig.javaVersion}" `
            --output json | Out-File -FilePath "$webappDir\runtime.json" -Encoding UTF8

        # App settings
        az webapp config appsettings list `
            --name $webapp `
            --resource-group $ResourceGroupName `
            --output json | Out-File -FilePath "$webappDir\appsettings.json" -Encoding UTF8

        # Convert to .env format
        $appSettings = az webapp config appsettings list `
            --name $webapp `
            --resource-group $ResourceGroupName `
            --query "[].{name:name, value:value}" `
            --output json | ConvertFrom-Json

        $envContent = $appSettings | ForEach-Object { "$($_.name)=$($_.value)" }
        $envContent | Out-File -FilePath "$webappDir\.env" -Encoding UTF8

        # Connection strings
        az webapp config connection-string list `
            --name $webapp `
            --resource-group $ResourceGroupName `
            --output json | Out-File -FilePath "$webappDir\connection-strings.json" -Encoding UTF8

        # Startup command
        az webapp config show `
            --name $webapp `
            --resource-group $ResourceGroupName `
            --query "{appCommandLine:appCommandLine, alwaysOn:alwaysOn, http20Enabled:http20Enabled, minTlsVersion:minTlsVersion}" `
            --output json | Out-File -FilePath "$webappDir\startup.json" -Encoding UTF8

        # Container settings (if containerized)
        try {
            az webapp config container show `
                --name $webapp `
                --resource-group $ResourceGroupName `
                --output json | Out-File -FilePath "$webappDir\container-settings.json" -Encoding UTF8
        }
        catch {
            "{}" | Out-File -FilePath "$webappDir\container-settings.json" -Encoding UTF8
        }

        # Managed identity
        try {
            az webapp identity show `
                --name $webapp `
                --resource-group $ResourceGroupName `
                --output json | Out-File -FilePath "$webappDir\identity.json" -Encoding UTF8
        }
        catch {
            "{}" | Out-File -FilePath "$webappDir\identity.json" -Encoding UTF8
        }
    }

    Write-SuccessLog "Web Apps extracted"
}

# Extract SQL Databases
function Export-SqlDatabases {
    Write-InfoLog "Extracting SQL Databases..."

    $servers = az sql server list `
        --resource-group $ResourceGroupName `
        --query "[].name" `
        --output tsv

    if (-not $servers) {
        Write-WarningLog "No SQL Servers found"
        return
    }

    foreach ($server in $servers) {
        Write-InfoLog "  Extracting SQL Server: $server"

        $serverDir = Join-Path $ExportDir "databases\sql-$server"
        New-Item -ItemType Directory -Path $serverDir -Force | Out-Null

        # Server configuration
        az sql server show `
            --name $server `
            --resource-group $ResourceGroupName `
            --output json | Out-File -FilePath "$serverDir\server-config.json" -Encoding UTF8

        # Firewall rules
        az sql server firewall-rule list `
            --server $server `
            --resource-group $ResourceGroupName `
            --output json | Out-File -FilePath "$serverDir\firewall-rules.json" -Encoding UTF8

        # Databases
        $databases = az sql db list `
            --server $server `
            --resource-group $ResourceGroupName `
            --query "[?name!='master'].name" `
            --output tsv

        foreach ($db in $databases) {
            if (-not $db) { continue }

            Write-InfoLog "    Extracting database: $db"

            $dbDir = Join-Path $serverDir $db
            New-Item -ItemType Directory -Path $dbDir -Force | Out-Null

            # Database configuration
            az sql db show `
                --name $db `
                --server $server `
                --resource-group $ResourceGroupName `
                --output json | Out-File -FilePath "$dbDir\config.json" -Encoding UTF8

            # Service tier
            az sql db show `
                --name $db `
                --server $server `
                --resource-group $ResourceGroupName `
                --query "{sku:sku.name, tier:sku.tier, capacity:sku.capacity, maxSizeBytes:maxSizeBytes, collation:collation}" `
                --output json | Out-File -FilePath "$dbDir\tier.json" -Encoding UTF8

            # Connection strings
            $fqdn = az sql server show --name $server --resource-group $ResourceGroupName --query fullyQualifiedDomainName -o tsv

            @"
Server=tcp:$fqdn,1433;Initial Catalog=$db;Persist Security Info=False;User ID=<username>;Password=<password>;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;
"@ | Out-File -FilePath "$dbDir\connection-string.txt" -Encoding UTF8

            @"
Server=sqlserver;Database=$db;User Id=sa;Password=<YourStrong@Passw0rd>;TrustServerCertificate=True;
"@ | Out-File -FilePath "$dbDir\docker-connection-string.txt" -Encoding UTF8

            # Export script
            @"
# PowerShell script to export Azure SQL Database
# Requires SqlPackage: https://aka.ms/sqlpackage

# Export as BACPAC (schema + data)
SqlPackage /Action:Export ``
    /SourceServerName:$fqdn ``
    /SourceDatabaseName:$db ``
    /SourceUser:<username> ``
    /SourcePassword:<password> ``
    /SourceEncryptConnection:True ``
    /TargetFile:$db.bacpac

# Or use Azure CLI
# az sql db export ``
#     --name $db ``
#     --server $server ``
#     --resource-group $ResourceGroupName ``
#     --admin-user <username> ``
#     --admin-password <password> ``
#     --storage-key-type StorageAccessKey ``
#     --storage-key <storage-key> ``
#     --storage-uri https://<storage-account>.blob.core.windows.net/backups/$db.bacpac
"@ | Out-File -FilePath "$dbDir\export-data.ps1" -Encoding UTF8
        }
    }

    Write-SuccessLog "SQL Databases extracted"
}

# Extract Storage Accounts
function Export-StorageAccounts {
    Write-InfoLog "Extracting Storage Accounts..."

    $accounts = az storage account list `
        --resource-group $ResourceGroupName `
        --query "[].name" `
        --output tsv

    if (-not $accounts) {
        Write-WarningLog "No Storage Accounts found"
        return
    }

    foreach ($account in $accounts) {
        Write-InfoLog "  Extracting storage account: $account"

        $storageDir = Join-Path $ExportDir "storage\$account"
        New-Item -ItemType Directory -Path $storageDir -Force | Out-Null

        # Account configuration
        az storage account show `
            --name $account `
            --resource-group $ResourceGroupName `
            --output json | Out-File -FilePath "$storageDir\config.json" -Encoding UTF8

        # Access keys
        az storage account keys list `
            --account-name $account `
            --resource-group $ResourceGroupName `
            --output json | Out-File -FilePath "$storageDir\keys.json" -Encoding UTF8

        # Connection string
        az storage account show-connection-string `
            --name $account `
            --resource-group $ResourceGroupName `
            --output json | Out-File -FilePath "$storageDir\connection-string.json" -Encoding UTF8

        # Blob containers
        try {
            az storage container list `
                --account-name $account `
                --auth-mode login `
                --output json | Out-File -FilePath "$storageDir\containers.json" -Encoding UTF8
        }
        catch {
            "[]" | Out-File -FilePath "$storageDir\containers.json" -Encoding UTF8
        }

        # Docker config
        @"
Use Azurite for local Azure Storage emulation:
https://hub.docker.com/_/microsoft-azure-storage-azurite

Connection String for Azurite:
DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://127.0.0.1:10000/devstoreaccount1;QueueEndpoint=http://127.0.0.1:10001/devstoreaccount1;TableEndpoint=http://127.0.0.1:10002/devstoreaccount1;
"@ | Out-File -FilePath "$storageDir\docker-config.txt" -Encoding UTF8
    }

    Write-SuccessLog "Storage Accounts extracted"
}

# Extract Redis Cache
function Export-RedisCache {
    Write-InfoLog "Extracting Redis Cache instances..."

    try {
        $caches = az redis list `
            --resource-group $ResourceGroupName `
            --query "[].name" `
            --output tsv
    }
    catch {
        Write-WarningLog "No Redis Cache instances found"
        return
    }

    if (-not $caches) {
        Write-WarningLog "No Redis Cache instances found"
        return
    }

    foreach ($cache in $caches) {
        Write-InfoLog "  Extracting Redis Cache: $cache"

        $redisDir = Join-Path $ExportDir "redis\$cache"
        New-Item -ItemType Directory -Path $redisDir -Force | Out-Null

        # Cache configuration
        az redis show `
            --name $cache `
            --resource-group $ResourceGroupName `
            --output json | Out-File -FilePath "$redisDir\config.json" -Encoding UTF8

        # Access keys
        az redis list-keys `
            --name $cache `
            --resource-group $ResourceGroupName `
            --output json | Out-File -FilePath "$redisDir\keys.json" -Encoding UTF8

        # Connection info
        $hostname = az redis show --name $cache --resource-group $ResourceGroupName --query hostName -o tsv
        $port = az redis show --name $cache --resource-group $ResourceGroupName --query port -o tsv
        $sslPort = az redis show --name $cache --resource-group $ResourceGroupName --query sslPort -o tsv

        @"
Hostname: $hostname
Port: $port
SSL Port: $sslPort

Connection String:
$hostname`:$sslPort,password=<primary-key>,ssl=True,abortConnect=False

Docker Connection String:
redis:6379,password=<local-password>
"@ | Out-File -FilePath "$redisDir\connection-info.txt" -Encoding UTF8
    }

    Write-SuccessLog "Redis Cache instances extracted"
}

# Extract Key Vaults
function Export-KeyVaults {
    Write-InfoLog "Extracting Key Vaults..."

    try {
        $vaults = az keyvault list `
            --resource-group $ResourceGroupName `
            --query "[].name" `
            --output tsv
    }
    catch {
        Write-WarningLog "No Key Vaults found"
        return
    }

    if (-not $vaults) {
        Write-WarningLog "No Key Vaults found"
        return
    }

    foreach ($vault in $vaults) {
        Write-InfoLog "  Extracting Key Vault: $vault"

        $vaultDir = Join-Path $ExportDir "keyvault\$vault"
        New-Item -ItemType Directory -Path $vaultDir -Force | Out-Null

        # Vault configuration
        az keyvault show `
            --name $vault `
            --output json | Out-File -FilePath "$vaultDir\config.json" -Encoding UTF8

        # List secret names
        try {
            az keyvault secret list `
                --vault-name $vault `
                --query "[].{name:name, enabled:attributes.enabled, expires:attributes.expires}" `
                --output json | Out-File -FilePath "$vaultDir\secret-names.json" -Encoding UTF8
        }
        catch {
            "[]" | Out-File -FilePath "$vaultDir\secret-names.json" -Encoding UTF8
        }

        # Create template
        "# Template for local development secrets`n" | Out-File -FilePath "$vaultDir\local-secrets-template.env" -Encoding UTF8

        try {
            $secrets = az keyvault secret list --vault-name $vault --query "[].name" -o tsv
            foreach ($secret in $secrets) {
                if ($secret) {
                    "$secret=" | Out-File -FilePath "$vaultDir\local-secrets-template.env" -Append -Encoding UTF8
                }
            }
        }
        catch {
            # No secrets or no access
        }
    }

    Write-SuccessLog "Key Vaults extracted"
}

# Generate docker-compose template
function New-DockerComposeTemplate {
    Write-InfoLog "Generating docker-compose.yml template..."

    $composeContent = @'
version: '3.8'

# Generated Docker Compose template for local development
# CUSTOMIZE THIS FILE based on your needs

services:
  # Add your services here based on extracted configurations
  # See SERVICE-MAPPING.md for Azure to Docker mappings

  # Example: SQL Server
  # sqlserver:
  #   image: mcr.microsoft.com/mssql/server:2022-latest
  #   environment:
  #     ACCEPT_EULA: "Y"
  #     SA_PASSWORD: "YourStrong@Passw0rd"
  #   ports:
  #     - "1433:1433"
  #   volumes:
  #     - sqldata:/var/opt/mssql

volumes:
  sqldata:

networks:
  app-network:
    driver: bridge
'@

    $composeContent | Out-File -FilePath "$ExportDir\docker-compose.yml" -Encoding UTF8
    Write-SuccessLog "docker-compose.yml template generated"
}

# Generate README
function New-ReadmeFile {
    Write-InfoLog "Generating README..."

    $readmeContent = @"
# Azure Infrastructure Export

Resource Group: **$ResourceGroupName**
Export Date: $(Get-Date)
Export Tool: azure-infrastructure-extractor.ps1

## Directory Structure

See the webapps/, databases/, storage/, redis/, keyvault/, and appinsights/ directories
for extracted configurations.

## Quick Start

1. Review extracted data in subdirectories
2. Export database data using provided scripts
3. Set up local secrets (.env files)
4. Customize docker-compose.yml
5. Create Dockerfiles for applications
6. Start local environment

## Security Notes

DO NOT commit files containing secrets:
- **\keys.json
- **\connection-string.json
- **\.env
- **\*secrets*.env

Add these to .gitignore!

## Next Steps

1. Review configurations
2. Export database schemas/data
3. Create Dockerfiles
4. Configure docker-compose.yml
5. Test local environment

Generated: $(Get-Date)
"@

    $readmeContent | Out-File -FilePath "$ExportDir\README.md" -Encoding UTF8
    Write-SuccessLog "README generated"
}

# Main execution
function Main {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Azure Infrastructure Extractor" -ForegroundColor Cyan
    Write-Host "Docker Compose Migration Tool" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    Test-Prerequisites
    New-DirectoryStructure

    # Extract all resources
    Export-AllResources
    Export-AppServicePlans
    Export-WebApps
    Export-SqlDatabases
    Export-StorageAccounts
    Export-RedisCache
    Export-KeyVaults

    # Generate helper files
    New-DockerComposeTemplate
    New-ReadmeFile

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-SuccessLog "Extraction Complete!"
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Output directory: $ExportDir" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Green
    Write-Host "1. Review README.md in the output directory"
    Write-Host "2. Extract database data using provided scripts"
    Write-Host "3. Set up local secrets (.env files)"
    Write-Host "4. Create Dockerfiles for your applications"
    Write-Host "5. Customize docker-compose.yml"
    Write-Host "6. Start your local environment"
    Write-Host ""
}

# Run main function
Main
