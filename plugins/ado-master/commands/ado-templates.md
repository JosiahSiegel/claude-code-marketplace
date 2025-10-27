---
description: Create and manage reusable Azure DevOps pipeline templates for consistency and efficiency
---

# Azure DevOps Pipeline Templates

## Purpose
Create, manage, and implement reusable YAML pipeline templates following 2025 best practices for maximum code reuse and consistency.

## Why Use Templates

**Benefits:**
- DRY principle (Don't Repeat Yourself)
- Centralized updates affect all pipelines
- Consistent security and quality standards
- Reduced maintenance overhead
- Faster pipeline creation
- Standardized deployment patterns

## Template Types

### 1. Step Templates
Reusable sequences of steps:

```yaml
# templates/build-dotnet.yml
parameters:
  - name: buildConfiguration
    type: string
    default: 'Release'
  - name: projectPath
    type: string
    default: '**/*.csproj'

steps:
  - task: UseDotNet@2
    displayName: 'Install .NET SDK'
    inputs:
      version: '8.x'

  - task: DotNetCoreCLI@2
    displayName: 'Restore packages'
    inputs:
      command: 'restore'
      projects: '${{ parameters.projectPath }}'

  - task: DotNetCoreCLI@2
    displayName: 'Build projects'
    inputs:
      command: 'build'
      projects: '${{ parameters.projectPath }}'
      arguments: '--configuration ${{ parameters.buildConfiguration }} --no-restore'
```

**Usage:**
```yaml
steps:
  - template: templates/build-dotnet.yml
    parameters:
      buildConfiguration: 'Release'
      projectPath: 'src/**/*.csproj'
```

### 2. Job Templates
Complete job definitions:

```yaml
# templates/security-scan-job.yml
parameters:
  - name: scanCategories
    type: string
    default: 'secrets,code,dependencies'

jobs:
  - job: SecurityScan
    displayName: 'Security Analysis'
    pool:
      vmImage: 'ubuntu-24.04'
    steps:
      - checkout: self
        fetchDepth: 1

      - task: MicrosoftSecurityDevOps@1
        displayName: 'Run Security Scan'
        inputs:
          categories: '${{ parameters.scanCategories }}'
          break: true
          breakSeverity: 'high'

      - task: PublishSecurityAnalysisLogs@3
        displayName: 'Publish Results'
```

**Usage:**
```yaml
stages:
  - stage: Security
    jobs:
      - template: templates/security-scan-job.yml
        parameters:
          scanCategories: 'all'
```

### 3. Stage Templates
Full stage definitions:

```yaml
# templates/deploy-stage.yml
parameters:
  - name: environment
    type: string
  - name: azureSubscription
    type: string
  - name: appName
    type: string

stages:
  - stage: Deploy_${{ parameters.environment }}
    displayName: 'Deploy to ${{ parameters.environment }}'
    jobs:
      - deployment: DeployApp
        environment: '${{ parameters.environment }}'
        pool:
          vmImage: 'ubuntu-24.04'
        strategy:
          runOnce:
            deploy:
              steps:
                - download: current
                  artifact: drop

                - task: AzureWebApp@1
                  displayName: 'Deploy Azure Web App'
                  inputs:
                    azureSubscription: '${{ parameters.azureSubscription }}'
                    appName: '${{ parameters.appName }}'
                    package: '$(Pipeline.Workspace)/drop/**/*.zip'
```

**Usage:**
```yaml
stages:
  - template: templates/deploy-stage.yml
    parameters:
      environment: 'production'
      azureSubscription: 'prod-connection'
      appName: 'my-app-prod'
```

### 4. Variable Templates
Shared variable definitions:

```yaml
# templates/common-variables.yml
variables:
  - name: buildConfiguration
    value: 'Release'
  - name: dotnetVersion
    value: '8.x'
  - name: nodeVersion
    value: '20.x'

  # Conditional variables
  - ${{ if eq(variables['Build.SourceBranch'], 'refs/heads/main') }}:
    - name: deployToProduction
      value: true
  - ${{ else }}:
    - name: deployToProduction
      value: false
```

**Usage:**
```yaml
variables:
  - template: templates/common-variables.yml

stages:
  - stage: Build
    jobs:
      - job: BuildJob
        steps:
          - script: echo "Build config: $(buildConfiguration)"
```

## Template Libraries

### Centralized Template Repository

```yaml
# Main pipeline
resources:
  repositories:
    - repository: templates
      type: git
      name: MyOrg/pipeline-templates
      ref: refs/heads/main

stages:
  - template: build/dotnet-build.yml@templates
    parameters:
      buildConfiguration: 'Release'

  - template: deploy/azure-webapp.yml@templates
    parameters:
      environment: 'production'
```

### Template Repository Structure

```
pipeline-templates/
├── build/
│   ├── dotnet-build.yml
│   ├── node-build.yml
│   ├── python-build.yml
│   └── docker-build.yml
├── test/
│   ├── unit-tests.yml
│   ├── integration-tests.yml
│   └── e2e-tests.yml
├── security/
│   ├── security-scan.yml
│   ├── container-scan.yml
│   └── dependency-scan.yml
├── deploy/
│   ├── azure-webapp.yml
│   ├── azure-function.yml
│   ├── kubernetes.yml
│   └── docker-registry.yml
└── variables/
    ├── common.yml
    ├── dev.yml
    ├── staging.yml
    └── prod.yml
```

## Advanced Template Patterns

### Conditional Template Inclusion

```yaml
stages:
  # Always run build
  - template: templates/build.yml

  # Security scan only on main
  - ${{ if eq(variables['Build.SourceBranch'], 'refs/heads/main') }}:
    - template: templates/security-full.yml
  - ${{ else }}:
    - template: templates/security-quick.yml

  # Deploy only if not PR
  - ${{ if ne(variables['Build.Reason'], 'PullRequest') }}:
    - template: templates/deploy.yml
```

### Template with Loops

```yaml
# templates/deploy-multi-region.yml
parameters:
  - name: regions
    type: object
    default:
      - name: 'eastus'
        appName: 'app-eastus'
      - name: 'westus'
        appName: 'app-westus'

stages:
  - ${{ each region in parameters.regions }}:
    - stage: Deploy_${{ region.name }}
      displayName: 'Deploy to ${{ region.name }}'
      jobs:
        - deployment: Deploy
          environment: 'production'
          pool:
            vmImage: 'ubuntu-24.04'
          strategy:
            runOnce:
              deploy:
                steps:
                  - task: AzureWebApp@1
                    inputs:
                      appName: '${{ region.appName }}'
```

**Usage:**
```yaml
stages:
  - template: templates/deploy-multi-region.yml
    parameters:
      regions:
        - name: 'eastus'
          appName: 'myapp-eastus'
        - name: 'westeurope'
          appName: 'myapp-westeurope'
        - name: 'southeastasia'
          appName: 'myapp-asia'
```

### Template Inheritance

```yaml
# templates/base-build.yml
parameters:
  - name: checkoutDepth
    type: number
    default: 1
  - name: enableCaching
    type: boolean
    default: true

steps:
  - checkout: self
    fetchDepth: ${{ parameters.checkoutDepth }}

  - ${{ if parameters.enableCaching }}:
    - task: Cache@2
      inputs:
        key: 'deps | "$(Agent.OS)" | **/lock.json'
        path: '$(Pipeline.Workspace)/.cache'

  # Additional steps provided by extending template
  - ${{ parameters.additionalSteps }}
```

## Real-World Template Examples

### Complete CI/CD Template

```yaml
# templates/complete-cicd.yml
parameters:
  - name: buildSteps
    type: stepList
  - name: testSteps
    type: stepList
  - name: deployEnvironments
    type: object
  - name: enableSecurity
    type: boolean
    default: true

stages:
  - stage: Build
    displayName: 'Build Application'
    jobs:
      - job: BuildJob
        pool:
          vmImage: 'ubuntu-24.04'
        steps:
          - checkout: self
            fetchDepth: 1

          - ${{ parameters.buildSteps }}

          - publish: $(Build.ArtifactStagingDirectory)
            artifact: drop

  - stage: Test
    displayName: 'Test Application'
    dependsOn: Build
    jobs:
      - job: TestJob
        pool:
          vmImage: 'ubuntu-24.04'
        steps:
          - download: current
            artifact: drop

          - ${{ parameters.testSteps }}

  - ${{ if parameters.enableSecurity }}:
    - stage: Security
      displayName: 'Security Scan'
      dependsOn: Build
      jobs:
        - template: security-scan-job.yml

  - ${{ each env in parameters.deployEnvironments }}:
    - stage: Deploy_${{ env.name }}
      displayName: 'Deploy to ${{ env.name }}'
      dependsOn:
        - Test
        - ${{ if parameters.enableSecurity }}:
          - Security
      jobs:
        - deployment: DeployApp
          environment: '${{ env.name }}'
          strategy:
            runOnce:
              deploy:
                steps:
                  - ${{ env.deploySteps }}
```

**Usage:**
```yaml
extends:
  template: templates/complete-cicd.yml
  parameters:
    buildSteps:
      - task: NodeTool@0
        inputs:
          versionSpec: '20.x'
      - script: npm ci
      - script: npm run build

    testSteps:
      - script: npm test
      - script: npm run test:e2e

    enableSecurity: true

    deployEnvironments:
      - name: 'staging'
        deploySteps:
          - task: AzureWebApp@1
            inputs:
              azureSubscription: 'staging-connection'
              appName: 'myapp-staging'

      - name: 'production'
        deploySteps:
          - task: AzureWebApp@1
            inputs:
              azureSubscription: 'prod-connection'
              appName: 'myapp-prod'
```

### Docker Build Template

```yaml
# templates/docker-build-push.yml
parameters:
  - name: dockerfilePath
    type: string
    default: 'Dockerfile'
  - name: imageName
    type: string
  - name: registry
    type: string
  - name: enableScan
    type: boolean
    default: true

steps:
  - task: Docker@2
    displayName: 'Build Docker Image'
    inputs:
      command: 'build'
      Dockerfile: '${{ parameters.dockerfilePath }}'
      repository: '${{ parameters.imageName }}'
      tags: |
        $(Build.BuildId)
        latest
      arguments: '--build-arg BUILDKIT_INLINE_CACHE=1'

  - ${{ if parameters.enableScan }}:
    - task: MicrosoftSecurityDevOps@1
      displayName: 'Scan Container Image'
      inputs:
        categories: 'containers'
        tools: 'trivy'

  - task: Docker@2
    displayName: 'Push to Registry'
    inputs:
      command: 'push'
      repository: '${{ parameters.imageName }}'
      containerRegistry: '${{ parameters.registry }}'
      tags: |
        $(Build.BuildId)
        latest
```

## Template Best Practices

**Parameters:**
- Provide sensible defaults
- Use type constraints (string, number, boolean, object)
- Document parameter purpose
- Validate parameter values when possible

**Structure:**
- Keep templates focused and single-purpose
- Use meaningful names
- Version control templates
- Test templates before use

**Security:**
- Never hardcode secrets in templates
- Use parameter validation
- Include security scanning by default
- Follow least privilege principle

**Maintenance:**
- Version template repositories
- Document template usage
- Provide example usage
- Keep templates updated with latest task versions

## Template Testing

```yaml
# test-template.yml
# Test pipeline for validating templates

trigger: none

stages:
  - stage: TestBuildTemplate
    jobs:
      - job: TestJob
        pool:
          vmImage: 'ubuntu-24.04'
        steps:
          - template: templates/build-dotnet.yml
            parameters:
              buildConfiguration: 'Debug'
              projectPath: 'tests/sample.csproj'

          - script: echo "Template test passed"
```

## Migrating to Templates

**Step 1: Identify Common Patterns**
```bash
# Analyze existing pipelines
az pipelines list --query "[].name"
# Look for repeated YAML blocks
```

**Step 2: Extract to Template**
```yaml
# Original inline steps → Template
# Move common steps to templates/build.yml
```

**Step 3: Parameterize**
```yaml
# Add parameters for customization
parameters:
  - name: buildConfig
    type: string
    default: 'Release'
```

**Step 4: Test and Deploy**
```yaml
# Test with one pipeline first
# Gradually migrate others
```

## Resources

- [Azure Pipelines Template Documentation](https://learn.microsoft.com/azure/devops/pipelines/process/templates)
- [Template Expressions](https://learn.microsoft.com/azure/devops/pipelines/process/expressions)
- [Extends Templates](https://learn.microsoft.com/azure/devops/pipelines/security/templates)
- [Template Best Practices](https://learn.microsoft.com/azure/devops/pipelines/process/template-usage-reference)
