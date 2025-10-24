---
description: Create new SQL Server database projects (SDK-style or legacy) with proper structure and configuration
---

You are an expert in creating new SQL Server database projects using SSDT tools.

## Your Task

Create a new SQL Server database project with proper structure, configuration, and best practices for either SDK-style (recommended) or legacy format.

## Project Type Selection

**Prompt user to choose**:
1. **SDK-style** (Microsoft.Build.Sql) - Recommended
   - Cross-platform (Windows, Linux, macOS)
   - Modern .NET tooling
   - Future-proof
   - Smaller project files

2. **Legacy** (.sqlproj)
   - Windows only
   - Visual Studio 2022 with SSDT
   - Supports SQLCLR
   - Mature, stable

## SDK-Style Project Creation

### Method 1: Using .NET CLI Template (Recommended)

**Check for SQL template**:
```bash
dotnet new list | grep -i sql
```

**If template available**:
```bash
dotnet new sqlproj -n <ProjectName> -o <OutputPath>
```

### Method 2: Manual Creation

**Create project structure**:
```bash
mkdir <ProjectName>
cd <ProjectName>
mkdir -p dbo/Tables dbo/Views dbo/StoredProcedures dbo/Functions
```

**Create .sqlproj file**:
```xml
<Project Sdk="Microsoft.Build.Sql/0.2.3">
  <PropertyGroup>
    <Name>ProjectName</Name>
    <DSP>Microsoft.Data.Tools.Schema.Sql.Sql160DatabaseSchemaProvider</DSP>
    <ModelCollation>1033,CI</ModelCollation>
    <TargetDatabaseSet>True</TargetDatabaseSet>
    <DefaultCollation>SQL_Latin1_General_CP1_CI_AS</DefaultCollation>
    <DefaultSchema>dbo</DefaultSchema>
    <QueryStoreCaptureMode>Auto</QueryStoreCaptureMode>
    <QueryStoreDesiredState>Off</QueryStoreDesiredState>
    <OutputPath>bin\</OutputPath>
  </PropertyGroup>

  <!-- Optional: SDK version can be in project element or here -->
  <!-- <ItemGroup>
    <PackageReference Include="Microsoft.Build.Sql" Version="0.2.3" />
  </ItemGroup> -->
</Project>
```

**Check latest SDK version**: https://www.nuget.org/packages/Microsoft.Build.Sql

### Project Structure

```
ProjectName/
├── ProjectName.sqlproj              # Project file
├── dbo/
│   ├── Tables/
│   │   └── .gitkeep                # Keep empty dirs in git
│   ├── Views/
│   ├── StoredProcedures/
│   ├── Functions/
│   ├── Schemas/
│   └── Security/
├── Scripts/
│   ├── Script.PreDeployment.sql    # Runs before deployment
│   └── Script.PostDeployment.sql   # Runs after deployment
├── Data/
│   └── ReferenceData.sql           # Static/seed data
└── README.md                        # Project documentation
```

## Legacy Project Creation

### Using Visual Studio

1. Open Visual Studio 2022
2. File → New → Project
3. Search: "SQL Server Database Project"
4. Configure:
   - Name: ProjectName
   - Location: OutputPath
   - Target Platform: SQL Server 2022 (or desired version)
5. Click Create

### Manual Legacy Project

**Create .sqlproj file**:
```xml
<?xml version="1.0" encoding="utf-8"?>
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003" ToolsVersion="4.0">
  <PropertyGroup>
    <Configuration Condition=" '$(Configuration)' == '' ">Debug</Configuration>
    <Platform Condition=" '$(Platform)' == '' ">AnyCPU</Platform>
    <Name>ProjectName</Name>
    <SchemaVersion>2.0</SchemaVersion>
    <ProjectVersion>4.1</ProjectVersion>
    <ProjectGuid>{GENERATE-NEW-GUID}</ProjectGuid>
    <DSP>Microsoft.Data.Tools.Schema.Sql.Sql160DatabaseSchemaProvider</DSP>
    <OutputType>Database</OutputType>
    <RootPath>
    </RootPath>
    <RootNamespace>ProjectName</RootNamespace>
    <AssemblyName>ProjectName</AssemblyName>
    <ModelCollation>1033,CI</ModelCollation>
    <DefaultFileStructure>BySchemaAndSchemaType</DefaultFileStructure>
    <DeployToDatabase>True</DeployToDatabase>
    <TargetFrameworkVersion>v4.7.2</TargetFrameworkVersion>
    <TargetLanguage>CS</TargetLanguage>
    <AppDesignerFolder>Properties</AppDesignerFolder>
    <SqlServerVerification>False</SqlServerVerification>
    <IncludeCompositeObjects>True</IncludeCompositeObjects>
    <TargetDatabaseSet>True</TargetDatabaseSet>
  </PropertyGroup>

  <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Release|AnyCPU' ">
    <OutputPath>bin\Release\</OutputPath>
    <BuildScriptName>$(MSBuildProjectName).sql</BuildScriptName>
    <TreatWarningsAsErrors>False</TreatWarningsAsErrors>
    <DebugType>pdbonly</DebugType>
    <Optimize>true</Optimize>
    <DefineDebug>false</DefineDebug>
    <DefineTrace>true</DefineTrace>
    <ErrorReport>prompt</ErrorReport>
    <WarningLevel>4</WarningLevel>
  </PropertyGroup>

  <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug|AnyCPU' ">
    <OutputPath>bin\Debug\</OutputPath>
    <BuildScriptName>$(MSBuildProjectName).sql</BuildScriptName>
    <TreatWarningsAsErrors>false</TreatWarningsAsErrors>
    <DebugSymbols>true</DebugSymbols>
    <DebugType>full</DebugType>
    <Optimize>false</Optimize>
    <DefineDebug>true</DefineDebug>
    <DefineTrace>true</DefineTrace>
    <ErrorReport>prompt</ErrorReport>
    <WarningLevel>4</WarningLevel>
  </PropertyGroup>

  <PropertyGroup>
    <VisualStudioVersion Condition="'$(VisualStudioVersion)' == ''">11.0</VisualStudioVersion>
    <SSDTExists Condition="Exists('$(MSBuildExtensionsPath)\Microsoft\VisualStudio\v$(VisualStudioVersion)\SSDT\Microsoft.Data.Tools.Schema.SqlTasks.targets')">True</SSDTExists>
    <VisualStudioVersion Condition="'$(SSDTExists)' == ''">11.0</VisualStudioVersion>
  </PropertyGroup>

  <Import Condition="'$(SQLDBExtensionsRefPath)' != ''" Project="$(SQLDBExtensionsRefPath)\Microsoft.Data.Tools.Schema.SqlTasks.targets" />
  <Import Condition="'$(SQLDBExtensionsRefPath)' == ''" Project="$(MSBuildExtensionsPath)\Microsoft\VisualStudio\v$(VisualStudioVersion)\SSDT\Microsoft.Data.Tools.Schema.SqlTasks.targets" />

  <ItemGroup>
    <Folder Include="Properties" />
    <Folder Include="dbo\" />
    <Folder Include="dbo\Tables\" />
    <Folder Include="dbo\Views\" />
    <Folder Include="dbo\StoredProcedures\" />
    <Folder Include="dbo\Functions\" />
    <Folder Include="Scripts\" />
    <Folder Include="Scripts\Pre-Deployment\" />
    <Folder Include="Scripts\Post-Deployment\" />
  </ItemGroup>

  <ItemGroup>
    <None Include="Scripts\Script.PreDeployment.sql" />
    <PostDeploy Include="Scripts\Script.PostDeployment.sql" />
  </ItemGroup>
</Project>
```

**Note**: Replace {GENERATE-NEW-GUID} with actual GUID:
```bash
# PowerShell
[guid]::NewGuid()

# Linux/macOS
uuidgen
```

## Essential Files

### 1. Pre-Deployment Script

**Scripts/Script.PreDeployment.sql**:
```sql
/*
 Pre-Deployment Script
 This script runs BEFORE the deployment plan is executed.
 Use for data transformations, temporary tables, or prep work.
 NOTE: Deployment plan is calculated BEFORE this runs!
*/

-- Example: Store data before column drop
-- SELECT * INTO #TempTable FROM dbo.TableToModify;

PRINT 'Pre-deployment script executed';
GO
```

### 2. Post-Deployment Script

**Scripts/Script.PostDeployment.sql**:
```sql
/*
 Post-Deployment Script
 This script runs AFTER the deployment plan is executed.
 Use for reference data, permissions, or post-deployment validation.
*/

-- Reference data population
:r .\Data\ReferenceData.sql

PRINT 'Post-deployment script executed';
GO
```

### 3. Reference Data Script

**Data/ReferenceData.sql**:
```sql
/*
 Reference/Seed Data
 Static data that should always exist in the database
*/

-- Example: Insert lookup table data
MERGE INTO dbo.Status AS target
USING (VALUES
    (1, 'Active'),
    (2, 'Inactive'),
    (3, 'Pending')
) AS source (StatusId, StatusName)
ON target.StatusId = source.StatusId
WHEN NOT MATCHED THEN
    INSERT (StatusId, StatusName)
    VALUES (source.StatusId, source.StatusName)
WHEN MATCHED AND target.StatusName <> source.StatusName THEN
    UPDATE SET StatusName = source.StatusName;
GO
```

## Configuration Files

### 1. Publish Profile

**ProjectName.publish.xml**:
```xml
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="Current" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <IncludeCompositeObjects>True</IncludeCompositeObjects>
    <TargetDatabaseName>DatabaseName</TargetDatabaseName>
    <DeployScriptFileName>ProjectName.sql</DeployScriptFileName>
    <TargetConnectionString>Data Source=(localdb)\MSSQLLocalDB;Integrated Security=True;Persist Security Info=False;Pooling=False;MultipleActiveResultSets=False;Connect Timeout=60;Encrypt=False;TrustServerCertificate=False</TargetConnectionString>
    <ProfileVersionNumber>1</ProfileVersionNumber>
    <BlockOnPossibleDataLoss>True</BlockOnPossibleDataLoss>
    <BackupDatabaseBeforeChanges>False</BackupDatabaseBeforeChanges>
    <CreateNewDatabase>False</CreateNewDatabase>
    <ScriptDatabaseOptions>False</ScriptDatabaseOptions>
    <AllowIncompatiblePlatform>False</AllowIncompatiblePlatform>
    <GenerateSmartDefaults>True</GenerateSmartDefaults>
  </PropertyGroup>
</Project>
```

### 2. .gitignore

**Add to project .gitignore**:
```gitignore
# Build outputs
bin/
obj/
*.dacpac
*.dll
*.pdb

# User-specific files
*.user
*.suo
*.userosscache
*.sln.docstates

# Publish profiles with credentials
*.publish.xml

# Visual Studio cache
.vs/
```

### 3. README.md

**Project README**:
```markdown
# ProjectName Database Project

SQL Server database project for [ProjectName].

## Requirements

- .NET 8.0+ SDK (for SDK-style projects)
- SQL Server 2022 or Azure SQL Database
- SqlPackage for deployments

## Building

\`\`\`bash
dotnet build ProjectName.sqlproj
\`\`\`

## Publishing

\`\`\`bash
sqlpackage /Action:Publish \\
  /SourceFile:"bin/Debug/ProjectName.dacpac" \\
  /TargetServerName:"localhost" \\
  /TargetDatabaseName:"DatabaseName"
\`\`\`

## Project Structure

- `dbo/Tables/` - Table definitions
- `dbo/StoredProcedures/` - Stored procedures
- `dbo/Views/` - View definitions
- `dbo/Functions/` - User-defined functions
- `Scripts/` - Pre/Post deployment scripts
- `Data/` - Reference/seed data scripts
```

## Example Schema Objects

### Sample Table

**dbo/Tables/Customer.sql**:
```sql
CREATE TABLE [dbo].[Customer]
(
    [CustomerId] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    [FirstName] NVARCHAR(100) NOT NULL,
    [LastName] NVARCHAR(100) NOT NULL,
    [Email] NVARCHAR(255) NOT NULL,
    [CreatedDate] DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
    [ModifiedDate] DATETIME2 NULL,
    CONSTRAINT [UK_Customer_Email] UNIQUE ([Email])
);
GO
```

### Sample View

**dbo/Views/vw_CustomerSummary.sql**:
```sql
CREATE VIEW [dbo].[vw_CustomerSummary]
AS
SELECT
    c.CustomerId,
    c.FirstName + ' ' + c.LastName AS FullName,
    c.Email,
    c.CreatedDate
FROM dbo.Customer c;
GO
```

### Sample Stored Procedure

**dbo/StoredProcedures/usp_GetCustomer.sql**:
```sql
CREATE PROCEDURE [dbo].[usp_GetCustomer]
    @CustomerId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        CustomerId,
        FirstName,
        LastName,
        Email,
        CreatedDate,
        ModifiedDate
    FROM dbo.Customer
    WHERE CustomerId = @CustomerId;
END;
GO
```

## Post-Creation Steps

1. **Build the project**:
```bash
# SDK-style
dotnet build <ProjectName>.sqlproj

# Legacy
msbuild <ProjectName>.sqlproj
```

2. **Initialize Git repository** (if applicable):
```bash
git init
git add .
git commit -m "Initial database project structure"
```

3. **Create initial publish profile** for local development

4. **Document**:
   - Database purpose
   - Connection requirements
   - Deployment process
   - Team conventions

## Best Practices

1. **Use SDK-style for new projects** unless you need SQLCLR
2. **Organize by schema and type** (Tables, Views, etc.)
3. **Use post-deployment scripts** for reference data
4. **Version your database** alongside application code
5. **Create publish profiles** for each environment
6. **Don't commit credentials** - use SQLCMD variables
7. **Enable source control** from day one
8. **Document conventions** in README

## Next Steps

After project creation:
- Add schema objects with proper organization
- Create publish profiles for environments
- Set up CI/CD pipeline
- Build with: `/ssdt-master:build`
- Deploy with: `/ssdt-master:publish`

IMPORTANT: SDK-style projects are recommended for all new development. They provide cross-platform support and modern tooling integration.
