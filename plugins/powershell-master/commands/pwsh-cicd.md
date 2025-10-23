---
description: Integrate PowerShell scripts into CI/CD pipelines (GitHub Actions, Azure DevOps, Bitbucket)
---

# PowerShell CI/CD Integration

Implement PowerShell automation in continuous integration and deployment pipelines across different platforms.

## When to Use

- Setting up PowerShell in CI/CD pipelines
- Running tests in automated builds
- Deploying with PowerShell scripts
- Cross-platform pipeline setup
- Troubleshooting CI/CD PowerShell issues

## Instructions

### 1. GitHub Actions

**Basic PowerShell Step:**
```yaml
name: PowerShell CI

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Run PowerShell script
        shell: pwsh
        run: |
          Write-Host "Running on PowerShell $($PSVersionTable.PSVersion)"
          ./build.ps1

      - name: Install modules and test
        shell: pwsh
        run: |
          Install-Module -Name Pester -Force -Scope CurrentUser
          Invoke-Pester -Path ./tests -OutputFormat NUnitXml
```

**Cross-Platform Matrix:**
```yaml
jobs:
  test:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
    runs-on: ${{ matrix.os }}

    steps:
      - uses: actions/checkout@v4

      - name: Test on ${{ matrix.os }}
        shell: pwsh
        run: |
          Write-Host "Testing on $($PSVersionTable.OS)"
          ./test-script.ps1
```

**With Azure Login:**
```yaml
- name: Azure Login
  uses: azure/login@v1
  with:
    creds: ${{ secrets.AZURE_CREDENTIALS }}

- name: Run Azure PowerShell script
  shell: pwsh
  run: |
    Install-Module -Name Az -Force -Scope CurrentUser
    ./deploy-to-azure.ps1
```

### 2. Azure DevOps Pipelines

**Basic Pipeline:**
```yaml
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'

steps:
- task: PowerShell@2
  inputs:
    targetType: 'inline'
    script: |
      Write-Host "PowerShell version: $($PSVersionTable.PSVersion)"
      Install-Module -Name Pester -Force
      Invoke-Pester -Path ./tests
  displayName: 'Run Pester Tests'

- task: PowerShell@2
  inputs:
    filePath: '$(System.DefaultWorkingDirectory)/build.ps1'
    arguments: '-Configuration Release'
  displayName: 'Run Build Script'
```

**Multi-Platform:**
```yaml
strategy:
  matrix:
    linux:
      imageName: 'ubuntu-latest'
    windows:
      imageName: 'windows-latest'
    mac:
      imageName: 'macos-latest'

pool:
  vmImage: $(imageName)

steps:
- pwsh: |
    Write-Host "Running on $(imageName)"
    ./cross-platform-script.ps1
  displayName: 'Cross-platform PowerShell'
```

**Azure Deployment:**
```yaml
- task: AzurePowerShell@5
  inputs:
    azureSubscription: 'MyAzureConnection'
    ScriptType: 'FilePath'
    ScriptPath: '$(System.DefaultWorkingDirectory)/deploy.ps1'
    azurePowerShellVersion: 'LatestVersion'
```

### 3. Bitbucket Pipelines

**Basic Configuration:**
```yaml
image: mcr.microsoft.com/powershell:latest

pipelines:
  default:
    - step:
        name: Build and Test
        script:
          - pwsh -Command "Write-Host 'PowerShell $($PSVersionTable.PSVersion)'"
          - pwsh -Command "Install-Module -Name Pester -Force"
          - pwsh -Command "Invoke-Pester -Path ./tests"

  branches:
    main:
      - step:
          name: Deploy
          deployment: production
          script:
            - pwsh -File ./deploy.ps1 -Environment Production
```

**With Caching:**
```yaml
definitions:
  caches:
    pwsh-modules: ~/.local/share/powershell/Modules

pipelines:
  default:
    - step:
        caches:
          - pwsh-modules
        script:
          - pwsh -Command "Install-Module -Name Az -Force"
          - pwsh -File ./script.ps1
```

## Common CI/CD Patterns

### Pattern 1: Test → Build → Deploy

```yaml
# GitHub Actions example
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - shell: pwsh
        run: |
          Install-Module -Name Pester -Force -Scope CurrentUser
          $result = Invoke-Pester -Path ./tests -PassThru
          if ($result.FailedCount -gt 0) { exit 1 }

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - shell: pwsh
        run: ./build.ps1

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - shell: pwsh
        run: ./deploy.ps1 -Environment Production
```

### Pattern 2: Code Quality Checks

```powershell
# Install PSScriptAnalyzer
Install-Module -Name PSScriptAnalyzer -Force

# Run analysis
$results = Invoke-ScriptAnalyzer -Path . -Recurse -Settings PSGallery

# Fail build on errors
if ($results) {
    $results | Format-Table -AutoSize
    exit 1
}
```

### Pattern 3: Versioning & Tagging

```powershell
# Get version from module manifest
$manifest = Test-ModuleManifest -Path ./MyModule.psd1
$version = $manifest.Version

# Tag release
git tag -a "v$version" -m "Release $version"
git push origin "v$version"
```

## Environment Variables

**GitHub Actions:**
```yaml
env:
  AZURE_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
  ENVIRONMENT: production

- shell: pwsh
  run: |
    Write-Host "Deploying to $env:ENVIRONMENT"
```

**Azure DevOps:**
```yaml
variables:
  environment: 'production'

steps:
- pwsh: |
    Write-Host "Environment: $(environment)"
```

**Bitbucket:**
```yaml
pipelines:
  default:
    - step:
        script:
          - export ENVIRONMENT=production
          - pwsh -Command "Write-Host \"Env: $env:ENVIRONMENT\""
```

## Secrets Management

**GitHub Actions:**
```yaml
- shell: pwsh
  env:
    API_KEY: ${{ secrets.API_KEY }}
  run: |
    $secureKey = ConvertTo-SecureString $env:API_KEY -AsPlainText -Force
    # Use $secureKey
```

**Azure DevOps:**
```yaml
- task: AzureKeyVault@2
  inputs:
    azureSubscription: 'MyConnection'
    KeyVaultName: 'MyKeyVault'
    SecretsFilter: '*'

- pwsh: |
    Write-Host "Using secret from Key Vault"
    # Secrets available as environment variables
```

## Troubleshooting CI/CD

**Issue: Module not found**
```powershell
# Solution: Install in CurrentUser scope
Install-Module -Name ModuleName -Force -Scope CurrentUser

# Verify installation
Get-Module -Name ModuleName -ListAvailable
```

**Issue: Execution policy**
```powershell
# Solution: Use pwsh instead of powershell
# pwsh has Unrestricted policy by default on non-Windows
```

**Issue: Path differences**
```powershell
# Solution: Use cross-platform paths
$scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "script.ps1"

# Or use environment variables
$workspace = $env:GITHUB_WORKSPACE  # GitHub Actions
$workspace = $env:SYSTEM_DEFAULTWORKINGDIRECTORY  # Azure DevOps
```

**Issue: Line ending conflicts**
```powershell
# Solution: Configure git
git config core.autocrlf input  # Linux/macOS
git config core.autocrlf true   # Windows
```

## Best Practices

- ✅ Use `pwsh` for cross-platform scripts (not `powershell`)
- ✅ Install modules with `-Scope CurrentUser` (no admin needed)
- ✅ Add `-Force` to skip prompts in automation
- ✅ Use `-ErrorAction Stop` in scripts to fail fast
- ✅ Output test results in standard formats (NUnitXml, JUnit)
- ✅ Cache modules to speed up builds
- ✅ Pin PowerShell versions in production pipelines
- ✅ Store secrets in platform secret managers
- ✅ Test scripts locally before committing to CI
- ✅ Use matrix builds for cross-platform testing

## Example: Complete CI/CD Workflow

```yaml
# .github/workflows/powershell-ci.yml
name: PowerShell CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]

    steps:
      - uses: actions/checkout@v4

      - name: Install dependencies
        shell: pwsh
        run: |
          Install-Module -Name Pester, PSScriptAnalyzer -Force -Scope CurrentUser

      - name: Run PSScriptAnalyzer
        shell: pwsh
        run: |
          $results = Invoke-ScriptAnalyzer -Path . -Recurse -Settings PSGallery
          if ($results) {
              $results | Format-Table
              throw "PSScriptAnalyzer found issues"
          }

      - name: Run Pester tests
        shell: pwsh
        run: |
          $config = New-PesterConfiguration
          $config.Run.Path = './tests'
          $config.TestResult.Enabled = $true
          $config.TestResult.OutputFormat = 'NUnitXml'
          $result = Invoke-Pester -Configuration $config
          if ($result.FailedCount -gt 0) { throw "Tests failed" }

      - name: Publish test results
        if: always()
        uses: EnricoMi/publish-unit-test-result-action@v2
        with:
          files: testResults.xml

  deploy:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Deploy to Azure
        shell: pwsh
        env:
          AZURE_CREDENTIALS: ${{ secrets.AZURE_CREDENTIALS }}
        run: |
          Install-Module -Name Az -Force -Scope CurrentUser
          ./deploy.ps1 -Environment Production
```
