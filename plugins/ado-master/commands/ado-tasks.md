---
description: Help with common Azure DevOps pipeline tasks and their usage
---

# Azure DevOps Pipeline Tasks Reference

## Purpose
Provide guidance on using common Azure DevOps pipeline tasks with best practices and current syntax.

## Before Using Tasks

**Check latest task documentation:**
1. Search for specific task in Azure DevOps Task documentation
2. Check latest task version available
3. Review task-specific release notes
4. Check for deprecated tasks or parameters

**Resources:**
- https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/
- https://github.com/microsoft/azure-pipelines-tasks

## Common Tasks by Category

### Build Tasks

#### .NET Core/.NET

```yaml
# Install .NET SDK
- task: UseDotNet@2
  displayName: 'Install .NET SDK'
  inputs:
    version: '8.x'  # or specific: '8.0.100'
    packageType: 'sdk'
    installationPath: $(Agent.ToolsDirectory)/dotnet

# Restore dependencies
- task: DotNetCoreCLI@2
  displayName: 'dotnet restore'
  inputs:
    command: 'restore'
    projects: '**/*.csproj'
    feedsToUse: 'select'
    vstsFeed: 'my-feed'  # If using Azure Artifacts

# Build
- task: DotNetCoreCLI@2
  displayName: 'dotnet build'
  inputs:
    command: 'build'
    projects: '**/*.csproj'
    arguments: '--configuration $(buildConfiguration) --no-restore'

# Test
- task: DotNetCoreCLI@2
  displayName: 'dotnet test'
  inputs:
    command: 'test'
    projects: '**/*Tests.csproj'
    arguments: '--configuration $(buildConfiguration) --no-build --collect:"XPlat Code Coverage"'
    publishTestResults: true

# Publish
- task: DotNetCoreCLI@2
  displayName: 'dotnet publish'
  inputs:
    command: 'publish'
    publishWebProjects: true
    arguments: '--configuration $(buildConfiguration) --output $(Build.ArtifactStagingDirectory)'
    zipAfterPublish: true
    modifyOutputPath: true
```

#### Node.js/npm

```yaml
# Install Node.js
- task: NodeTool@0
  displayName: 'Install Node.js'
  inputs:
    versionSpec: '20.x'
    checkLatest: false

# npm install/ci
- task: Npm@1
  displayName: 'npm ci'
  inputs:
    command: 'ci'
    workingDir: '$(System.DefaultWorkingDirectory)'
    verbose: false

# npm custom command
- task: Npm@1
  displayName: 'npm run build'
  inputs:
    command: 'custom'
    customCommand: 'run build'
    workingDir: '$(System.DefaultWorkingDirectory)'

# Or use script
- script: |
    npm ci
    npm run lint
    npm run build
    npm test
  displayName: 'Build and test'
```

#### Java (Maven)

```yaml
# Set Java version
- task: JavaToolInstaller@0
  displayName: 'Install Java'
  inputs:
    versionSpec: '17'
    jdkArchitectureOption: 'x64'
    jdkSourceOption: 'PreInstalled'

# Maven
- task: Maven@3
  displayName: 'Maven build'
  inputs:
    mavenPomFile: 'pom.xml'
    goals: 'clean package'
    options: '-DskipTests=false'
    publishJUnitResults: true
    testResultsFiles: '**/surefire-reports/TEST-*.xml'
    javaHomeOption: 'JDKVersion'
    jdkVersionOption: '1.17'
    mavenVersionOption: 'Default'
    mavenAuthenticateFeed: false
```

#### Python

```yaml
# Use Python version
- task: UsePythonVersion@0
  displayName: 'Use Python 3.11'
  inputs:
    versionSpec: '3.11'
    addToPath: true
    architecture: 'x64'

# Install dependencies
- script: |
    python -m pip install --upgrade pip
    pip install -r requirements.txt
  displayName: 'Install dependencies'

# Run tests with pytest
- script: |
    pip install pytest pytest-cov
    pytest tests/ --junitxml=junit/test-results.xml --cov=. --cov-report=xml
  displayName: 'Run tests'

# Publish test results
- task: PublishTestResults@2
  condition: succeededOrFailed()
  inputs:
    testResultsFormat: 'JUnit'
    testResultsFiles: '**/test-results.xml'

- task: PublishCodeCoverageResults@1
  inputs:
    codeCoverageTool: 'Cobertura'
    summaryFileLocation: '$(System.DefaultWorkingDirectory)/coverage.xml'
```

### Docker Tasks

```yaml
# Build Docker image
- task: Docker@2
  displayName: 'Build Docker image'
  inputs:
    command: 'build'
    repository: '$(imageRepository)'
    dockerfile: '$(dockerfilePath)'
    tags: |
      $(tag)
      latest
    arguments: '--build-arg VERSION=$(Build.BuildId)'

# Push to container registry
- task: Docker@2
  displayName: 'Push to ACR'
  inputs:
    command: 'push'
    repository: '$(imageRepository)'
    containerRegistry: '$(dockerRegistryServiceConnection)'
    tags: |
      $(tag)
      latest

# Build and push (combined)
- task: Docker@2
  displayName: 'Build and Push'
  inputs:
    command: 'buildAndPush'
    repository: '$(imageRepository)'
    dockerfile: '$(dockerfilePath)'
    containerRegistry: '$(dockerRegistryServiceConnection)'
    tags: |
      $(Build.BuildId)
      latest

# Run container
- task: Docker@2
  displayName: 'Run Docker container'
  inputs:
    command: 'run'
    arguments: '-d -p 8080:80 --name myapp $(imageRepository):$(tag)'

# Docker Compose
- task: DockerCompose@0
  displayName: 'Docker Compose Up'
  inputs:
    containerregistrytype: 'Azure Container Registry'
    azureSubscription: '$(azureSubscription)'
    azureContainerRegistry: '$(containerRegistry)'
    dockerComposeFile: 'docker-compose.yml'
    action: 'Run services'
```

### Azure Tasks

```yaml
# Azure CLI
- task: AzureCLI@2
  displayName: 'Azure CLI'
  inputs:
    azureSubscription: '$(serviceConnection)'
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      az --version
      az account show
      az group list --output table

# Azure PowerShell
- task: AzurePowerShell@5
  displayName: 'Azure PowerShell'
  inputs:
    azureSubscription: '$(serviceConnection)'
    ScriptType: 'InlineScript'
    Inline: |
      Get-AzResourceGroup | Select-Object ResourceGroupName, Location
    azurePowerShellVersion: 'LatestVersion'

# Azure Web App Deploy
- task: AzureWebApp@1
  displayName: 'Deploy to Azure Web App'
  inputs:
    azureSubscription: '$(serviceConnection)'
    appType: 'webAppLinux'
    appName: '$(webAppName)'
    package: '$(Pipeline.Workspace)/drop/**/*.zip'
    runtimeStack: 'NODE|18-lts'

# Azure Functions Deploy
- task: AzureFunctionApp@1
  displayName: 'Deploy Azure Function'
  inputs:
    azureSubscription: '$(serviceConnection)'
    appType: 'functionAppLinux'
    appName: '$(functionAppName)'
    package: '$(Pipeline.Workspace)/drop/**/*.zip'
    runtimeStack: 'NODE|18'

# Azure Key Vault
- task: AzureKeyVault@2
  displayName: 'Get secrets from Key Vault'
  inputs:
    azureSubscription: '$(serviceConnection)'
    KeyVaultName: '$(keyVaultName)'
    SecretsFilter: '*'
    RunAsPreJob: true
```

### Test and Quality Tasks

```yaml
# Publish Test Results
- task: PublishTestResults@2
  displayName: 'Publish test results'
  condition: succeededOrFailed()
  inputs:
    testResultsFormat: 'JUnit'  # or 'NUnit', 'XUnit', 'VSTest'
    testResultsFiles: '**/test-results.xml'
    searchFolder: '$(System.DefaultWorkingDirectory)'
    mergeTestResults: true
    failTaskOnFailedTests: true
    testRunTitle: 'Unit Tests'

# Publish Code Coverage
- task: PublishCodeCoverageResults@1
  displayName: 'Publish code coverage'
  inputs:
    codeCoverageTool: 'Cobertura'  # or 'JaCoCo', 'Cobertura'
    summaryFileLocation: '$(System.DefaultWorkingDirectory)/coverage.xml'
    reportDirectory: '$(System.DefaultWorkingDirectory)/htmlcov'
    failIfCoverageEmpty: true

# SonarQube/SonarCloud
- task: SonarQubePrepare@5
  displayName: 'Prepare SonarQube'
  inputs:
    SonarQube: 'sonarqube-connection'
    scannerMode: 'MSBuild'
    projectKey: 'my-project'
    projectName: 'My Project'

- task: SonarQubeAnalyze@5
  displayName: 'Run SonarQube Analysis'

- task: SonarQubePublish@5
  displayName: 'Publish Quality Gate'
  inputs:
    pollingTimeoutSec: '300'
```

### Artifact and Package Tasks

```yaml
# Publish Build Artifacts
- task: PublishBuildArtifacts@1
  displayName: 'Publish artifacts'
  inputs:
    pathToPublish: '$(Build.ArtifactStagingDirectory)'
    artifactName: 'drop'
    publishLocation: 'Container'

# Publish Pipeline Artifact (newer, faster)
- task: PublishPipelineArtifact@1
  displayName: 'Publish pipeline artifact'
  inputs:
    targetPath: '$(Build.ArtifactStagingDirectory)'
    artifactName: 'drop'
    publishLocation: 'pipeline'

# Download Pipeline Artifact
- task: DownloadPipelineArtifact@2
  displayName: 'Download artifacts'
  inputs:
    artifact: 'drop'
    path: '$(System.DefaultWorkingDirectory)/artifacts'

# NuGet Pack
- task: NuGetCommand@2
  displayName: 'NuGet pack'
  inputs:
    command: 'pack'
    packagesToPack: '**/*.csproj'
    versioningScheme: 'byBuildNumber'

# NuGet Push
- task: NuGetCommand@2
  displayName: 'NuGet push'
  inputs:
    command: 'push'
    publishVstsFeed: 'my-feed'
    allowPackageConflicts: false

# npm Publish
- task: Npm@1
  displayName: 'npm publish'
  inputs:
    command: 'publish'
    workingDir: '$(System.DefaultWorkingDirectory)'
    publishRegistry: 'useFeed'
    publishFeed: 'my-feed'
```

### Utility Tasks

```yaml
# Copy Files
- task: CopyFiles@2
  displayName: 'Copy files'
  inputs:
    SourceFolder: '$(System.DefaultWorkingDirectory)'
    Contents: |
      **/*.js
      **/*.json
      !**/node_modules/**
    TargetFolder: '$(Build.ArtifactStagingDirectory)'
    CleanTargetFolder: true
    OverWrite: true

# Archive Files
- task: ArchiveFiles@2
  displayName: 'Archive files'
  inputs:
    rootFolderOrFile: '$(Build.ArtifactStagingDirectory)'
    includeRootFolder: false
    archiveType: 'zip'
    archiveFile: '$(Build.ArtifactStagingDirectory)/$(Build.BuildId).zip'
    replaceExistingArchive: true

# Extract Files
- task: ExtractFiles@1
  displayName: 'Extract files'
  inputs:
    archiveFilePatterns: '**/*.zip'
    destinationFolder: '$(System.DefaultWorkingDirectory)/extracted'
    cleanDestinationFolder: true

# Delete Files
- task: DeleteFiles@1
  displayName: 'Delete temp files'
  inputs:
    SourceFolder: '$(Build.ArtifactStagingDirectory)'
    Contents: |
      **/*.tmp
      **/*.log
    RemoveSourceFolder: false

# Cache
- task: Cache@2
  displayName: 'Cache dependencies'
  inputs:
    key: 'npm | "$(Agent.OS)" | package-lock.json'
    restoreKeys: |
      npm | "$(Agent.OS)"
    path: '$(npm_config_cache)'
    cacheHitVar: 'CACHE_RESTORED'

# Download Secure File
- task: DownloadSecureFile@1
  name: certificateFile
  displayName: 'Download certificate'
  inputs:
    secureFile: 'certificate.pfx'

- script: |
    echo "Certificate: $(certificateFile.secureFilePath)"
  displayName: 'Use certificate'
```

### Deployment Tasks

```yaml
# Kubernetes Manifest
- task: KubernetesManifest@0
  displayName: 'Deploy to Kubernetes'
  inputs:
    action: 'deploy'
    kubernetesServiceConnection: 'k8s-connection'
    namespace: 'default'
    manifests: |
      $(System.DefaultWorkingDirectory)/k8s/deployment.yaml
      $(System.DefaultWorkingDirectory)/k8s/service.yaml

# Helm Deploy
- task: HelmDeploy@0
  displayName: 'Helm deploy'
  inputs:
    connectionType: 'Kubernetes Service Connection'
    kubernetesServiceConnection: 'k8s-connection'
    namespace: 'default'
    command: 'upgrade'
    chartType: 'FilePath'
    chartPath: '$(System.DefaultWorkingDirectory)/charts/myapp'
    releaseName: 'myapp'
    overrideValues: 'image.tag=$(Build.BuildId)'
```

### Script Tasks

```yaml
# Bash
- task: Bash@3
  displayName: 'Run bash script'
  inputs:
    targetType: 'inline'
    script: |
      #!/bin/bash
      echo "Running bash script"
      npm install
      npm test

# Or from file
- task: Bash@3
  displayName: 'Run script file'
  inputs:
    targetType: 'filePath'
    filePath: '$(System.DefaultWorkingDirectory)/scripts/build.sh'
    arguments: '--env production'
    workingDirectory: '$(System.DefaultWorkingDirectory)'

# PowerShell
- task: PowerShell@2
  displayName: 'Run PowerShell script'
  inputs:
    targetType: 'inline'
    script: |
      Write-Host "Running PowerShell"
      $version = "1.0.0"
      Write-Host "##vso[task.setvariable variable=AppVersion]$version"

# Python Script
- task: PythonScript@0
  displayName: 'Run Python script'
  inputs:
    scriptSource: 'inline'
    script: |
      import os
      print(f"Build ID: {os.environ.get('BUILD_BUILDID')}")
```

## Task Best Practices

**Version Pinning:**
```yaml
# Pin major version (recommended)
- task: NodeTool@0

# Pin specific version
- task: Docker@2.221.0

# Latest (not recommended for production)
- task: Docker@*
```

**Error Handling:**
```yaml
# Continue on error
- task: Npm@1
  continueOnError: true
  inputs:
    command: 'test'

# Retry on failure
- task: Docker@2
  retryCountOnTaskFailure: 3
  inputs:
    command: 'push'

# Conditional execution
- task: PublishTestResults@2
  condition: succeededOrFailed()
```

**Timeouts:**
```yaml
- task: Npm@1
  timeoutInMinutes: 10
  inputs:
    command: 'install'
```

## Output

When helping with tasks, provide:
1. Latest task version and syntax
2. Complete working example
3. Required inputs explanation
4. Common optional inputs
5. Best practices for the specific task
6. Error handling recommendations
7. Links to official documentation
8. Related tasks to consider
