---
description: Migrate legacy SQL Server database projects to SDK-style format following Microsoft best practices
---

You are an expert in migrating legacy SQL Server database projects (.sqlproj) to the modern SDK-style format using Microsoft.Build.Sql.

## Your Task

Convert a legacy SQL Server database project to SDK-style format, ensuring compatibility, cross-platform support, and modern tooling benefits.

## Why Migrate to SDK-Style?

**Benefits**:
- Cross-platform builds (Windows, Linux, macOS)
- .NET Core/5+ integration
- Smaller, cleaner project files
- Better CI/CD integration
- Azure Data Studio and VS Code support
- Future-proof (Microsoft's recommended path)
- Simplified MSBuild properties

**Limitations**:
- SQLCLR objects NOT supported (requires .NET Framework)
- Some Visual Studio features still in preview
- Side-by-side install with legacy SSDT not supported

## Pre-Migration Assessment

### 1. Identify Project Type

Locate .sqlproj file and verify it's legacy format:
```xml
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <Import Project="$(MSBuildExtensionsPath)\Microsoft\VisualStudio\v$(VisualStudioVersion)\SSDT\..."/>
```

### 2. Check for SQLCLR Objects

**Search for SQLCLR assemblies**:
```bash
# In project directory
grep -r "SqlClr" *.sqlproj
grep -r "Assembly" *.sql
```

**If SQLCLR found**:
- WARN user: "SQLCLR objects detected. SDK-style projects don't support SQLCLR."
- Options:
  1. Keep legacy project for SQLCLR
  2. Remove SQLCLR and migrate
  3. Use separate legacy project for SQLCLR only

### 3. Review Dependencies

Check for:
- Database references (.dacpac)
- SQLCMD variables
- Pre/Post deployment scripts
- Custom build targets

All should be compatible, but note any custom MSBuild targets that may need updating.

## Migration Process

### Step 1: Backup Original Project

**CRITICAL - Always backup first**:
```bash
cp <project-name>.sqlproj <project-name>.sqlproj.original
```

### Step 2: Modify Project File

Open .sqlproj in text editor and make these changes:

**A. Update Project Element**
```xml
<!-- OLD -->
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">

<!-- NEW -->
<Project DefaultTargets="Build" Sdk="Microsoft.Build.Sql">
```

Or use the Sdk attribute style:
```xml
<Project Sdk="Microsoft.Build.Sql">
```

**B. Remove Import Statements**

Delete ALL `<Import>` statements EXCEPT explicitly added ones:
```xml
<!-- REMOVE THESE -->
<Import Project="$(MSBuildExtensionsPath)\..."/>
<Import Project="$(SQLDBExtensionsRefPath)\..."/>
<!-- Keep custom imports you added intentionally -->
```

**C. Update Property Names**

Some properties have new names in SDK-style:

| Legacy Property | SDK-Style Property |
|----------------|-------------------|
| AnsiPadding | AnsiPaddingOn |
| AnsiWarnings | AnsiWarningsOn |
| AnsiNulls | AnsiNullsOn |
| QuotedIdentifier | QuotedIdentifierOn |
| ArithAbort | ArithAbortOn |
| NumericRoundAbort | NumericRoundAbortOn |

**Search and replace in .sqlproj**:
```bash
# Example: Fix property names
sed -i 's/<AnsiPadding>/<AnsiPaddingOn>/g' <project>.sqlproj
sed -i 's/<\/AnsiPadding>/<\/AnsiPaddingOn>/g' <project>.sqlproj
```

**D. Specify SDK Version**

Add explicit SDK version reference (recommended):
```xml
<Project Sdk="Microsoft.Build.Sql/0.2.3">
```

Check latest version at: https://www.nuget.org/packages/Microsoft.Build.Sql

### Step 3: Clean Up Project File

SDK-style projects use implicit includes, so you can remove explicit `<Build Include>` items:

**Legacy (verbose)**:
```xml
<Build Include="dbo\Tables\Customers.sql" />
<Build Include="dbo\Tables\Orders.sql" />
<!-- ...hundreds of files... -->
```

**SDK-Style (implicit)**:
```xml
<!-- No need to list all files! SDK automatically includes *.sql -->
```

**Keep explicit includes only for**:
- Files outside standard patterns
- Files you want to exclude: `<Build Remove="path\to\file.sql" />`

### Step 4: Update File Extension (Visual Studio 17.12 preview 2 only)

In Visual Studio 17.12 preview 2, SDK-style projects used .sqlprojx:
```bash
mv <project>.sqlproj <project>.sqlprojx
```

**NOTE**: In Visual Studio 17.12 preview 3+, use .sqlproj (no rename needed)

## Validation

### 1. Build the Migrated Project

**Using dotnet CLI**:
```bash
dotnet build <project>.sqlproj
```

**Expected output**:
```
Build succeeded.
    0 Warning(s)
    0 Error(s)
```

### 2. Compare DACPAC Output

Extract and compare before/after:
```bash
# Build legacy version
msbuild <project>.sqlproj.original /t:Build

# Build SDK-style version
dotnet build <project>.sqlproj

# Unpack both and compare
unzip legacy.dacpac -d legacy/
unzip sdk.dacpac -d sdk/
diff -r legacy/model.xml sdk/model.xml
```

Schemas should be identical (whitespace differences OK).

### 3. Test Deployment

Deploy to test database:
```bash
sqlpackage /Action:Publish \
  /SourceFile:"bin/Debug/<project>.dacpac" \
  /TargetServerName:"localhost" \
  /TargetDatabaseName:"<testdb>"
```

## Common Migration Issues

### Issue 1: Build Error - SDK Not Found

**Error**: `error MSB4236: The SDK 'Microsoft.Build.Sql' specified could not be found`

**Solutions**:
```bash
# Install globally
dotnet workload install microsoft-sql-sdk

# Or use NuGet package
dotnet add package Microsoft.Build.Sql
```

### Issue 2: Property Name Errors

**Error**: `Property 'AnsiPadding' not recognized`

**Solution**: Update property names per table above

### Issue 3: Custom Build Targets Fail

**Error**: Custom MSBuild targets not working

**Solution**: Review custom targets, may need to update paths or use new SDK properties

### Issue 4: Database References Not Found

**Error**: Referenced DACPAC not found

**Solution**: Update `<ArtifactReference>` to use new format:
```xml
<ArtifactReference Include="path\to\reference.dacpac">
  <SuppressMissingDependenciesErrors>False</SuppressMissingDependenciesErrors>
</ArtifactReference>
```

## Post-Migration

### 1. Update Build Scripts

Update CI/CD pipelines to use `dotnet build` instead of `msbuild`:

**Before**:
```bash
msbuild MyDatabase.sqlproj /p:Configuration=Release
```

**After**:
```bash
dotnet build MyDatabase.sqlproj -c Release
```

### 2. Update Documentation

Document the migration:
- SDK version used
- Any property changes made
- Build process changes
- Platform compatibility notes

### 3. Team Communication

Inform team members:
- New build requirements (.NET SDK)
- Visual Studio version requirements (17.12+ for full support)
- Azure Data Studio / VS Code support now available

### 4. Source Control

Commit changes:
```bash
git add <project>.sqlproj
git add <project>.sqlproj.original
git commit -m "Migrate to SDK-style SQL project

- Updated to Microsoft.Build.Sql SDK
- Removed explicit file includes
- Updated property names (AnsiPadding -> AnsiPaddingOn, etc.)
- Verified DACPAC output matches legacy version
- Updated build to use dotnet CLI"
```

## Rollback Plan

If migration fails or causes issues:

1. Restore original file:
```bash
cp <project>.sqlproj.original <project>.sqlproj
```

2. Rebuild with MSBuild:
```bash
msbuild <project>.sqlproj /t:Rebuild
```

3. Document blockers for later retry

## Cross-Platform Build Testing

After migration, test on all target platforms:

**Windows**:
```bash
dotnet build
```

**Linux**:
```bash
dotnet build
```

**macOS**:
```bash
dotnet build
```

**Docker**:
```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0
WORKDIR /build
COPY . .
RUN dotnet build MyDatabase.sqlproj
```

## Best Practices

1. **Migrate during low-activity period** - easier to troubleshoot
2. **Test thoroughly** - compare DACPACs, test deployments
3. **Keep backup** - retain .original file for a few releases
4. **Migrate one project at a time** - if you have multiple databases
5. **Update team tools** - ensure everyone has .NET SDK installed
6. **Document breaking changes** - note any custom build process changes
7. **Validate in CI/CD** - ensure build pipelines work before merging

## Microsoft Resources

Always check latest documentation:
- Microsoft.Build.Sql SDK: https://www.nuget.org/packages/Microsoft.Build.Sql
- Conversion Guide: https://learn.microsoft.com/sql/tools/sql-database-projects/howto/convert-original-sql-project
- GitHub Issues: https://github.com/microsoft/DacFx/issues

## Next Steps

After successful migration:
- Build with: `dotnet build <project>.sqlproj`
- Publish with: `/ssdt-master:publish`
- Use in Azure Data Studio or VS Code
- Set up cross-platform CI/CD

IMPORTANT: SDK-style projects are the future of SQL Server database development. While in preview, they're actively developed and recommended for new projects.
