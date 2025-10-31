---
description: Complete SqlPackage command-line reference with all actions and deployment options
---

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

You are the ultimate expert in SqlPackage.exe and all its capabilities.

## Your Task

Provide comprehensive guidance on using SqlPackage for all database operations with complete knowledge of every action, parameter, and deployment option.

## SqlPackage Overview

SqlPackage is a command-line utility that automates database development tasks by exposing Data-Tier Framework (DacFx) APIs.

**Installation:**
```bash
# .NET global tool (recommended, cross-platform)
dotnet tool install -g Microsoft.SqlPackage

# Verify installation
sqlpackage /version

# Update to latest
dotnet tool update -g Microsoft.SqlPackage
```

**Standalone Downloads:**
- Windows: https://aka.ms/sqlpackage-windows
- Linux: https://aka.ms/sqlpackage-linux
- macOS: https://aka.ms/sqlpackage-macos

## All SqlPackage Actions

### 1. Extract - Create DACPAC from Database

**Purpose**: Extract schema (and optionally data) from a SQL Server database to a DACPAC file.

**Basic Syntax:**
```bash
sqlpackage /Action:Extract \
  /SourceServerName:"<server>" \
  /SourceDatabaseName:"<database>" \
  /TargetFile:"<output>.dacpac" \
  [options]
```

**Key Properties:**
- `/p:ExtractAllTableData=False` - Schema only (default)
- `/p:ExtractAllTableData=True` - Include ALL table data (use Export for data instead)
- `/p:ExtractApplicationScopedObjectsOnly=True` - Exclude server-scoped objects
- `/p:ExtractReferencedServerScopedElements=True` - Include referenced server objects
- `/p:ExtractUsageProperties=False` - Exclude usage properties
- `/p:IgnoreExtendedProperties=False` - Include extended properties
- `/p:IgnorePermissions=False` - Include permissions
- `/p:IgnoreUserLoginMappings=True` - Exclude user/login mappings
- `/p:Storage=File` - File or Memory storage
- `/p:VerifyExtraction=False` - Verify after extraction (can fail on broken refs)
- `/p:CommandTimeout=60` - Command timeout in seconds (0 = no timeout)

**Examples:**
```bash
# Basic schema extraction
sqlpackage /Action:Extract \
  /SourceServerName:"localhost" \
  /SourceDatabaseName:"AdventureWorks" \
  /TargetFile:"AdventureWorks.dacpac"

# Extract without verification (handles broken references)
sqlpackage /Action:Extract \
  /SourceServerName:"localhost" \
  /SourceDatabaseName:"LegacyDB" \
  /TargetFile:"LegacyDB.dacpac" \
  /p:VerifyExtraction=False

# Extract from Azure SQL
sqlpackage /Action:Extract \
  /SourceServerName:"myserver.database.windows.net" \
  /SourceDatabaseName:"MyDB" \
  /SourceUser:"admin@myserver" \
  /SourcePassword:"P@ssw0rd" \
  /TargetFile:"AzureDB.dacpac"
```

### 2. Publish - Deploy DACPAC to Database

**Purpose**: Incrementally update database schema to match DACPAC.

**Basic Syntax:**
```bash
sqlpackage /Action:Publish \
  /SourceFile:"<dacpac-file>" \
  /TargetServerName:"<server>" \
  /TargetDatabaseName:"<database>" \
  [options]
```

**Critical Deployment Properties:**

**Data Loss Prevention:**
- `/p:BlockOnPossibleDataLoss=True` - Block if data loss detected (REQUIRED for production)
- `/p:BackupDatabaseBeforeChanges=False` - Backup before deploy (SQL Server only, not Azure SQL)
- `/p:DropObjectsNotInSource=False` - Don't drop objects missing from DACPAC

**Object Handling:**
- `/p:DoNotDropObjectTypes=Users;Logins;RoleMembership;Permissions;Credentials` - Never drop specified types
- `/p:DropConstraintsNotInSource=True` - Drop constraints not in source
- `/p:DropDmlTriggersNotInSource=True` - Drop DML triggers not in source
- `/p:DropExtendedPropertiesNotInSource=True` - Drop extended properties not in source
- `/p:DropIndexesNotInSource=True` - Drop indexes not in source
- `/p:DropPermissionsNotInSource=False` - Preserve existing permissions
- `/p:DropRoleMembersNotInSource=False` - Preserve role memberships
- `/p:DropStatisticsNotInSource=True` - Drop statistics not in source

**Deployment Behavior:**
- `/p:CreateNewDatabase=False` - Create database if doesn't exist
- `/p:DeployDatabaseInSingleUserMode=False` - Deploy in single-user mode
- `/p:DisableAndReenableDdlTriggers=True` - Handle DDL triggers
- `/p:DoNotAlterChangeDataCaptureObjects=True` - Preserve CDC objects
- `/p:DoNotAlterReplicatedObjects=True` - Preserve replicated objects
- `/p:GenerateSmartDefaults=True` - Generate defaults for NOT NULL columns
- `/p:IgnoreAnsiNulls=True` - Ignore ANSI_NULLS differences
- `/p:IgnoreAuthorizer=True` - Ignore authorization differences
- `/p:IgnoreColumnCollation=False` - Compare column collation
- `/p:IgnoreColumnOrder=False` - Compare column order
- `/p:IgnoreComments=True` - Ignore comment differences
- `/p:IgnoreCryptographicProviderFilePath=True` - Ignore crypto provider paths
- `/p:IgnoreDdlTriggerOrder=False` - Compare DDL trigger order
- `/p:IgnoreDdlTriggerState=False` - Compare DDL trigger state
- `/p:IgnoreDefaultSchema=False` - Compare default schema
- `/p:IgnoreDmlTriggerOrder=False` - Compare DML trigger order
- `/p:IgnoreDmlTriggerState=False` - Compare DML trigger state
- `/p:IgnoreExtendedProperties=False` - Compare extended properties
- `/p:IgnoreFileAndLogFilePath=True` - Ignore file paths (for portability)
- `/p:IgnoreFilegroupPlacement=True` - Ignore filegroup placement
- `/p:IgnoreFileSize=True` - Ignore file size settings
- `/p:IgnoreFillFactor=True` - Ignore fill factor settings
- `/p:IgnoreFullTextCatalogFilePath=True` - Ignore full-text catalog paths
- `/p:IgnoreIdentitySeed=False` - Compare identity seed values
- `/p:IgnoreIncrement=False` - Compare identity increment values
- `/p:IgnoreIndexOptions=False` - Compare index options
- `/p:IgnoreIndexPadding=True` - Ignore index padding
- `/p:IgnoreKeywordCasing=True` - Ignore T-SQL keyword casing
- `/p:IgnoreLockHintsOnIndexes=False` - Compare lock hints
- `/p:IgnoreLoginSids=True` - Ignore login SIDs
- `/p:IgnoreNotForReplication=False` - Compare NOT FOR REPLICATION
- `/p:IgnoreObjectPlacementOnPartitionScheme=True` - Ignore partition placement
- `/p:IgnorePartitionSchemes=False` - Compare partition schemes
- `/p:IgnorePermissions=False` - Compare permissions
- `/p:IgnoreQuotedIdentifiers=True` - Ignore QUOTED_IDENTIFIER
- `/p:IgnoreRoleMembership=False` - Compare role membership
- `/p:IgnoreRouteLifetime=True` - Ignore route lifetime
- `/p:IgnoreSemicolonBetweenStatements=True` - Ignore semicolons
- `/p:IgnoreTableOptions=False` - Compare table options
- `/p:IgnoreTablePartitionOptions=False` - Compare partition options
- `/p:IgnoreUserSettingsObjects=False` - Compare user settings
- `/p:IgnoreWhitespace=True` - Ignore whitespace differences
- `/p:IgnoreWithNocheckOnCheckConstraints=False` - Compare WITH NOCHECK
- `/p:IgnoreWithNocheckOnForeignKeys=False` - Compare FK WITH NOCHECK

**Performance & Scale:**
- `/p:CommandTimeout=60` - Command timeout (0 = infinite)
- `/p:LongRunningCommandTimeout=0` - Timeout for long operations
- `/p:DatabaseLockTimeout=60` - Lock timeout in seconds
- `/p:ScriptDatabaseOptions=True` - Script database options
- `/p:ScriptDeployStateChecks=False` - Include deployment state checks

**Examples:**
```bash
# Safe production deployment
sqlpackage /Action:Publish \
  /SourceFile:"MyDB.dacpac" \
  /TargetServerName:"prod-server" \
  /TargetDatabaseName:"ProductionDB" \
  /p:BlockOnPossibleDataLoss=True \
  /p:BackupDatabaseBeforeChanges=True \
  /p:DropObjectsNotInSource=False

# Development deployment (drop extra objects)
sqlpackage /Action:Publish \
  /SourceFile:"MyDB.dacpac" \
  /TargetServerName:"localhost" \
  /TargetDatabaseName:"DevDB" \
  /p:DropObjectsNotInSource=True

# Use publish profile
sqlpackage /Action:Publish \
  /SourceFile:"MyDB.dacpac" \
  /Profile:"Production.publish.xml"
```

### 3. Export - Create BACPAC with Data

**Purpose**: Export schema AND data to BACPAC file for migration/archival.

**Basic Syntax:**
```bash
sqlpackage /Action:Export \
  /SourceServerName:"<server>" \
  /SourceDatabaseName:"<database>" \
  /TargetFile:"<output>.bacpac" \
  [options]
```

**Key Properties:**
- `/p:CommandTimeout=0` - No timeout for large databases
- `/p:CompressionOption=Normal` - Normal, Maximum, Fast, SuperFast, NotCompressed
- `/p:Storage=Memory` - Memory or File (Memory faster for smaller DBs)
- `/p:TableData=<schema.table>` - Export specific tables only (repeatable)
- `/p:VerifyFullTextDocumentTypesSupported=True` - Check full-text support
- `/p:TempDirectoryForTableData=<path>` - Temp directory for staging

**Examples:**
```bash
# Export entire database
sqlpackage /Action:Export \
  /SourceServerName:"localhost" \
  /SourceDatabaseName:"CustomerDB" \
  /TargetFile:"CustomerDB.bacpac"

# Export specific tables only
sqlpackage /Action:Export \
  /SourceServerName:"localhost" \
  /SourceDatabaseName:"LargeDB" \
  /TargetFile:"LargeDB_Subset.bacpac" \
  /p:TableData=dbo.Customers \
  /p:TableData=dbo.Orders \
  /p:TableData=dbo.OrderDetails

# Export from Azure SQL with timeout
sqlpackage /Action:Export \
  /SourceServerName:"myserver.database.windows.net" \
  /SourceDatabaseName:"AzureDB" \
  /SourceUser:"admin" \
  /SourcePassword:"P@ssw0rd" \
  /TargetFile:"AzureDB.bacpac" \
  /p:CommandTimeout=0
```

### 4. Import - Restore BACPAC to Database

**Purpose**: Import schema and data from BACPAC to create/update database.

**Basic Syntax:**
```bash
sqlpackage /Action:Import \
  /SourceFile:"<bacpac-file>" \
  /TargetServerName:"<server>" \
  /TargetDatabaseName:"<database>" \
  [options]
```

**Key Properties:**
- `/p:CommandTimeout=0` - No timeout
- `/p:DatabaseEdition=<edition>` - Azure SQL: Basic, Standard, Premium, DataWarehouse, GeneralPurpose, BusinessCritical, Hyperscale
- `/p:DatabaseServiceObjective=<objective>` - Azure SQL: S0, S1, P1, P2, etc.
- `/p:DatabaseMaximumSize=<size>` - Maximum database size (e.g., 10 GB)
- `/p:Storage=Memory` - Memory or File

**Examples:**
```bash
# Import to SQL Server
sqlpackage /Action:Import \
  /SourceFile:"CustomerDB.bacpac" \
  /TargetServerName:"localhost" \
  /TargetDatabaseName:"CustomerDB_Restored"

# Import to Azure SQL with specific tier
sqlpackage /Action:Import \
  /SourceFile:"MyDB.bacpac" \
  /TargetServerName:"myserver.database.windows.net" \
  /TargetDatabaseName:"MyDB" \
  /TargetUser:"admin" \
  /TargetPassword:"P@ssw0rd" \
  /p:DatabaseEdition=Standard \
  /p:DatabaseServiceObjective=S2
```

### 5. Script - Generate Deployment Script

**Purpose**: Generate T-SQL deployment script without executing.

**Basic Syntax:**
```bash
sqlpackage /Action:Script \
  /SourceFile:"<dacpac-file>" \
  /TargetServerName:"<server>" \
  /TargetDatabaseName:"<database>" \
  /OutputPath:"<output>.sql" \
  [options]
```

**All Publish properties apply** (see Publish section above).

**Examples:**
```bash
# Generate deployment script
sqlpackage /Action:Script \
  /SourceFile:"MyDB.dacpac" \
  /TargetServerName:"prod-server" \
  /TargetDatabaseName:"ProductionDB" \
  /OutputPath:"deploy.sql" \
  /p:BlockOnPossibleDataLoss=True

# Script with specific options
sqlpackage /Action:Script \
  /SourceFile:"MyDB.dacpac" \
  /TargetServerName:"localhost" \
  /TargetDatabaseName:"TestDB" \
  /OutputPath:"update.sql" \
  /p:IgnoreWhitespace=True \
  /p:IgnoreComments=True
```

### 6. DeployReport - Generate Deployment Report

**Purpose**: Generate XML report of deployment changes without executing.

**Basic Syntax:**
```bash
sqlpackage /Action:DeployReport \
  /SourceFile:"<dacpac-file>" \
  /TargetServerName:"<server>" \
  /TargetDatabaseName:"<database>" \
  /OutputPath:"<output>.xml" \
  [options]
```

**All Publish properties apply**.

**Examples:**
```bash
# Generate deployment report
sqlpackage /Action:DeployReport \
  /SourceFile:"MyDB.dacpac" \
  /TargetServerName:"prod-server" \
  /TargetDatabaseName:"ProductionDB" \
  /OutputPath:"deploy-report.xml"

# Compare two DACPACs
sqlpackage /Action:DeployReport \
  /SourceFile:"MyDB_v2.dacpac" \
  /TargetFile:"MyDB_v1.dacpac" \
  /OutputPath:"v1-to-v2-report.xml"
```

### 7. DriftReport - Detect Schema Drift

**Purpose**: Compare live database to DACPAC and report drift.

**Basic Syntax:**
```bash
sqlpackage /Action:DriftReport \
  /SourceFile:"<dacpac-file>" \
  /TargetServerName:"<server>" \
  /TargetDatabaseName:"<database>" \
  /OutputPath:"<output>.xml" \
  [options]
```

**Key Properties:**
- Same comparison properties as DeployReport
- Reports objects in database NOT in DACPAC
- Reports objects modified differently than DACPAC

**Examples:**
```bash
# Detect production drift
sqlpackage /Action:DriftReport \
  /SourceFile:"expected-schema.dacpac" \
  /TargetServerName:"prod-server" \
  /TargetDatabaseName:"ProductionDB" \
  /OutputPath:"drift-report.xml"
```

## Connection Parameters

### SQL Server Authentication
```bash
/SourceServerName:"server"
/SourceDatabaseName:"database"
/SourceUser:"username"
/SourcePassword:"password"
/SourceTrustServerCertificate:True
/SourceEncryptConnection:True
```

### Windows Authentication
```bash
/SourceServerName:"server"
/SourceDatabaseName:"database"
/SourceIntegratedSecurity:True
```

### Azure Active Directory
```bash
# Interactive (with MFA)
/SourceServerName:"server.database.windows.net"
/SourceDatabaseName:"database"
/SourceAuthentication:ActiveDirectoryInteractive

# Password
/SourceAuthentication:ActiveDirectoryPassword
/SourceUser:"user@domain.com"
/SourcePassword:"password"

# Service Principal
/SourceAuthentication:ActiveDirectoryServicePrincipal
/SourceUser:"<app-id>"
/SourcePassword:"<secret>"

# Managed Identity
/SourceAuthentication:ActiveDirectoryManagedIdentity
```

### Connection String
```bash
/SourceConnectionString:"Server=<server>;Database=<database>;User Id=<user>;Password=<password>;"
```

## Advanced Deployment Scenarios

### Scenario 1: Safe Production Deployment

```bash
# Step 1: Generate report
sqlpackage /Action:DeployReport \
  /SourceFile:"MyDB_v2.0.dacpac" \
  /TargetServerName:"prod-server" \
  /TargetDatabaseName:"ProductionDB" \
  /OutputPath:"prod-deploy-report.xml" \
  /p:BlockOnPossibleDataLoss=True \
  /p:DropObjectsNotInSource=False

# Step 2: Review report, then generate script
sqlpackage /Action:Script \
  /SourceFile:"MyDB_v2.0.dacpac" \
  /TargetServerName:"prod-server" \
  /TargetDatabaseName:"ProductionDB" \
  /OutputPath:"prod-deploy.sql" \
  /p:BlockOnPossibleDataLoss=True \
  /p:DropObjectsNotInSource=False

# Step 3: Review script, then publish
sqlpackage /Action:Publish \
  /SourceFile:"MyDB_v2.0.dacpac" \
  /TargetServerName:"prod-server" \
  /TargetDatabaseName:"ProductionDB" \
  /p:BlockOnPossibleDataLoss=True \
  /p:BackupDatabaseBeforeChanges=True \
  /p:DropObjectsNotInSource=False \
  /p:DoNotDropObjectTypes=Users;Logins;RoleMembership;Permissions
```

### Scenario 2: Development Sync

```bash
# Drop objects not in source for clean dev environment
sqlpackage /Action:Publish \
  /SourceFile:"MyDB.dacpac" \
  /TargetServerName:"localhost" \
  /TargetDatabaseName:"DevDB" \
  /p:DropObjectsNotInSource=True \
  /p:BlockOnPossibleDataLoss=False
```

### Scenario 3: Database Migration

```bash
# Export from source
sqlpackage /Action:Export \
  /SourceServerName:"old-server" \
  /SourceDatabaseName:"LegacyDB" \
  /TargetFile:"migration.bacpac" \
  /p:CommandTimeout=0

# Import to destination
sqlpackage /Action:Import \
  /SourceFile:"migration.bacpac" \
  /TargetServerName:"new-server" \
  /TargetDatabaseName:"ModernDB" \
  /p:CommandTimeout=0
```

### Scenario 4: Multi-Environment Deployment

```bash
# Use variables for environments
DACPAC="MyDB.dacpac"

# Dev
sqlpackage /Action:Publish \
  /SourceFile:"$DACPAC" \
  /Profile:"Dev.publish.xml"

# QA
sqlpackage /Action:Publish \
  /SourceFile:"$DACPAC" \
  /Profile:"QA.publish.xml"

# Production
sqlpackage /Action:Publish \
  /SourceFile:"$DACPAC" \
  /Profile:"Prod.publish.xml"
```

## Publish Profile (.publish.xml)

**Example Profile:**
```xml
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="Current" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <IncludeCompositeObjects>True</IncludeCompositeObjects>
    <TargetDatabaseName>ProductionDB</TargetDatabaseName>
    <TargetConnectionString>Data Source=prod-server;Integrated Security=True;Persist Security Info=False;Pooling=False;MultipleActiveResultSets=False;Connect Timeout=60;Encrypt=False;TrustServerCertificate=False</TargetConnectionString>
    <ProfileVersionNumber>1</ProfileVersionNumber>

    <!-- Safety -->
    <BlockOnPossibleDataLoss>True</BlockOnPossibleDataLoss>
    <BackupDatabaseBeforeChanges>True</BackupDatabaseBeforeChanges>
    <DropObjectsNotInSource>False</DropObjectsNotInSource>

    <!-- Don't drop these object types -->
    <DoNotDropObjectTypes>Users;Logins;RoleMembership;Permissions;Credentials;DatabaseScopedCredentials</DoNotDropObjectTypes>

    <!-- Ignore differences -->
    <IgnoreWhitespace>True</IgnoreWhitespace>
    <IgnoreComments>True</IgnoreComments>
    <IgnoreFileAndLogFilePath>True</IgnoreFileAndLogFilePath>
    <IgnoreFilegroupPlacement>True</IgnoreFilegroupPlacement>

    <!-- SQLCMD Variables -->
    <SqlCmdVariableValues>
      <SqlCmdVariable Include="Environment">
        <Value>Production</Value>
      </SqlCmdVariable>
    </SqlCmdVariableValues>
  </PropertyGroup>
</Project>
```

## Getting Help

**List all actions:**
```bash
sqlpackage /?
```

**Get action-specific help:**
```bash
sqlpackage /Action:Publish /?
sqlpackage /Action:Extract /?
```

**List all deployment properties:**
```bash
sqlpackage /Action:Publish /p:?
```

## Best Practices

1. **Always preview before production** - Use DeployReport or Script first
2. **Use publish profiles** - Store deployment settings in version control
3. **Block data loss in production** - `/p:BlockOnPossibleDataLoss=True`
4. **Backup before changes** - `/p:BackupDatabaseBeforeChanges=True`
5. **Don't drop user objects** - `/p:DoNotDropObjectTypes=Users;Logins;...`
6. **Use timeouts wisely** - `/p:CommandTimeout=0` for large operations
7. **Test with same options** - Use identical settings for all environments
8. **Version your DACPACs** - Include version in filename
9. **Store credentials securely** - Use Azure Key Vault, don't hardcode
10. **Monitor deployments** - Review deployment reports and logs

## Platform Support

| Platform | Installation Method | Support |
|----------|-------------------|---------|
| Windows | .NET tool, Standalone, Visual Studio | Full |
| Linux | .NET tool, Standalone | Full |
| macOS | .NET tool, Standalone | Full |
| Docker | .NET tool in container | Full |
| Azure Cloud Shell | Pre-installed | Full |

## Troubleshooting

**Issue**: "SqlPackage command not found"
```bash
# Install as .NET global tool
dotnet tool install -g Microsoft.SqlPackage

# Or add to PATH (Windows)
set PATH=%PATH%;C:\Program Files\Microsoft SQL Server\160\DAC\bin
```

**Issue**: "Timeout expired"
```bash
# Increase timeout
/p:CommandTimeout=0  # Infinite timeout
/p:LongRunningCommandTimeout=0
```

**Issue**: "Blocked by data loss"
```bash
# Review what would be dropped
sqlpackage /Action:Script ... /OutputPath:review.sql

# If acceptable, allow data loss (NOT for production!)
/p:BlockOnPossibleDataLoss=False
```

**Issue**: "Login failed"
```bash
# Check authentication method
/SourceIntegratedSecurity:True  # Windows auth
# Or
/SourceUser:"user" /SourcePassword:"pass"  # SQL auth

# For Azure SQL, add firewall rule for your IP
```

## Git Bash / MINGW / MSYS2 Path Conversion Issues

**CRITICAL for Windows Git Bash Users**: SqlPackage parameters starting with `/` trigger automatic path conversion in Git Bash/MINGW, causing commands to fail.

### The Problem

```bash
# FAILS in Git Bash - /Action gets converted to file path
sqlpackage /Action:Publish /SourceFile:MyDB.dacpac /TargetServerName:localhost
# Error: Invalid parameter (Git Bash converted /Action to C:/Program Files/Git/usr/Action)
```

### Solutions

**Method 1: MSYS_NO_PATHCONV=1 (Recommended)**

```bash
# Disable path conversion for SqlPackage
MSYS_NO_PATHCONV=1 sqlpackage /Action:Extract \
  /SourceServerName:"localhost" \
  /SourceDatabaseName:"MyDB" \
  /TargetFile:"MyDB.dacpac"

MSYS_NO_PATHCONV=1 sqlpackage /Action:Publish \
  /SourceFile:"MyDB.dacpac" \
  /TargetServerName:"localhost" \
  /TargetDatabaseName:"MyDB" \
  /p:BlockOnPossibleDataLoss=True
```

**Method 2: Double Slash // (Shell-Agnostic)**

```bash
# Works in all shells without environment variables
sqlpackage //Action:Extract \
  //SourceServerName:localhost \
  //SourceDatabaseName:MyDB \
  //TargetFile:MyDB.dacpac

sqlpackage //Action:Publish \
  //SourceFile:MyDB.dacpac \
  //TargetServerName:localhost \
  //TargetDatabaseName:MyDB \
  //p:BlockOnPossibleDataLoss=True
```

**Method 3: Use PowerShell (Recommended for Windows)**

```powershell
# PowerShell - native Windows shell, no path issues
sqlpackage /Action:Publish `
  /SourceFile:"MyDB.dacpac" `
  /TargetServerName:"localhost" `
  /TargetDatabaseName:"MyDB" `
  /p:BlockOnPossibleDataLoss=True
```

### All Actions with Git Bash Workarounds

```bash
# Extract - Method 1 (MSYS_NO_PATHCONV)
MSYS_NO_PATHCONV=1 sqlpackage /Action:Extract \
  /SourceServerName:"localhost" /SourceDatabaseName:"MyDB" \
  /TargetFile:"MyDB.dacpac"

# Publish - Method 2 (Double Slash)
sqlpackage //Action:Publish \
  //SourceFile:MyDB.dacpac \
  //TargetServerName:localhost //TargetDatabaseName:MyDB

# Export
MSYS_NO_PATHCONV=1 sqlpackage /Action:Export \
  /SourceServerName:"localhost" /SourceDatabaseName:"MyDB" \
  /TargetFile:"MyDB.bacpac"

# Import
MSYS_NO_PATHCONV=1 sqlpackage /Action:Import \
  /SourceFile:"MyDB.bacpac" \
  /TargetServerName:"localhost" /TargetDatabaseName:"MyDB_Restored"

# DeployReport
MSYS_NO_PATHCONV=1 sqlpackage /Action:DeployReport \
  /SourceFile:"MyDB.dacpac" \
  /TargetServerName:"localhost" /TargetDatabaseName:"MyDB" \
  /OutputPath:"deploy-report.xml"

# Script
MSYS_NO_PATHCONV=1 sqlpackage /Action:Script \
  /SourceFile:"MyDB.dacpac" \
  /TargetServerName:"localhost" /TargetDatabaseName:"MyDB" \
  /OutputPath:"deploy.sql"

# DriftReport
MSYS_NO_PATHCONV=1 sqlpackage /Action:DriftReport \
  /TargetServerName:"localhost" /TargetDatabaseName:"MyDB" \
  /OutputPath:"drift-report.xml"
```

### Shell Detection Script

```bash
#!/bin/bash
# Detect Git Bash and set path conversion flag

if [ -n "$MSYSTEM" ]; then
  echo "Git Bash/MSYS2 detected - disabling path conversion"
  export MSYS_NO_PATHCONV=1
fi

# Now all SqlPackage commands will work correctly
sqlpackage /Action:Extract \
  /SourceServerName:"localhost" \
  /SourceDatabaseName:"MyDB" \
  /TargetFile:"MyDB.dacpac"
```

### Common Path Issues

**Spaces in paths:**
```bash
# WRONG - unquoted
MSYS_NO_PATHCONV=1 sqlpackage /Action:Publish /SourceFile:D:/Program Files/MyDB.dacpac

# CORRECT - quoted
MSYS_NO_PATHCONV=1 sqlpackage /Action:Publish /SourceFile:"D:/Program Files/MyDB.dacpac"
```

**Connection strings:**
```bash
# Quote entire connection string
MSYS_NO_PATHCONV=1 sqlpackage /Action:Publish \
  /SourceFile:"MyDB.dacpac" \
  /TargetConnectionString:"Server=localhost;Database=MyDB;Integrated Security=True;"
```

**Publish profiles:**
```bash
# Quote profile paths
MSYS_NO_PATHCONV=1 sqlpackage /Action:Publish \
  /SourceFile:"MyDB.dacpac" \
  /Profile:"./Profiles/Production.publish.xml"
```

### Recommended Approach

For Windows SSDT development:
1. **Use PowerShell** - Native Windows shell, no path issues
2. **Use CMD** - Also no path conversion problems
3. **Use Git Bash with MSYS_NO_PATHCONV=1** - If Git Bash preferred
4. **Use double-slash //Action** - Most portable across shells

**For comprehensive Git Bash path handling**, see the `windows-git-bash-paths` skill documentation.

## Next Steps

After SqlPackage operations:
- Review deployment reports before production
- Test generated scripts in non-production
- Monitor database performance after deployment
- Document any manual steps required
- Archive DACPAC/BACPAC files with version info

IMPORTANT: SqlPackage is the core tool for database deployments. Master all its options to ensure safe, reliable database changes across all environments.
