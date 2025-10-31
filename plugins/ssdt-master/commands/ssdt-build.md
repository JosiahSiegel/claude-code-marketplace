---
description: Build SQL Server database projects (SDK-style or legacy) with .NET 8 and Microsoft.Build.Sql 2.0.0 GA
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

You are an expert in building SQL Server database projects using SSDT tools.

## Your Task

Build SQL Server database project (.sqlproj) following Microsoft 2025 best practices for SDK-style (Microsoft.Build.Sql 2.0.0 GA) and legacy formats.

**Prerequisites:**
- SDK-style: .NET 8.0 SDK, Microsoft.Build.Sql 2.0.0
- Legacy: MSBuild (Windows only)

## Project Type Detection

First, analyze the project file:
- **SDK-style (GA)**: `<Project Sdk="Microsoft.Build.Sql">` or `<Project Sdk="Microsoft.Build.Sql/2.0.0">`
- **Legacy**: Contains `<Import Project="$(MSBuildExtensionsPath)\Microsoft\VisualStudio\...SSDT..."`

**Note:** .sqlprojx extension was preview-only (VS 17.12 preview 2), now use .sqlproj for SDK-style.

## Build Methods

### Method 1: .NET CLI (SDK-Style Projects - Cross-Platform)

**Recommended for**: SDK-style projects, cross-platform builds, CI/CD

```bash
dotnet build <project-path> [options]
```

**Common Options:**
- `-c Release` or `/p:Configuration=Release` - Build in Release mode
- `/p:OutputPath=<path>` - Specify output directory
- `/p:SqlTargetName=<name>` - Set DACPAC name
- `--verbosity detailed` - Show detailed output
- `/p:NetCoreBuild=true` - Force .NET Core build
- `/p:RunSqlCodeAnalysis=true` - Enable static code analysis
- `/p:DacVersion=1.0.0` - Set DACPAC version
- `/p:DacApplicationName=<name>` - Set application name
- `/p:DacApplicationDescription=<desc>` - Set description
- `--no-restore` - Skip restore, use for faster builds
- `--no-incremental` - Force full rebuild

**Examples:**
```bash
# Standard build
dotnet build MyDatabase.sqlproj

# Release build with version
dotnet build MyDatabase.sqlproj -c Release /p:DacVersion=1.2.0

# Build with code analysis
dotnet build MyDatabase.sqlproj /p:RunSqlCodeAnalysis=true

# Build to specific output directory
dotnet build MyDatabase.sqlproj /p:OutputPath=./artifacts/
```

### Method 2: MSBuild (Legacy and SDK-Style - Windows)

**Recommended for**: Legacy projects, Windows-only environments, Visual Studio integration

```bash
msbuild <project-path> [options]
```

**Common Options:**
- `/t:Build` - Build target (default)
- `/t:Rebuild` - Clean and rebuild
- `/t:Clean` - Remove build outputs
- `/p:Configuration=Release` - Build configuration
- `/p:Platform=AnyCPU` - Target platform
- `/p:OutputPath=<path>` - Output directory
- `/verbosity:detailed` - Show detailed output
- `/m` - Multi-processor build (parallel)
- `/nr:false` - Don't use node reuse (clean build)
- `/p:RunSqlCodeAnalysis=true` - Enable code analysis
- `/p:SqlCodeAnalysisRules=<rules>` - Specify analysis rules

**MSBuild Locations:**
```bash
# Visual Studio 2022
"C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
"C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe"
"C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"

# Visual Studio 2019
"C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe"

# Build Tools (standalone)
"C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\MSBuild.exe"

# Add to PATH or use full path
```

**Examples:**
```bash
# Standard build
msbuild MyDatabase.sqlproj

# Rebuild in Release mode
msbuild MyDatabase.sqlproj /t:Rebuild /p:Configuration=Release

# Multi-processor build
msbuild MyDatabase.sqlproj /m /p:Configuration=Release

# Build with detailed logging
msbuild MyDatabase.sqlproj /verbosity:detailed /flp:logfile=build.log

# Clean build output
msbuild MyDatabase.sqlproj /t:Clean
```

### Method 3: Visual Studio (GUI)

**Recommended for**: Interactive development, debugging, refactoring

**Visual Studio 2022 (17.12+) - SDK-Style Support:**
1. File → Open → Project/Solution
2. Select .sqlproj file
3. Right-click project → Build
4. Or: Build → Build Solution (Ctrl+Shift+B)
5. View build output in Output window

**Visual Studio 2019/2022 - Legacy Projects:**
1. File → Open → Project/Solution
2. Select .sqlproj file
3. Right-click project → Build
4. Or: Build → Build Solution (Ctrl+Shift+B)

**Build Configuration:**
- Build → Configuration Manager
- Select Debug or Release
- Set platform to AnyCPU

**Advanced Options:**
- Project Properties → Build
  - Target platform (SQL Server version)
  - Treat warnings as errors
  - Suppress warnings
  - Output path
- Project Properties → Code Analysis
  - Enable/disable rules
  - Set rule severity

### Method 4: VS Code (SQL Database Projects Extension)

**Recommended for**: Cross-platform development, lightweight editor

**Prerequisites:**
```bash
# Install SQL Database Projects extension
code --install-extension ms-mssql.sql-database-projects-vscode
```

**Build Methods:**

**A. Command Palette:**
1. Open project folder in VS Code
2. Ctrl+Shift+P → "Database Projects: Build"
3. Select project if multiple exist
4. View output in Terminal

**B. Context Menu:**
1. Right-click .sqlproj in Explorer
2. Select "Build Database Project"
3. View output in Terminal

**C. Terminal:**
```bash
# SDK-style projects
dotnet build MyDatabase.sqlproj

# Or use VS Code tasks
```

**Configure Tasks (tasks.json):**
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Build Database",
      "type": "shell",
      "command": "dotnet",
      "args": ["build", "${workspaceFolder}/MyDatabase.sqlproj"],
      "group": {
        "kind": "build",
        "isDefault": true
      },
      "presentation": {
        "reveal": "always",
        "panel": "new"
      }
    }
  ]
}
```

**Build with Task:**
- Terminal → Run Build Task (Ctrl+Shift+B)

### Method 5: Azure Data Studio (SQL Database Projects Extension)

**Recommended for**: Database admins, Azure SQL development

**Prerequisites:**
```bash
# Install from Extensions marketplace
# Search: "SQL Database Projects"
```

**Build Methods:**

**A. Projects View:**
1. Open Projects view (Ctrl+Shift+P → "Projects: Focus on Projects View")
2. Right-click project → Build
3. View output in Output panel

**B. Command Palette:**
1. Ctrl+Shift+P → "Database Projects: Build"
2. Select project
3. View results

**C. Integrated Terminal:**
```bash
dotnet build MyDatabase.sqlproj
```

### Method 6: Docker Containers (Cross-Platform)

**Recommended for**: SDK-style projects, CI/CD

```dockerfile
# Dockerfile - SDK-style (Linux/Windows compatible)
FROM mcr.microsoft.com/dotnet/sdk:8.0

WORKDIR /build
COPY . .
RUN dotnet build MyDatabase.sqlproj -c Release
```

**One-liner build:**
```bash
docker run --rm -v $(pwd):/build -w /build mcr.microsoft.com/dotnet/sdk:8.0 \
  dotnet build MyDatabase.sqlproj -c Release
```

### Method 7: CI/CD Build Scripts

**GitHub Actions:**
```yaml
- name: Build Database Project
  run: dotnet build src/MyDatabase.sqlproj -c Release

- name: Upload DACPAC
  uses: actions/upload-artifact@v3
  with:
    name: dacpac
    path: src/bin/Release/*.dacpac
```

**Azure DevOps:**
```yaml
- task: DotNetCoreCLI@2
  displayName: 'Build Database Project'
  inputs:
    command: 'build'
    projects: '**/*.sqlproj'
    arguments: '-c Release'
```

**GitLab CI:**
```yaml
build:
  image: mcr.microsoft.com/dotnet/sdk:8.0
  script:
    - dotnet build MyDatabase.sqlproj -c Release
  artifacts:
    paths:
      - bin/Release/*.dacpac
```

## Build Process

1. **Locate Project File**
   - Search for .sqlproj or .sqlprojx files in the current directory
   - If multiple exist, ask user which one to build
   - Use Glob tool to find: `**/*.sqlproj` or `**/*.sqlprojx`

2. **Verify Prerequisites**
   - For SDK-style: Check `dotnet --version` (requires .NET 6.0+)
   - For legacy: Check MSBuild availability (Windows only)
   - Verify Microsoft.Build.Sql SDK installation for SDK-style projects

3. **Check Dependencies**
   - Examine project for database references (.dacpac references)
   - Ensure referenced dacpacs are available in specified paths
   - Check for SQLCMD variables in .sqlproj

4. **Execute Build**
   - Run appropriate build command based on project type
   - Capture and display build output
   - Report any errors, warnings, or suggestions

5. **Verify Output**
   - Confirm .dacpac file was created
   - Report file location and size
   - Show any build warnings that should be addressed

## Error Handling

Common build errors and solutions:

**Missing SDK**: "error MSB4236: The SDK 'Microsoft.Build.Sql' specified could not be found"
- Solution: Install Microsoft.Build.Sql from NuGet or update Visual Studio

**Reference Resolution**: "Error SQL71501: Cannot resolve the referenced object"
- Solution: Add database reference or verify connection string

**SQLCLR Issues**: SDK-style projects don't support SQLCLR
- Solution: Keep SQLCLR objects in legacy project or remove them

**Invalid Syntax**: T-SQL syntax errors in .sql files
- Solution: Review reported file and line number, fix syntax

## Best Practices

1. **Always verify build succeeded** before proceeding with deployment
2. **Use Release configuration** for production builds
3. **Enable static code analysis** with `/p:RunSqlCodeAnalysis=true`
4. **Version your dacpacs** using `/p:DacVersion=<version>`
5. **Check for warnings** - treat warnings as potential issues
6. **Validate cross-platform** compatibility for SDK-style projects
7. **Use consistent output paths** for CI/CD integration

## Output Information

After successful build, provide:
- Build status (Success/Failed)
- DACPAC location
- Build time
- Warnings count
- Next steps (e.g., "Ready to publish with /ssdt-master:publish")

## Platform Considerations

- **Windows**: Both SDK-style (.NET) and legacy (MSBuild) supported
- **Linux/macOS**: Only SDK-style projects supported via dotnet CLI
- **Containers**: SDK-style projects can be built in Docker using .NET SDK images

## Windows Shell Considerations (Git Bash/MINGW/MSYS2)

### Git Bash on Windows

Git Bash users on Windows may encounter path issues when building projects with paths containing spaces or when using tools that expect Windows-style paths.

**Recommended Approach**: Use PowerShell or CMD for SSDT workflows on Windows to avoid path conversion issues.

**If using Git Bash:**

```bash
# dotnet CLI handles paths correctly in Git Bash
dotnet build MyDatabase.sqlproj

# For paths with spaces, always quote
dotnet build "D:/Program Files/MyProject/Database.sqlproj"

# Detect Git Bash and provide guidance
if [ -n "$MSYSTEM" ]; then
  echo "Git Bash detected. Using dotnet CLI (recommended for cross-shell compatibility)"
fi
```

**Shell Detection in Build Scripts:**

```bash
#!/bin/bash
# Cross-platform build script with shell detection

# Detect shell environment
case "$OSTYPE" in
  msys*)
    echo "Git Bash/MSYS detected on Windows"
    SHELL_TYPE="git-bash"
    ;;
  linux-gnu*)
    echo "Linux detected"
    SHELL_TYPE="linux"
    ;;
  darwin*)
    echo "macOS detected"
    SHELL_TYPE="macos"
    ;;
esac

# Build with dotnet CLI (works on all platforms)
echo "Building database project..."
dotnet build Database.sqlproj -c Release

# Verify DACPAC
if [ -f "bin/Release/Database.dacpac" ]; then
  echo "Build successful: bin/Release/Database.dacpac"
else
  echo "Build failed: DACPAC not found"
  exit 1
fi
```

**Alternative: PowerShell (Recommended for Windows)**

```powershell
# PowerShell script - no path conversion issues
$projectPath = "D:\Program Files\MyProject\Database.sqlproj"
dotnet build $projectPath -c Release

if (Test-Path "bin\Release\Database.dacpac") {
    Write-Host "Build successful"
} else {
    Write-Error "Build failed"
}
```

### GitHub Actions Build Example (Windows)

```yaml
jobs:
  build:
    runs-on: windows-latest
    defaults:
      run:
        shell: pwsh  # Use PowerShell - recommended for Windows SSDT

    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '8.0.x'

      - name: Build Database Project
        run: dotnet build Database.sqlproj -c Release

      # Alternative: Use bash if needed (dotnet CLI works correctly)
      # defaults:
      #   run:
      #     shell: bash
```

IMPORTANT: Always research latest Microsoft.Build.Sql documentation if encountering issues with SDK-style projects, as this is an actively evolving technology.

**For comprehensive Git Bash path handling guidance**, see the `windows-git-bash-paths` skill documentation.
