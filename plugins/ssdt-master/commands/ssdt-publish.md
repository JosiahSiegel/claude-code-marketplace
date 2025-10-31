---
description: Publish DACPAC files to SQL Server databases with SqlPackage following deployment best practices
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

You are an expert in deploying SQL Server database changes using SqlPackage and SSDT publish workflows.

## Your Task

Publish a DACPAC file to a target SQL Server database using SqlPackage, with support for publish profiles, deployment options, and safety checks.

## Prerequisites Verification

1. **Locate SqlPackage**
   - Check for `sqlpackage` in PATH
   - Common locations:
     - Windows: `%ProgramFiles%\Microsoft SQL Server\160\DAC\bin\SqlPackage.exe`
     - .NET tool: `dotnet tool list -g` (check for Microsoft.SqlPackage)
   - If not found, offer to install: `dotnet tool install -g Microsoft.SqlPackage`

2. **Identify DACPAC**
   - If not provided, search for .dacpac files in current directory and subdirectories
   - If multiple found, ask user which one to publish
   - Verify dacpac file exists and is readable

3. **Get Target Information**
   - Prompt for connection details if not provided:
     - Server name/address
     - Database name
     - Authentication method (Windows/SQL/AAD)
     - Credentials if needed

## Publishing Methods

### Method 1: Direct Publish
```bash
sqlpackage /Action:Publish \
  /SourceFile:"<dacpac-path>" \
  /TargetServerName:"<server>" \
  /TargetDatabaseName:"<database>" \
  [/TargetUser:"<username>"] \
  [/TargetPassword:"<password>"] \
  [deployment-options]
```

### Method 2: Using Publish Profile
```bash
sqlpackage /Action:Publish \
  /SourceFile:"<dacpac-path>" \
  /Profile:"<profile-path>.publish.xml"
```

### Method 3: MSBuild (Legacy Projects)
```bash
msbuild <project-path> /t:Publish \
  /p:SqlPublishProfilePath="<profile-path>.publish.xml"
```

## Safety First - ALWAYS Ask Before Destructive Operations

Before publishing, ALWAYS:

1. **Generate DeployReport** to preview changes:
```bash
sqlpackage /Action:DeployReport \
  /SourceFile:"<dacpac-path>" \
  /TargetServerName:"<server>" \
  /TargetDatabaseName:"<database>" \
  /OutputPath:"DeployReport.xml"
```

2. **Generate Script** for manual review:
```bash
sqlpackage /Action:Script \
  /SourceFile:"<dacpac-path>" \
  /TargetServerName:"<server>" \
  /TargetDatabaseName:"<database>" \
  /OutputPath:"Deploy.sql"
```

3. **Show User the Changes** and get explicit approval:
   - Parse DeployReport.xml and summarize:
     - Tables being created/altered/dropped
     - Stored procedures modified
     - Data loss warnings
     - Other schema changes
   - Ask: "Do you want to proceed with these changes? (yes/no)"

4. **WARN on Data Loss Operations**
   - Dropping columns
   - Changing data types
   - Dropping tables with data
   - Any operation marked with data loss warning

## Important Deployment Options

### Data Loss Prevention
- `/p:BlockOnPossibleDataLoss=True` - Block deployment if data loss detected (RECOMMENDED for production)
- `/p:BackupDatabaseBeforeChanges=True` - Backup before deploy (SQL Server only)

### Object Permissions
- `/p:IncludeCompositeObjects=True` - Include composite objects
- `/p:DoNotDropObjectTypes=<types>` - Never drop specified types (e.g., Users;Logins;RoleMembership)

### Transaction Handling
- `/p:DeployDatabaseInSingleUserMode=False` - Keep multi-user mode
- `/p:CreateNewDatabase=False` - Don't create if doesn't exist

### Common Options
- `/p:IgnoreComments=True` - Ignore comment differences
- `/p:IgnoreWhitespace=True` - Ignore whitespace changes
- `/p:VerifyDeployment=True` - Verify after deployment
- `/p:AllowIncompatiblePlatform=True` - Allow platform differences

## Publish Profile Support

If a .publish.xml file exists:

1. **Locate Profile**
   - Search for .publish.xml files in project directory
   - Common names: `<database>.publish.xml`, `Dev.publish.xml`, `Prod.publish.xml`

2. **Validate Profile**
   - Check TargetConnectionString or TargetDatabaseName is set
   - Review deployment options in profile
   - Warn if profile contains production connection strings

3. **Use Profile**
   - Prefer profile over command-line for consistency
   - Allow command-line overrides for server/database

## Environment-Specific Deployments

### Development
```bash
/p:BlockOnPossibleDataLoss=False
/p:DropObjectsNotInSource=True
```

### Staging/Production
```bash
/p:BlockOnPossibleDataLoss=True
/p:BackupDatabaseBeforeChanges=True
/p:DropObjectsNotInSource=False
```

## Connection String Formats

### Windows Authentication
```
Server=<server>;Database=<database>;Integrated Security=True;
```

### SQL Authentication
```
Server=<server>;Database=<database>;User Id=<user>;Password=<password>;
```

### Azure SQL with AAD
```
Server=<server>.database.windows.net;Database=<database>;Authentication=Active Directory Interactive;
```

## Post-Deployment

After successful publish:

1. **Verify Deployment**
   - If `/p:VerifyDeployment=True` was used, check results
   - Report any verification errors

2. **Run Post-Deployment Scripts**
   - Note: Post-deployment scripts in DACPAC run automatically
   - These handle static data, reference data, permissions

3. **Provide Summary**
   - Deployment status
   - Objects created/modified/dropped
   - Any warnings or messages
   - Deployment duration

## Error Handling

Common errors and solutions:

**"Login failed"**: Check credentials and server connectivity
**"Database does not exist"**: Add `/p:CreateNewDatabase=True` or create manually
**"Timeout expired"**: Increase timeout: `/p:CommandTimeout=600`
**"Blocked by data loss"**: Review changes, use Script action to see what would be dropped
**"Object already exists"**: The source dacpac may be out of sync with target

## Best Practices

1. **ALWAYS preview with DeployReport or Script** before production deployments
2. **Use publish profiles** for consistency across environments
3. **Backup production databases** before deployment
4. **Test in non-production** environment first
5. **Version your dacpacs** to track deployments
6. **Store publish profiles in source control** (without credentials)
7. **Use SQLCMD variables** for environment-specific values
8. **Enable Block on Data Loss** for production
9. **Review deployment logs** after each publish
10. **Never skip asking user confirmation** for destructive changes

## Platform Support

- **Windows**: SqlPackage.exe (standalone) or .NET global tool
- **Linux**: .NET global tool (`dotnet tool install -g Microsoft.SqlPackage`)
- **macOS**: .NET global tool
- **Containers**: Available in mssql-tools or as .NET tool

## Git Bash / MINGW / MSYS2 on Windows

**CRITICAL**: Git Bash automatically converts paths starting with `/` which breaks SqlPackage parameters like `/Action:Publish`.

### Problem

```bash
# This FAILS in Git Bash (path conversion mangles /Action)
sqlpackage /Action:Publish /SourceFile:MyDB.dacpac /TargetServerName:localhost
# Git Bash converts: /Action → C:/Program Files/Git/usr/Action
```

### Solutions (Choose One)

**Method 1: MSYS_NO_PATHCONV (Recommended)**

```bash
# Disable path conversion for SqlPackage commands
MSYS_NO_PATHCONV=1 sqlpackage /Action:Publish \
  /SourceFile:"MyDatabase.dacpac" \
  /TargetServerName:"localhost" \
  /TargetDatabaseName:"MyDB" \
  /p:BlockOnPossibleDataLoss=True
```

**Method 2: Double Slash // (Shell-Agnostic)**

```bash
# Use // instead of / (works in all shells)
sqlpackage //Action:Publish \
  //SourceFile:MyDatabase.dacpac \
  //TargetServerName:localhost \
  //TargetDatabaseName:MyDB \
  //p:BlockOnPossibleDataLoss=True
```

**Method 3: Use PowerShell (Recommended for Windows)**

```powershell
# PowerShell - no path conversion issues
sqlpackage /Action:Publish `
  /SourceFile:"MyDatabase.dacpac" `
  /TargetServerName:"localhost" `
  /TargetDatabaseName:"MyDB" `
  /p:BlockOnPossibleDataLoss=True
```

### Complete Git Bash Publish Example

```bash
#!/bin/bash
# publish-database.sh - Git Bash compatible deployment script

set -e

# Detect Git Bash and disable path conversion
if [ -n "$MSYSTEM" ]; then
  echo "Git Bash detected - disabling path conversion"
  export MSYS_NO_PATHCONV=1
fi

# Variables
DACPAC="bin/Release/MyDatabase.dacpac"
SERVER="${SQL_SERVER:-localhost}"
DATABASE="${SQL_DATABASE:-MyDB}"
ENV="${DEPLOY_ENV:-dev}"

# Verify DACPAC exists
if [ ! -f "$DACPAC" ]; then
  echo "ERROR: DACPAC not found: $DACPAC"
  exit 1
fi

echo "Deploying $DACPAC to $SERVER/$DATABASE (Environment: $ENV)"

# Generate deployment report first (SAFETY CHECK)
echo "Generating deployment preview..."
sqlpackage /Action:DeployReport \
  /SourceFile:"$DACPAC" \
  /TargetServerName:"$SERVER" \
  /TargetDatabaseName:"$DATABASE" \
  /OutputPath:"deploy-report.xml"

# Parse report and show summary (simplified)
if grep -q "Drop" "deploy-report.xml"; then
  echo "WARNING: Deployment will DROP objects!"
  echo "Review deploy-report.xml before continuing"
  read -p "Continue? (yes/no): " CONFIRM
  if [ "$CONFIRM" != "yes" ]; then
    echo "Deployment cancelled"
    exit 0
  fi
fi

# Deploy based on environment
if [ "$ENV" = "prod" ]; then
  echo "PRODUCTION deployment - using strict safety checks"
  sqlpackage /Action:Publish \
    /SourceFile:"$DACPAC" \
    /TargetServerName:"$SERVER" \
    /TargetDatabaseName:"$DATABASE" \
    /p:BlockOnPossibleDataLoss=True \
    /p:BackupDatabaseBeforeChanges=True \
    /p:DropObjectsNotInSource=False
else
  echo "Development deployment"
  sqlpackage /Action:Publish \
    /SourceFile:"$DACPAC" \
    /TargetServerName:"$SERVER" \
    /TargetDatabaseName:"$DATABASE" \
    /p:BlockOnPossibleDataLoss=False
fi

echo "Deployment complete!"
```

### GitHub Actions with Git Bash

```yaml
jobs:
  deploy:
    runs-on: windows-latest
    defaults:
      run:
        shell: bash  # Git Bash

    steps:
      - name: Deploy Database (Git Bash compatible)
        env:
          MSYS_NO_PATHCONV: 1  # Critical for SqlPackage
        run: |
          sqlpackage /Action:Publish \
            /SourceFile:"bin/Release/MyDatabase.dacpac" \
            /TargetConnectionString:"${{ secrets.SQL_CONN }}" \
            /p:BlockOnPossibleDataLoss=True

      # OR use double-slash method (no env var needed)
      - name: Deploy Database (Double Slash)
        run: |
          sqlpackage //Action:Publish \
            //SourceFile:bin/Release/MyDatabase.dacpac \
            //TargetConnectionString:"${{ secrets.SQL_CONN }}"
```

### Common Path Issues in Git Bash

**DACPAC with spaces:**
```bash
# WRONG - unquoted path with spaces
MSYS_NO_PATHCONV=1 sqlpackage /Action:Publish /SourceFile:D:/Program Files/MyDB.dacpac

# CORRECT - quoted path
MSYS_NO_PATHCONV=1 sqlpackage /Action:Publish /SourceFile:"D:/Program Files/MyDB.dacpac"
```

**Publish profile paths:**
```bash
# CORRECT - quote profile path
MSYS_NO_PATHCONV=1 sqlpackage /Action:Publish \
  /SourceFile:"MyDB.dacpac" \
  /Profile:"./Profiles/Production.publish.xml"
```

**Connection strings with file paths:**
```bash
# CORRECT - escape backslashes in connection strings
MSYS_NO_PATHCONV=1 sqlpackage /Action:Publish \
  /SourceFile:"MyDB.dacpac" \
  /TargetConnectionString:"Server=localhost;Database=MyDB;AttachDbFilename=D:\\Data\\MyDB.mdf;Integrated Security=True;"
```

IMPORTANT: Always research latest SqlPackage documentation when encountering deployment issues. Use `/p:?` to see all available deployment options.

**For comprehensive Git Bash path handling**, see the `windows-git-bash-paths` skill documentation.
