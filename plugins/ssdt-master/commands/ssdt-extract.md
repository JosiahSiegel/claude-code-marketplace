---
description: Extract DACPAC or BACPAC files from SQL Server databases using SqlPackage
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

You are an expert in extracting SQL Server database schemas and data using SqlPackage.

## Your Task

Extract a database to a DACPAC (schema only) or BACPAC (schema + data) file from a SQL Server instance.

## Prerequisites

1. **Verify SqlPackage**
   - Check for `sqlpackage` in PATH
   - If not found, offer to install: `dotnet tool install -g Microsoft.SqlPackage`
   - Test with: `sqlpackage /version`

2. **Gather Connection Information**
   - Source server name
   - Source database name
   - Authentication method
   - Credentials if needed

## Extract Actions

### DACPAC (Schema Only)

**Use Case**: Capture database structure without data
- Source control of schema
- Schema comparison
- Deployment to other environments
- CI/CD pipelines

**Command**:
```bash
sqlpackage /Action:Extract \
  /SourceServerName:"<server>" \
  /SourceDatabaseName:"<database>" \
  /TargetFile:"<output-path>.dacpac" \
  [/SourceUser:"<username>"] \
  [/SourcePassword:"<password>"] \
  [options]
```

**Important Options**:
- `/p:ExtractAllTableData=False` - Schema only (default)
- `/p:VerifyExtraction=True` - Validate after extraction (can fail on broken references)
- `/p:ExtractReferencedServerScopedElements=True` - Include server-level objects
- `/p:ExtractApplicationScopedObjectsOnly=True` - Exclude server/database scoped objects
- `/p:IgnoreExtendedProperties=False` - Include extended properties
- `/p:Storage=File` - Store as file (default) vs Memory

### BACPAC (Schema + Data)

**Use Case**: Full database backup with data
- Database migration
- Cloud migration (on-premises to Azure SQL)
- Database archival
- Dev/Test database copies

**Command**:
```bash
sqlpackage /Action:Export \
  /SourceServerName:"<server>" \
  /SourceDatabaseName:"<database>" \
  /TargetFile:"<output-path>.bacpac" \
  [/SourceUser:"<username>"] \
  [/SourcePassword:"<password>"] \
  [options]
```

**Important Options**:
- `/p:VerifyFullTextDocumentTypesSupported=True` - Check full-text support
- `/p:Storage=Memory` - Faster for smaller databases
- `/p:CommandTimeout=0` - No timeout (for large databases)
- `/p:TableData=<schema.table>` - Export specific table data (can specify multiple)

## Extraction Best Practices

### 1. Pre-Extraction Validation

**Check Database Size**:
```sql
SELECT
    DB_NAME() AS DatabaseName,
    SUM(size * 8 / 1024) AS SizeMB
FROM sys.database_files;
```

For large databases (>10GB):
- Use `/p:Storage=Memory` for faster extraction
- Increase timeout: `/p:CommandTimeout=0`
- Consider extracting during off-peak hours

**Check for Broken References**:
```sql
SELECT
    OBJECT_NAME(referencing_id) AS ReferencingObject,
    referenced_entity_name AS MissingObject
FROM sys.sql_expression_dependencies
WHERE referenced_id IS NULL
  AND referenced_entity_name IS NOT NULL;
```

If broken references exist:
- DACPAC extraction may fail with `/p:VerifyExtraction=True`
- Solution: Use `/p:VerifyExtraction=False` to bypass validation
- Note: SSMS validates by default; SqlPackage.exe does NOT by default

### 2. Handling Extraction Errors

**Error: "Timeout expired"**
```bash
/p:CommandTimeout=0  # Disable timeout
```

**Error: "Verification failed"**
```bash
/p:VerifyExtraction=False  # Skip verification
```

**Error: "Login failed"**
- Verify credentials
- Check firewall rules (especially for Azure SQL)
- Ensure user has db_owner or appropriate permissions

**Error: "Full-Text not supported"**
```bash
/p:VerifyFullTextDocumentTypesSupported=False
```

### 3. Output File Management

**Naming Convention**:
```
<DatabaseName>_<Environment>_<Version>_<Date>.dacpac
Example: AdventureWorks_Prod_1.0.0_20250123.dacpac
```

**Output Path**:
- Absolute path recommended
- Ensure directory exists
- Check disk space availability
- For BACPAC: May be very large, plan accordingly

### 4. Selective Extraction

**Extract Specific Tables Only** (BACPAC):
```bash
/p:TableData=dbo.Customers \
/p:TableData=dbo.Orders \
/p:TableData=dbo.OrderDetails
```

**Exclude Server-Scoped Objects**:
```bash
/p:ExtractApplicationScopedObjectsOnly=True
```

**Ignore Permissions**:
```bash
/p:IgnorePermissions=True
```

## Advanced Scenarios

### Extract from Azure SQL Database

```bash
sqlpackage /Action:Extract \
  /SourceServerName:"<server>.database.windows.net" \
  /SourceDatabaseName:"<database>" \
  /SourceAuthentication:ActiveDirectoryPassword \
  /SourceUser:"<user@domain.com>" \
  /SourcePassword:"<password>" \
  /TargetFile:"output.dacpac"
```

**Azure-Specific Considerations**:
- Use `/SourceAuthentication:ActiveDirectoryInteractive` for MFA
- Enable firewall rule for your IP
- Use `/p:CommandTimeout=0` for large databases
- Consider using Azure Storage for large BACPAC files

### Extract with SQLCMD Variables

Capture SQLCMD variables used in project:
```bash
/p:IncludeSqlCmdVariableStatements=True
```

### Unpack DACPAC for Analysis

After extraction, you can inspect contents:
```bash
# Change extension to .zip
cp output.dacpac output.zip

# Extract contents
unzip output.zip -d dacpac-contents

# Review model.xml for schema details
cat dacpac-contents/model.xml
```

## Post-Extraction Tasks

1. **Validate DACPAC**
   - Check file size (should not be 0 bytes)
   - Verify file can be opened/unpacked
   - For BACPAC: Compare size with expected data volume

2. **Test Deployment**
   - Try publishing to test database
   - Use `/Action:Script` to preview changes
   - Verify all objects are present

3. **Document Extraction**
   - Record source database version
   - Note any extraction warnings
   - Document any `/p:VerifyExtraction=False` usage

4. **Store Securely**
   - BACPAC files contain data - treat as sensitive
   - Version control DACPAC files (schema)
   - Don't commit BACPAC to source control (too large, contains data)

## Comparison: DACPAC vs BACPAC

| Feature | DACPAC | BACPAC |
|---------|---------|---------|
| Contains Schema | ✓ | ✓ |
| Contains Data | ✗ | ✓ |
| File Size | Small (KB-MB) | Large (MB-GB) |
| Use for Deployment | ✓ | ✗ (use for migration) |
| Source Control | ✓ Recommended | ✗ Too large |
| Import Action | Publish | Import |
| Extract Action | Extract | Export |

## Platform Support

- **Windows**: SqlPackage.exe or .NET tool
- **Linux**: .NET global tool
- **macOS**: .NET global tool
- **Azure Cloud Shell**: Pre-installed
- **Docker**: Use mssql-tools image or install .NET tool

## Next Steps

After extraction, suggest:
- **DACPAC**: "Ready for deployment with /ssdt-master:publish or schema comparison with /ssdt-master:schema-compare"
- **BACPAC**: "Ready to import to another database with SqlPackage /Action:Import"

IMPORTANT: Always verify the extracted file is valid before relying on it for deployments or migrations.
