---
description: Generate detailed deployment reports showing exactly what changes would be made before deploying
---

You are an expert in generating and analyzing SQL Server deployment reports using SqlPackage.

## Your Task

Generate comprehensive deployment reports that show exactly what schema changes would occur, identify potential issues, and help users make informed deployment decisions.

## What is a Deployment Report?

A deployment report is an XML file that details:
- **Operations**: Every schema change that would be executed
- **Data Loss Warnings**: Any operations that could cause data loss
- **Object Changes**: Creates, alters, and drops for all object types
- **Deployment Script**: The actual T-SQL that would run
- **Dependencies**: Object dependency analysis

**Critical**: Deployment reports are READ-ONLY. They never modify databases.

## Generating Deployment Reports

### Method 1: DeployReport Action

**Compare DACPAC to Database:**
```bash
sqlpackage /Action:DeployReport \
  /SourceFile:"<dacpac-file>" \
  /TargetServerName:"<server>" \
  /TargetDatabaseName:"<database>" \
  /OutputPath:"<report>.xml" \
  [options]
```

**Compare DACPAC to DACPAC:**
```bash
sqlpackage /Action:DeployReport \
  /SourceFile:"<source>.dacpac" \
  /TargetFile:"<target>.dacpac" \
  /OutputPath:"<report>.xml"
```

**Examples:**
```bash
# Pre-deployment report for production
sqlpackage /Action:DeployReport \
  /SourceFile:"MyDB_v2.0.dacpac" \
  /TargetServerName:"prod-server" \
  /TargetDatabaseName:"ProductionDB" \
  /OutputPath:"prod-deploy-report.xml" \
  /p:BlockOnPossibleDataLoss=True

# Version comparison (v1 to v2)
sqlpackage /Action:DeployReport \
  /SourceFile:"MyDB_v2.0.dacpac" \
  /TargetFile:"MyDB_v1.0.dacpac" \
  /OutputPath:"v1-to-v2-changes.xml"

# Development environment check
sqlpackage /Action:DeployReport \
  /SourceFile:"MyDB.dacpac" \
  /TargetServerName:"localhost" \
  /TargetDatabaseName:"DevDB" \
  /OutputPath:"dev-sync-report.xml" \
  /p:DropObjectsNotInSource=True
```

### Method 2: DriftReport Action

**Detect Schema Drift:**
```bash
sqlpackage /Action:DriftReport \
  /SourceFile:"<expected-schema>.dacpac" \
  /TargetServerName:"<server>" \
  /TargetDatabaseName:"<database>" \
  /OutputPath:"<drift-report>.xml"
```

**Purpose**: Identify unauthorized changes in production databases.

**Examples:**
```bash
# Check production drift
sqlpackage /Action:DriftReport \
  /SourceFile:"expected-prod-schema.dacpac" \
  /TargetServerName:"prod-server" \
  /TargetDatabaseName:"ProductionDB" \
  /OutputPath:"drift-detection.xml"
```

## Report Structure

### DeployReport.xml Format

```xml
<?xml version="1.0" encoding="utf-8"?>
<DeploymentReport xmlns="http://schemas.microsoft.com/sqlserver/dac/DeployReport/2012/02">
  <Alerts>
    <Alert Name="DataLoss">
      <Issue Value="Dropping column [dbo].[Customer].[LegacyId] could result in data loss" Id="1"/>
    </Alert>
  </Alerts>

  <Operations>
    <!-- Table Operations -->
    <Operation Name="Create">
      <Item Value="[dbo].[NewCustomer]" Type="SqlTable"/>
    </Operation>

    <Operation Name="Alter">
      <Item Value="[dbo].[Order]" Type="SqlTable"/>
    </Operation>

    <Operation Name="Drop" DataLoss="True">
      <Item Value="[dbo].[LegacyTable]" Type="SqlTable"/>
    </Operation>

    <!-- Stored Procedure Operations -->
    <Operation Name="Create">
      <Item Value="[dbo].[usp_GetCustomer]" Type="SqlProcedure"/>
    </Operation>

    <Operation Name="Alter">
      <Item Value="[dbo].[usp_ProcessOrder]" Type="SqlProcedure"/>
    </Operation>

    <!-- Index Operations -->
    <Operation Name="Create">
      <Item Value="[dbo].[Customer].[IX_Customer_Email]" Type="SqlIndex"/>
    </Operation>

    <Operation Name="Drop">
      <Item Value="[dbo].[Order].[IX_Order_Old]" Type="SqlIndex"/>
    </Operation>
  </Operations>
</DeploymentReport>
```

## Analyzing Reports

### 1. Parse XML and Categorize Changes

**Group by Operation Type:**
- **Creates**: New objects being added
- **Alters**: Existing objects being modified
- **Drops**: Objects being removed

**Group by Object Type:**
- Tables
- Views
- Stored Procedures
- Functions
- Indexes
- Triggers
- Constraints
- Users/Logins
- Permissions

### 2. Identify Data Loss Risks

**Look for:**
- `<Alert Name="DataLoss">`
- Operations with `DataLoss="True"` attribute
- Column drops
- Table drops with data
- Data type changes (narrowing)

**Example Data Loss Scenarios:**
```xml
<!-- Dropping column -->
<Operation Name="Alter" DataLoss="True">
  <Item Value="[dbo].[Customer]" Type="SqlTable"/>
  <!-- Dropping column Email -->
</Operation>

<!-- Changing data type -->
<Operation Name="Alter" DataLoss="True">
  <Item Value="[dbo].[Order].[Total]" Type="SqlColumn"/>
  <!-- DECIMAL(10,2) to DECIMAL(8,2) -->
</Operation>

<!-- Dropping table with data -->
<Operation Name="Drop" DataLoss="True">
  <Item Value="[dbo].[OldOrders]" Type="SqlTable"/>
</Operation>
```

### 3. Present Summary to User

**Format:**
```
Deployment Report: MyDB v2.0 → ProductionDB
═══════════════════════════════════════════

SUMMARY:
--------
Total Operations: 47
├─ Creates: 15
├─ Alters: 22
└─ Drops: 10

CHANGES BY OBJECT TYPE:
-----------------------
Tables:
  • 3 created: NewCustomer, NewOrder, NewProduct
  • 5 altered: Customer, Order, Product, Invoice, Payment
  • 2 dropped: LegacyCustomer, OldOrders

Stored Procedures:
  • 8 created: usp_GetCustomer, usp_ProcessOrder, ...
  • 12 altered: usp_UpdateCustomer, usp_DeleteOrder, ...
  • 3 dropped: usp_LegacyProc, ...

Views:
  • 2 created: vw_CustomerSummary, vw_OrderDetails
  • 3 altered: vw_SalesReport, ...
  • 1 dropped: vw_OldReport

Indexes:
  • 2 created: IX_Customer_Email, IX_Order_Date
  • 4 dropped: IX_Old_Index1, ...

⚠️  DATA LOSS WARNINGS (5):
────────────────────────────
1. CRITICAL: Dropping table [dbo].[OldOrders] (may contain data)
2. CRITICAL: Dropping column [dbo].[Customer].[LegacyId]
3. WARNING: Changing [dbo].[Order].[Total] from DECIMAL(10,2) to DECIMAL(8,2)
4. WARNING: Dropping column [dbo].[Product].[OldPrice]
5. INFO: Dropping unused index [dbo].[Customer].[IX_OldIndex]

RECOMMENDATIONS:
────────────────
✓ Backup database before deployment
✓ Verify data in [dbo].[OldOrders] can be archived/deleted
✓ Migrate [dbo].[Customer].[LegacyId] data if needed
✓ Test in non-production environment first
✓ Consider deploying during maintenance window

Proceed with deployment? (yes/no)
```

## Advanced Report Analysis

### Compare Multiple Environments

```bash
# Generate reports for each environment
sqlpackage /Action:DeployReport \
  /SourceFile:"MyDB.dacpac" \
  /TargetServerName:"dev-server" \
  /TargetDatabaseName:"DevDB" \
  /OutputPath:"dev-report.xml"

sqlpackage /Action:DeployReport \
  /SourceFile:"MyDB.dacpac" \
  /TargetServerName:"qa-server" \
  /TargetDatabaseName:"QaDB" \
  /OutputPath:"qa-report.xml"

sqlpackage /Action:DeployReport \
  /SourceFile:"MyDB.dacpac" \
  /TargetServerName:"prod-server" \
  /TargetDatabaseName:"ProdDB" \
  /OutputPath:"prod-report.xml"

# Compare reports to ensure consistency
```

### Diff Two Versions

```bash
# See what changed from v1.0 to v2.0
sqlpackage /Action:DeployReport \
  /SourceFile:"MyDB_v2.0.dacpac" \
  /TargetFile:"MyDB_v1.0.dacpac" \
  /OutputPath:"v1-to-v2-changelog.xml"

# This becomes your release notes
```

### Automated Drift Detection

```bash
#!/bin/bash
# drift-monitor.sh - Run daily to detect production drift

EXPECTED="expected-prod-schema.dacpac"
SERVER="prod-server"
DATABASE="ProductionDB"
REPORT="drift-report-$(date +%Y%m%d).xml"

sqlpackage /Action:DriftReport \
  /SourceFile:"$EXPECTED" \
  /TargetServerName:"$SERVER" \
  /TargetDatabaseName:"$DATABASE" \
  /OutputPath:"$REPORT"

# Parse report and alert if drift detected
if grep -q "<Operation" "$REPORT"; then
  echo "ALERT: Schema drift detected in $DATABASE!"
  # Send alert to monitoring system
fi
```

## Report Options

**All deployment properties apply to DeployReport:**

```bash
# Generate report with specific ignore options
sqlpackage /Action:DeployReport \
  /SourceFile:"MyDB.dacpac" \
  /TargetServerName:"prod-server" \
  /TargetDatabaseName:"ProdDB" \
  /OutputPath:"report.xml" \
  /p:IgnoreWhitespace=True \
  /p:IgnoreComments=True \
  /p:IgnoreExtendedProperties=True \
  /p:DropObjectsNotInSource=False \
  /p:BlockOnPossibleDataLoss=True
```

**These options affect what appears in the report:**
- Ignore options reduce noise
- DropObjectsNotInSource affects whether drops are included
- BlockOnPossibleDataLoss doesn't block report generation, but highlights risks

## Workflow Integration

### Pre-Deployment Checklist

1. **Generate Report**
```bash
sqlpackage /Action:DeployReport \
  /SourceFile:"MyDB.dacpac" \
  /TargetServerName:"prod" \
  /TargetDatabaseName:"ProdDB" \
  /OutputPath:"deploy-report.xml"
```

2. **Parse and Present**
   - Count operations by type
   - Identify data loss risks
   - Estimate deployment impact
   - Calculate estimated time

3. **Get Approval**
   - Present summary to stakeholders
   - Highlight risks and mitigations
   - Get explicit approval for production

4. **Generate Script** (optional)
```bash
sqlpackage /Action:Script \
  /SourceFile:"MyDB.dacpac" \
  /TargetServerName:"prod" \
  /TargetDatabaseName:"ProdDB" \
  /OutputPath:"deploy-script.sql"
```

5. **Execute Deployment**
```bash
sqlpackage /Action:Publish \
  /SourceFile:"MyDB.dacpac" \
  /TargetServerName:"prod" \
  /TargetDatabaseName:"ProdDB"
```

### CI/CD Integration

**GitHub Actions:**
```yaml
- name: Generate Deployment Report
  run: |
    sqlpackage /Action:DeployReport \
      /SourceFile:"bin/Release/MyDB.dacpac" \
      /TargetServerName:"${{ secrets.SQL_SERVER }}" \
      /TargetDatabaseName:"${{ secrets.SQL_DATABASE }}" \
      /TargetUser:"${{ secrets.SQL_USER }}" \
      /TargetPassword:"${{ secrets.SQL_PASSWORD }}" \
      /OutputPath:"deploy-report.xml"

- name: Upload Report
  uses: actions/upload-artifact@v3
  with:
    name: deployment-report
    path: deploy-report.xml

- name: Check for Data Loss
  run: |
    if grep -q 'DataLoss="True"' deploy-report.xml; then
      echo "::warning::Deployment includes data loss operations"
      exit 1  # Fail pipeline to require manual approval
    fi
```

**Azure DevOps:**
```yaml
- task: Bash@3
  displayName: 'Generate Deployment Report'
  inputs:
    targetType: 'inline'
    script: |
      sqlpackage /Action:DeployReport \
        /SourceFile:"$(Build.ArtifactStagingDirectory)/MyDB.dacpac" \
        /TargetServerName:"$(SqlServer)" \
        /TargetDatabaseName:"$(SqlDatabase)" \
        /OutputPath:"deploy-report.xml"

- task: PublishBuildArtifacts@1
  inputs:
    PathtoPublish: 'deploy-report.xml'
    ArtifactName: 'deployment-reports'
```

## Report Storage and Auditing

**Best Practices:**
1. **Version Control**: Store reports with DACPAC version
2. **Naming Convention**: `<database>_<version>_<environment>_<date>.xml`
3. **Archive**: Keep deployment reports for audit trail
4. **Compare**: Track changes between versions

**Example:**
```bash
# Generate and archive
sqlpackage /Action:DeployReport \
  /SourceFile:"MyDB_v2.1.0.dacpac" \
  /TargetServerName:"prod" \
  /TargetDatabaseName:"ProdDB" \
  /OutputPath:"reports/MyDB_v2.1.0_prod_20250123.xml"

# Commit to git for history
git add reports/
git commit -m "Deployment report for v2.1.0 to production"
```

## Interpreting Specific Operations

### Table Rebuilds

```xml
<Operation Name="TableRebuild">
  <Item Value="[dbo].[LargeTable]" Type="SqlTable"/>
</Operation>
```

**Impact**: Expensive operation, locks table, long duration

### Index Rebuilds

```xml
<Operation Name="Alter">
  <Item Value="[dbo].[Customer].[IX_Email]" Type="SqlIndex"/>
</Operation>
```

**Impact**: Can be done online or offline depending on SQL Server edition

### Constraint Changes

```xml
<Operation Name="Create">
  <Item Value="[dbo].[FK_Order_Customer]" Type="SqlForeignKey"/>
</Operation>
```

**Impact**: Can fail if referential integrity violated

## Troubleshooting

**Empty Report**: No differences detected
```bash
# Verify you're comparing correct versions
# Check comparison options aren't ignoring everything
```

**Report Generation Fails**: Connection issues
```bash
# Verify server/database name
# Check credentials
# Ensure firewall allows connection
```

**Unexpected Changes**: Comparison options
```bash
# Review /p:Ignore* options
# May be ignoring real differences
```

## Best Practices

1. **Always generate reports before production deployments**
2. **Review reports with stakeholders** before approval
3. **Archive reports** for compliance and audit
4. **Automate drift detection** in production
5. **Compare reports across environments** to ensure consistency
6. **Use reports for release notes** - document what changed
7. **Set up alerts** for data loss operations in CI/CD
8. **Test in non-production** with same report options
9. **Document approval process** for risky changes
10. **Keep historical reports** for troubleshooting

## Next Steps

After reviewing deployment report:
- If clean, proceed with `/ssdt-master:publish`
- If data loss detected, plan mitigation strategy
- If unexpected changes, investigate schema drift
- If blocked, generate script for manual review
- Archive report for compliance

IMPORTANT: Deployment reports are your safety net. Never deploy to production without reviewing the report first.
