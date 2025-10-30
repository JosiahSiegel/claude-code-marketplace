---
description: Create Azure DevOps YAML pipelines following current best practices and industry standards
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

# Create Azure DevOps Pipeline

## Purpose
Create new Azure DevOps YAML pipelines following the latest best practices, security standards, and industry conventions.

## Before Creating

**CRITICAL: Fetch latest Azure DevOps documentation**

Before creating any pipeline, search for and review:
1. Latest Azure Pipelines YAML schema documentation
2. Current best practices for Azure DevOps pipelines (current year)
3. Security recommendations for Azure Pipelines
4. Latest task versions and deprecation notices

**Essential resources to check:**
- [YAML Schema](https://learn.microsoft.com/azure/devops/pipelines/yaml-schema/)
- [Security Overview](https://learn.microsoft.com/azure/devops/pipelines/security/overview)
- [Tasks Documentation](https://learn.microsoft.com/azure/devops/pipelines/process/tasks)
- [Azure DevOps Release Notes](https://learn.microsoft.com/azure/devops/release-notes/)

## Pipeline Creation Process

### 1. Gather Requirements

Ask or determine:
- **Pipeline purpose:** CI, CD, or both?
- **Trigger strategy:** On commit, PR, scheduled, manual?
- **Platform/language:** .NET, Node.js, Python, Java, etc.?
- **Target environment:** Azure, on-premises, multi-cloud?
- **Deployment strategy:** Blue-green, canary, rolling?
- **Security requirements:** Code scanning, secret scanning, compliance?
- **Testing requirements:** Unit, integration, E2E tests?

### 2. Choose Pipeline Template

Based on purpose, select appropriate structure:

**CI Pipeline:**
- Build and test on every commit
- Fast feedback
- Artifact generation
- Code quality checks

**CD Pipeline:**
- Deploy to environments
- Approval gates
- Environment-specific configurations
- Rollback capability

**CI/CD Pipeline:**
- Combined build and deploy
- Multi-stage with dependencies
- Environment progression

### 3. Best Practices Checklist

Apply current Azure DevOps best practices:

**Structure:**
- Use multi-stage YAML (stages → jobs → steps)
- Separate concerns (build, test, deploy)
- Use templates for reusability
- Version control all pipeline files

**Triggers:**
```yaml
trigger:
  branches:
    include:
      - main
      - develop
  paths:
    include:
      - src/*
    exclude:
      - docs/*

pr:
  branches:
    include:
      - main
  paths:
    exclude:
      - '**.md'
```

**Variables:**
```yaml
variables:
  # Use variable groups for secrets
  - group: 'production-secrets'

  # Define build variables
  - name: buildConfiguration
    value: 'Release'

  # Use runtime parameters for flexibility
parameters:
  - name: environment
    type: string
    default: 'dev'
    values:
      - dev
      - staging
      - production
```

**Security:**
- Never hardcode secrets
- Use Azure Key Vault integration
- Implement secret scanning
- Use service connections with proper permissions
- Enable pipeline permissions and checks

**Performance:**
- Use caching for dependencies
- Parallelize independent jobs
- Use hosted agents efficiently
- Clean up artifacts after retention period

**Quality:**
- Run linters and code analysis
- Require test pass before deploy
- Code coverage thresholds
- Security scanning (SAST, dependency scanning)

### 4. Standard Pipeline Templates

#### Basic CI Pipeline (Build & Test)

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - main
      - develop

pool:
  vmImage: 'ubuntu-24.04'  # Ubuntu 24.04 LTS recommended for 2025

variables:
  buildConfiguration: 'Release'

stages:
  - stage: Build
    displayName: 'Build and Test'
    jobs:
      - job: BuildJob
        displayName: 'Build Application'
        steps:
          - task: UseDotNet@2
            displayName: 'Install .NET SDK'
            inputs:
              version: '8.x'

          - task: DotNetCoreCLI@2
            displayName: 'Restore Dependencies'
            inputs:
              command: 'restore'
              projects: '**/*.csproj'

          - task: DotNetCoreCLI@2
            displayName: 'Build Project'
            inputs:
              command: 'build'
              arguments: '--configuration $(buildConfiguration) --no-restore'

          - task: DotNetCoreCLI@2
            displayName: 'Run Tests'
            inputs:
              command: 'test'
              arguments: '--configuration $(buildConfiguration) --no-build --collect:"XPlat Code Coverage"'
              publishTestResults: true

          - task: PublishCodeCoverageResults@1
            displayName: 'Publish Code Coverage'
            inputs:
              codeCoverageTool: 'cobertura'
              summaryFileLocation: '$(Agent.TempDirectory)/**/coverage.cobertura.xml'

          - task: DotNetCoreCLI@2
            displayName: 'Publish Artifact'
            inputs:
              command: 'publish'
              publishWebProjects: true
              arguments: '--configuration $(buildConfiguration) --output $(Build.ArtifactStagingDirectory)'
              zipAfterPublish: true

          - task: PublishBuildArtifacts@1
            displayName: 'Upload Artifacts'
            inputs:
              pathToPublish: '$(Build.ArtifactStagingDirectory)'
              artifactName: 'drop'
```

#### Multi-Stage CI/CD Pipeline

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - main

pool:
  vmImage: 'ubuntu-24.04'

variables:
  - group: 'app-secrets'  # Variable group
  - name: buildConfiguration
    value: 'Release'

stages:
  # Build Stage
  - stage: Build
    displayName: 'Build Application'
    jobs:
      - job: BuildJob
        steps:
          - script: echo "Building application..."
          # Add build steps here

          - publish: $(Build.ArtifactStagingDirectory)
            artifact: drop

  # Test Stage
  - stage: Test
    displayName: 'Run Tests'
    dependsOn: Build
    jobs:
      - job: UnitTests
        steps:
          - script: echo "Running unit tests..."

      - job: IntegrationTests
        steps:
          - script: echo "Running integration tests..."

  # Deploy to Dev
  - stage: DeployDev
    displayName: 'Deploy to Dev'
    dependsOn: Test
    condition: succeeded()
    jobs:
      - deployment: DeployDevJob
        environment: 'dev'
        strategy:
          runOnce:
            deploy:
              steps:
                - download: current
                  artifact: drop
                - script: echo "Deploying to dev..."

  # Deploy to Production (with approval)
  - stage: DeployProd
    displayName: 'Deploy to Production'
    dependsOn: DeployDev
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: DeployProdJob
        environment: 'production'  # Configure approvals in ADO UI
        strategy:
          runOnce:
            deploy:
              steps:
                - download: current
                  artifact: drop
                - script: echo "Deploying to production..."
```

#### Pipeline with Templates (Reusable)

**Main pipeline (azure-pipelines.yml):**
```yaml
trigger:
  branches:
    include:
      - main

resources:
  repositories:
    - repository: templates
      type: git
      name: shared-templates
      ref: refs/heads/main

stages:
  - template: templates/build-template.yml@templates
    parameters:
      buildConfiguration: 'Release'

  - template: templates/deploy-template.yml@templates
    parameters:
      environment: 'production'
      dependsOn: Build
```

**Build template (templates/build-template.yml):**
```yaml
parameters:
  - name: buildConfiguration
    type: string
    default: 'Release'

jobs:
  - job: Build
    pool:
      vmImage: 'ubuntu-24.04'
    steps:
      - script: echo "Building with ${{ parameters.buildConfiguration }}"
      # Add build steps
```

#### Node.js/npm Pipeline

```yaml
trigger:
  branches:
    include:
      - main

pool:
  vmImage: 'ubuntu-24.04'

variables:
  nodeVersion: '20.x'

stages:
  - stage: Build
    jobs:
      - job: BuildAndTest
        steps:
          - task: NodeTool@0
            displayName: 'Install Node.js'
            inputs:
              versionSpec: '$(nodeVersion)'

          - task: Cache@2
            displayName: 'Cache npm packages'
            inputs:
              key: 'npm | "$(Agent.OS)" | package-lock.json'
              path: '$(npm_config_cache)'
              restoreKeys: |
                npm | "$(Agent.OS)"

          - script: npm ci
            displayName: 'Install Dependencies'

          - script: npm run lint
            displayName: 'Run Linter'

          - script: npm test -- --coverage
            displayName: 'Run Tests'

          - task: PublishTestResults@2
            condition: succeededOrFailed()
            inputs:
              testResultsFiles: '**/test-results.xml'
              testRunTitle: 'Unit Tests'

          - task: PublishCodeCoverageResults@1
            inputs:
              codeCoverageTool: 'Cobertura'
              summaryFileLocation: '$(System.DefaultWorkingDirectory)/coverage/cobertura-coverage.xml'

          - script: npm run build
            displayName: 'Build Application'

          - task: ArchiveFiles@2
            displayName: 'Archive Build Output'
            inputs:
              rootFolderOrFile: '$(System.DefaultWorkingDirectory)/dist'
              includeRootFolder: false
              archiveType: 'zip'
              archiveFile: '$(Build.ArtifactStagingDirectory)/$(Build.BuildId).zip'

          - publish: $(Build.ArtifactStagingDirectory)
            artifact: drop
```

#### Docker Build Pipeline

```yaml
trigger:
  branches:
    include:
      - main

pool:
  vmImage: 'ubuntu-24.04'

variables:
  dockerRegistryServiceConnection: 'myACR'
  imageRepository: 'myapp'
  containerRegistry: 'myregistry.azurecr.io'
  dockerfilePath: '$(Build.SourcesDirectory)/Dockerfile'
  tag: '$(Build.BuildId)'

stages:
  - stage: Build
    displayName: 'Build and Push Docker Image'
    jobs:
      - job: Docker
        steps:
          - task: Docker@2
            displayName: 'Build Docker Image'
            inputs:
              command: 'build'
              repository: '$(imageRepository)'
              dockerfile: '$(dockerfilePath)'
              tags: |
                $(tag)
                latest

          - task: Docker@2
            displayName: 'Scan Image for Vulnerabilities'
            inputs:
              command: 'run'
              arguments: '--rm aquasec/trivy image $(imageRepository):$(tag)'

          - task: Docker@2
            displayName: 'Push to Container Registry'
            inputs:
              command: 'push'
              repository: '$(imageRepository)'
              containerRegistry: '$(dockerRegistryServiceConnection)'
              tags: |
                $(tag)
                latest
```

### 5. Security Best Practices

**Secrets Management:**
```yaml
# Use Azure Key Vault
variables:
  - group: 'keyvault-secrets'  # Linked to Azure Key Vault

# Or use secret variables
variables:
  - name: apiKey
    value: '$(secretApiKey)'  # Set in pipeline variables as secret
```

**Service Connections:**
- Use service connections for external resources
- Apply least privilege principle
- Enable pipeline permissions
- Use managed identities where possible

**Code Scanning:**
```yaml
- task: CredScan@3
  displayName: 'Run Credential Scanner'

- task: Semmle@1
  displayName: 'Run CodeQL Analysis'
  inputs:
    language: 'csharp'

- task: DependencyCheck@0
  displayName: 'OWASP Dependency Check'
```

### 6. Advanced Features

**Conditional Execution:**
```yaml
- script: echo "Deploy to production"
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
```

**Matrix Strategy:**
```yaml
strategy:
  matrix:
    Python38:
      python.version: '3.8'
    Python39:
      python.version: '3.9'
    Python310:
      python.version: '3.10'
steps:
  - task: UsePythonVersion@0
    inputs:
      versionSpec: '$(python.version)'
```

**Deployment Strategies:**
```yaml
strategy:
  # Rolling deployment
  rolling:
    maxParallel: 2
    deploy:
      steps:
        - script: echo "Deploy"

  # Or canary
  canary:
    increments: [10, 20, 50, 100]
    deploy:
      steps:
        - script: echo "Canary deploy"
```

### 7. Pipeline Organization

**File Structure:**
```
├── azure-pipelines.yml          # Main pipeline
├── pipelines/
│   ├── ci-pipeline.yml          # CI specific
│   ├── cd-pipeline.yml          # CD specific
│   └── templates/
│       ├── build-template.yml   # Reusable build
│       ├── test-template.yml    # Reusable test
│       └── deploy-template.yml  # Reusable deploy
```

### 8. Validation Steps

After creating pipeline:
1. Validate YAML syntax in ADO UI
2. Test with a dry run if possible
3. Run on a feature branch first
4. Check all tasks use latest versions
5. Verify secrets are properly masked in logs
6. Test failure scenarios
7. Verify artifact retention policies
8. Check resource usage and costs

## Common Patterns by Technology

**Python:**
- Use `UsePythonVersion@0` task
- Cache pip packages
- Run pytest with coverage
- Use virtual environments

**.NET:**
- Use `UseDotNet@2` for SDK
- Restore → Build → Test → Publish pattern
- Publish code coverage
- Use `DotNetCoreCLI@2` tasks

**Java:**
- Use `JavaToolInstaller@0`
- Maven or Gradle tasks
- JaCoCo for coverage
- SonarQube integration

**Container:**
- Use `Docker@2` tasks
- Multi-stage builds
- Scan images for vulnerabilities
- Tag with build ID and git SHA

## Output

Provide:
1. Complete YAML pipeline file
2. Explanation of each stage/job
3. Security considerations applied
4. Required service connections or variable groups
5. Setup instructions for ADO
6. Testing recommendations
7. Links to relevant Azure DevOps documentation
8. Next steps for enhancement

## Platform-Specific Notes

**Azure-specific:**
- Use Azure-hosted agents when possible
- Leverage Azure service connections
- Integrate with Azure Key Vault
- Use Azure Artifacts for package management

**On-premises:**
- Configure self-hosted agents
- Network and firewall considerations
- Agent pools and capabilities
- Maintenance and updates
