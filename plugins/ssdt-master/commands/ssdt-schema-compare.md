---
description: Compare database schemas using SqlPackage and MSBuild schema compare functionality
---

You are an expert in comparing SQL Server database schemas using SSDT tools.

## Your Task

Compare two database schemas (DACPAC to DACPAC, DACPAC to Database, or Database to Database) and optionally generate update scripts or deploy changes.

## Schema Compare Methods

### Method 1: SqlPackage DeployReport

Generate an XML report of schema differences:

```bash
sqlpackage /Action:DeployReport \
  /SourceFile:"<source.dacpac>" \
  /TargetServerName:"<server>" \
  /TargetDatabaseName:"<database>" \
  /OutputPath:"report.xml" \
  [options]
```

**Compare Two DACPACs**:
```bash
sqlpackage /Action:DeployReport \
  /SourceFile:"<source.dacpac>" \
  /TargetFile:"<target.dacpac>" \
  /OutputPath:"report.xml"
```

### Method 2: SqlPackage Script

Generate a T-SQL script of changes needed:

```bash
sqlpackage /Action:Script \
  /SourceFile:"<source.dacpac>" \
  /TargetServerName:"<server>" \
  /TargetDatabaseName:"<database>" \
  /OutputPath:"update.sql" \
  [options]
```

### Method 3: MSBuild Schema Compare

For advanced scenarios with .scmp files:

```bash
msbuild /t:SqlSchemaCompare \
  /p:SourceDacpac="<source.dacpac>" \
  /p:TargetDacpac="<target.dacpac>" \
  /p:XmlOutput="report.xml"
```

Or using a saved comparison file:
```bash
msbuild /t:SqlSchemaCompare \
  /p:SqlScmpFilePath="<comparison.scmp>" \
  /p:XmlOutput="report.xml"
```

## Comparison Workflow

### 1. Identify Sources

**Source** (what you want to apply):
- DACPAC file from project build
- Existing database
- Another DACPAC for comparison

**Target** (what you want to update):
- Target database
- Target DACPAC
- Another database

### 2. Configure Comparison Options

Common comparison options:

**Ignore Options** (reduce noise):
```bash
/p:IgnoreWhitespace=True
/p:IgnoreComments=True
/p:IgnoreSemicolonBetweenStatements=True
/p:IgnoreKeywordCasing=True
/p:IgnoreAuthorizer=True
/p:IgnoreAnsiNulls=True
/p:IgnoreQuotedIdentifiers=True
```

**Include/Exclude Objects**:
```bash
/p:DoNotDropObjectTypes=Users;Logins;RoleMembership;Permissions
/p:ExcludeObjectTypes=Users;Logins
```

**Data Loss Prevention**:
```bash
/p:BlockOnPossibleDataLoss=True
```

### 3. Generate and Analyze Report

**Parse DeployReport.xml**:
```xml
<DeploymentReport>
  <Operations>
    <Operation Name="Create" Type="SqlTable">
      <Item Value="[dbo].[NewTable]"/>
    </Operation>
    <Operation Name="Alter" Type="SqlStoredProcedure">
      <Item Value="[dbo].[UpdatedProc]"/>
    </Operation>
    <Operation Name="Drop" Type="SqlTable">
      <Item Value="[dbo].[OldTable]" DataLoss="True"/>
    </Operation>
  </Operations>
</DeploymentReport>
```

**Present Summary**:
- Tables: X created, Y altered, Z dropped
- Stored Procedures: X created, Y altered, Z dropped
- Views: X created, Y altered, Z dropped
- Functions: X created, Y altered, Z dropped
- WARNING: N operations may cause data loss

### 4. Review Generated Script

If using Script action, show:
- Pre-deployment checks
- Schema changes
- Post-deployment steps
- Highlight any DROP statements or data loss risks

## Comparison Scenarios

### Scenario 1: Project to Database (Pre-Deployment Check)

**Purpose**: See what would change before publishing

```bash
sqlpackage /Action:DeployReport \
  /SourceFile:"bin/Release/MyDatabase.dacpac" \
  /TargetServerName:"localhost" \
  /TargetDatabaseName:"MyDatabase" \
  /OutputPath:"PreDeployReport.xml"
```

**Then present changes and ask**: "Proceed with deployment?"

### Scenario 2: Environment Drift Detection

**Purpose**: Check if production database matches expected schema

```bash
sqlpackage /Action:DeployReport \
  /SourceFile:"Production_v1.2.0.dacpac" \
  /TargetServerName:"prod-server" \
  /TargetDatabaseName:"ProductionDB" \
  /OutputPath:"DriftReport.xml"
```

**Alert if differences found**: Schema drift detected!

### Scenario 3: Database to Database

**Purpose**: Compare two database instances

```bash
# First extract both to DACPAC
sqlpackage /Action:Extract \
  /SourceServerName:"server1" \
  /SourceDatabaseName:"DB1" \
  /TargetFile:"db1.dacpac"

sqlpackage /Action:Extract \
  /SourceServerName:"server2" \
  /SourceDatabaseName:"DB2" \
  /TargetFile:"db2.dacpac"

# Then compare
sqlpackage /Action:DeployReport \
  /SourceFile:"db1.dacpac" \
  /TargetFile:"db2.dacpac" \
  /OutputPath:"comparison.xml"
```

### Scenario 4: Version Comparison

**Purpose**: See changes between two versions

```bash
sqlpackage /Action:Script \
  /SourceFile:"MyDB_v1.2.0.dacpac" \
  /TargetFile:"MyDB_v1.1.0.dacpac" \
  /OutputPath:"v1.1.0_to_v1.2.0.sql"
```

**Result**: Migration script from v1.1.0 to v1.2.0

## Advanced Features

### Save Comparison Configuration (.scmp)

In Visual Studio, you can save schema comparison settings to a .scmp file. This file can be used with MSBuild:

**Find .scmp files**:
```bash
# Search for schema compare files
find . -name "*.scmp"
```

**Run saved comparison**:
```bash
msbuild /t:SqlSchemaCompare \
  /p:SqlScmpFilePath="SchemaCompare.scmp" \
  /p:XmlOutput="ComparisonResult.xml"
```

### Apply Schema Changes

After reviewing comparison, you can:

**Option 1: Use generated script**:
```bash
# Execute the script manually in SSMS or sqlcmd
sqlcmd -S <server> -d <database> -i update.sql
```

**Option 2: Direct publish**:
```bash
# Skip comparison, deploy directly
sqlpackage /Action:Publish \
  /SourceFile:"<source.dacpac>" \
  /TargetServerName:"<server>" \
  /TargetDatabaseName:"<database>"
```

**Option 3: MSBuild deploy**:
```bash
msbuild /t:SqlSchemaCompare \
  /p:SqlScmpFilePath:"comparison.scmp" \
  /p:Deploy=true
```

## Filtering Comparisons

### Exclude System Objects
```bash
/p:IgnoreSystemObjects=True
```

### Compare Specific Object Types
Use DoNotDropObjectTypes for object-level filtering:
```bash
/p:DoNotDropObjectTypes=Tables;Views;StoredProcedures
```

### Ignore Permissions and Users
```bash
/p:IgnorePermissions=True
/p:IgnoreUserSettingsObjects=True
```

## Interpreting Results

### Green/Safe Changes
- Adding new tables, procedures, views
- Adding new columns (with defaults or nullable)
- Creating new indexes

### Yellow/Caution Changes
- Modifying stored procedures (may affect apps)
- Adding NOT NULL columns without defaults
- Changing data types (may need conversion)

### Red/Dangerous Changes
- Dropping tables or columns (data loss)
- Changing column data types incompatibly
- Removing indexes (performance impact)

## Best Practices

1. **Always compare before deploying** to production
2. **Review the script**, don't just trust the comparison
3. **Test generated scripts** in non-production first
4. **Document schema drift** when detected in production
5. **Use comparison options** to reduce noise
6. **Save comparison configurations** (.scmp) for repeatability
7. **Version control comparison results** for audit trails
8. **Automate drift detection** in CI/CD pipelines
9. **Set up alerts** for production schema drift
10. **Never auto-deploy** comparison results to production

## Troubleshooting

**Issue**: Comparison shows too many differences
- Solution: Review ignore options, may need to ignore whitespace/comments

**Issue**: Comparison fails with timeout
- Solution: Increase timeout: `/p:CommandTimeout=600`

**Issue**: Comparison misses objects
- Solution: Check object inclusion/exclusion settings

**Issue**: DeployReport.xml is empty
- Solution: No differences detected, schemas match

## Platform Considerations

- **Windows**: Full support (SqlPackage + MSBuild)
- **Linux/macOS**: SqlPackage actions only (DeployReport, Script)
- **MSBuild schema compare**: Windows with Visual Studio/Build Tools only
- **CI/CD**: Use SqlPackage for cross-platform pipelines

## Next Steps

After schema comparison:
- If differences acceptable: "/ssdt-master:publish to deploy"
- If drift detected: "Investigate why production differs from source control"
- If generating migration: "Review and test the generated script"

IMPORTANT: Schema comparison is a READ operation - it never modifies databases. Always review before applying changes.
