---
description: Debug Azure DevOps pipeline failures and troubleshoot common issues
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

# Debug Azure DevOps Pipeline

## Purpose
Systematically diagnose and resolve Azure DevOps pipeline failures, errors, and performance issues.

## Before Debugging

**Check latest troubleshooting guides:**
1. Azure DevOps service status: https://status.dev.azure.com/
2. Latest known issues and fixes
3. Recent Azure DevOps updates and breaking changes
4. Task-specific troubleshooting documentation

## Debugging Workflow

### 1. Gather Information

**Essential data to collect:**
```bash
# Get pipeline run details
az pipelines runs show --id <run-id>

# Get specific job logs
az pipelines runs show --id <run-id> --open

# List recent failed runs
az pipelines runs list --pipeline-id <id> --status failed --top 10
```

**From ADO UI:**
- Full logs (Download logs as zip)
- Timeline view (job dependencies)
- Variables used in run
- Agent pool and VM image
- Service connection status
- Error messages and stack traces

### 2. Common Failure Scenarios

#### A. Agent Issues

**Symptom:** Pipeline stuck in "Waiting for an agent"

**Causes:**
- No available agents in pool
- Insufficient parallel jobs
- Agent demands not met
- Pool configuration issues

**Debug steps:**
```yaml
# Check agent pool status
pool:
  vmImage: 'ubuntu-latest'
  demands:
    - agent.os -equals Linux
    - docker

# Add diagnostic step
steps:
  - script: |
      echo "Agent OS: $(Agent.OS)"
      echo "Agent Name: $(Agent.Name)"
      echo "Agent Version: $(Agent.Version)"
      which docker || echo "Docker not found"
    displayName: 'Agent Diagnostics'
```

**Solutions:**
- Increase parallel jobs (Project Settings → Parallel jobs)
- Use different agent pool
- Remove unnecessary demands
- Check self-hosted agent status
- Use Microsoft-hosted agents as fallback

#### B. Task Failures

**Symptom:** Specific task fails with error

**Common task errors:**

**NuGet/npm restore failures:**
```yaml
# Add verbose logging
- task: NuGetCommand@2
  inputs:
    command: 'restore'
    verbosityRestore: 'Detailed'

# Or for npm
- script: npm install --verbose --loglevel silly
  displayName: 'npm install (verbose)'

# Check connectivity
- script: |
    curl -I https://registry.npmjs.org/
    ping -c 3 registry.npmjs.org
  displayName: 'Test npm registry connectivity'
```

**Docker task failures:**
```yaml
# Enable BuildKit debugging
- task: Docker@2
  inputs:
    command: 'build'
    arguments: '--progress=plain --no-cache'
  env:
    DOCKER_BUILDKIT: 1
    BUILDKIT_PROGRESS: plain

# Check Docker daemon
- script: |
    docker version
    docker info
    docker ps
  displayName: 'Docker diagnostics'
```

**Azure CLI task failures:**
```yaml
- task: AzureCLI@2
  inputs:
    azureSubscription: 'connection'
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    addSpnToEnvironment: true
    inlineScript: |
      set -x  # Enable verbose output
      az account show
      az account list --all
```

#### C. Variable Issues

**Symptom:** Variables not resolving or empty

**Debug variables:**
```yaml
steps:
  - script: |
      echo "Build.SourceBranch: $(Build.SourceBranch)"
      echo "Build.Reason: $(Build.Reason)"
      echo "System.Debug: $(System.Debug)"
      env | sort  # Print all environment variables
    displayName: 'Debug Variables'
    env:
      SYSTEM_DEBUG: true

# Enable system diagnostics
variables:
  system.debug: true  # Verbose logging for all tasks
```

**Variable scope issues:**
```yaml
# Job-level variable
jobs:
  - job: A
    variables:
      myVar: 'value'
    steps:
      - script: echo "$(myVar)"  # Works

  - job: B
    steps:
      - script: echo "$(myVar)"  # Empty! Not in scope

# Solution: Use stage or pipeline level variables
variables:
  myVar: 'value'  # Available to all jobs

stages:
  - stage: Build
    variables:
      stageVar: 'value'  # Available to all jobs in stage
```

**Set variables between jobs:**
```yaml
jobs:
  - job: A
    steps:
      - script: echo "##vso[task.setvariable variable=myVar;isOutput=true]myValue"
        name: setVar

  - job: B
    dependsOn: A
    variables:
      varFromA: $[ dependencies.A.outputs['setVar.myVar'] ]
    steps:
      - script: echo "$(varFromA)"
```

#### D. Checkout Issues

**Symptom:** Source checkout fails

**Debug checkout:**
```yaml
steps:
  - checkout: self
    clean: true
    fetchDepth: 1
    lfs: false

  - script: |
      git status
      git log -1
      git remote -v
      ls -la
    displayName: 'Verify checkout'
```

**Common checkout issues:**

**Large repository timeout:**
```yaml
steps:
  - checkout: self
    fetchDepth: 1  # Shallow clone
    clean: true
    persistCredentials: true
```

**Submodule issues:**
```yaml
steps:
  - checkout: self
    submodules: true  # or 'recursive'

  - script: |
      git submodule status
      git submodule update --init --recursive
    displayName: 'Verify submodules'
```

**LFS issues:**
```yaml
steps:
  - checkout: self
    lfs: true

  - script: |
      git lfs env
      git lfs ls-files
    displayName: 'Verify LFS'
```

#### E. Service Connection Failures

**Symptom:** Authentication or authorization errors

**Debug service connections:**
```yaml
- task: AzureCLI@2
  inputs:
    azureSubscription: 'my-connection'
    addSpnToEnvironment: true
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      echo "Service Principal ID: $servicePrincipalId"
      echo "Tenant ID: $tenantId"
      # Don't echo the key!

      # Test authentication
      az login --service-principal \
        --username $servicePrincipalId \
        --password $servicePrincipalKey \
        --tenant $tenantId

      # Test permissions
      az account show
      az group list
```

**Common fixes:**
- Verify service connection exists and is accessible
- Check service principal hasn't expired
- Verify permissions on target resource
- Ensure connection is authorized for pipeline

#### F. Dependency and Build Errors

**Symptom:** Build or compilation fails

**Debugging strategies:**

**Increase verbosity:**
```yaml
# .NET
- task: DotNetCoreCLI@2
  inputs:
    command: 'build'
    arguments: '--verbosity diagnostic'

# Maven
- task: Maven@3
  inputs:
    options: '-X'  # Debug mode

# Gradle
- task: Gradle@2
  inputs:
    options: '--stacktrace --debug'
```

**Isolate the problem:**
```yaml
steps:
  # Test each step individually
  - script: dotnet restore
    displayName: 'Restore only'

  - script: dotnet build --no-restore
    displayName: 'Build only (no restore)'
    continueOnError: true

  - script: dotnet test --no-build
    displayName: 'Test only (no build)'
```

#### G. Timeout Issues

**Symptom:** Job times out

**Identify long-running tasks:**
```yaml
jobs:
  - job: Build
    timeoutInMinutes: 60  # Increase timeout
    steps:
      - script: |
          start_time=$(date +%s)
          npm install
          end_time=$(date +%s)
          echo "npm install took $((end_time - start_time)) seconds"
        displayName: 'timed npm install'
```

**Solutions:**
```yaml
# 1. Increase timeout
jobs:
  - job: LongRunning
    timeoutInMinutes: 120
    cancelTimeoutInMinutes: 10

# 2. Use caching
- task: Cache@2
  inputs:
    key: 'npm | "$(Agent.OS)" | package-lock.json'
    path: '$(npm_config_cache)'

# 3. Split into multiple jobs
jobs:
  - job: Part1
    timeoutInMinutes: 30
  - job: Part2
    dependsOn: Part1
    timeoutInMinutes: 30
```

### 3. Advanced Debugging Techniques

#### A. System Diagnostics

**Enable verbose logging:**
```yaml
variables:
  system.debug: true

steps:
  - task: Bash@3
    inputs:
      targetType: 'inline'
      script: |
        set -x  # Print commands
        set -e  # Exit on error
        # Your commands here
```

#### B. Conditional Debugging

```yaml
steps:
  - script: |
      if [ "$(System.Debug)" == "true" ]; then
        echo "Debug mode enabled"
        env | sort
        df -h
        free -m
      fi
    displayName: 'Conditional Debug Info'

  - script: npm install
    displayName: 'npm install'
    env:
      ${{ if eq(variables['System.Debug'], 'true') }}:
        NPM_CONFIG_LOGLEVEL: silly
```

#### C. Interactive Debugging

**SSH into failed agent (self-hosted):**
```yaml
steps:
  - script: |
      # Keep agent alive on failure for investigation
      if [ $? -ne 0 ]; then
        echo "Build failed. Starting SSH for debugging..."
        sleep 3600  # Keep alive for 1 hour
      fi
    condition: failed()
```

**Reproduce locally:**
```yaml
# Get exact agent environment
- script: |
    echo "## Agent Info" > debug-info.txt
    echo "OS: $(Agent.OS)" >> debug-info.txt
    echo "Name: $(Agent.Name)" >> debug-info.txt
    env >> debug-info.txt

- publish: debug-info.txt
  artifact: debug-info
```

### 4. Logging and Diagnostics

#### A. Custom Logging

```yaml
steps:
  - script: |
      echo "##[section]Starting custom task"
      echo "##[debug]Debug message"
      echo "##[warning]Warning message"
      echo "##[error]Error message"
      echo "##[command]Running command"
    displayName: 'Custom Logging'

  - script: |
      # Log issue
      echo "##vso[task.logissue type=warning]This is a warning"
      echo "##vso[task.logissue type=error]This is an error"
    displayName: 'Log Issues'
```

#### B. Set Variables for Debugging

```yaml
- script: |
    # Set variable for use in later steps
    echo "##vso[task.setvariable variable=debugValue]test"
  displayName: 'Set debug variable'

- script: echo "Debug value: $(debugValue)"
  displayName: 'Use debug variable'
```

#### C. Upload Debug Artifacts

```yaml
- script: |
    # Collect debug information
    mkdir -p $(Build.ArtifactStagingDirectory)/debug
    cp -r logs/ $(Build.ArtifactStagingDirectory)/debug/
    env > $(Build.ArtifactStagingDirectory)/debug/environment.txt
  condition: always()
  displayName: 'Collect debug info'

- publish: $(Build.ArtifactStagingDirectory)/debug
  artifact: debug-logs
  condition: always()
```

### 5. Common Error Patterns

#### A. Permission Errors

**Symptoms:**
- "Permission denied"
- "Access denied"
- "Unauthorized"

**Solutions:**
```yaml
# File permissions
- script: |
    chmod +x script.sh
    ./script.sh
  displayName: 'Fix script permissions'

# Service connection permissions
- task: AzureCLI@2
  inputs:
    azureSubscription: 'connection'
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      # Check permissions
      az role assignment list --assignee $servicePrincipalId
```

#### B. Network Errors

**Symptoms:**
- Connection timeouts
- DNS resolution failures
- Certificate errors

**Debug network:**
```yaml
- script: |
    # Test connectivity
    ping -c 3 google.com
    nslookup myserver.com
    curl -v https://api.example.com

    # Check proxy settings
    echo "HTTP_PROXY: $HTTP_PROXY"
    echo "HTTPS_PROXY: $HTTPS_PROXY"
  displayName: 'Network diagnostics'
```

#### C. Resource Limits

**Symptoms:**
- Out of memory
- Disk space full
- CPU throttling

**Monitor resources:**
```yaml
- script: |
    echo "## Disk Space"
    df -h

    echo "## Memory"
    free -m

    echo "## CPU"
    lscpu
    top -b -n 1 | head -20
  displayName: 'Resource monitoring'
  condition: always()
```

### 6. Debugging Checklist

**When pipeline fails:**
- [ ] Check service health status
- [ ] Review full pipeline logs
- [ ] Check for recent Azure DevOps changes
- [ ] Verify service connections are valid
- [ ] Check agent pool availability
- [ ] Review variable values
- [ ] Test tasks individually
- [ ] Check for environmental differences
- [ ] Review timeline for dependencies
- [ ] Verify repository access
- [ ] Check artifact storage
- [ ] Review recent code changes

### 7. Prevention Strategies

**Avoid common issues:**
```yaml
# 1. Use specific task versions
- task: NodeTool@0
  inputs:
    versionSpec: '16.x'  # Specify version

# 2. Validate before running
- script: |
    # Pre-flight checks
    command -v node || exit 1
    command -v npm || exit 1
    [ -f package.json ] || exit 1
  displayName: 'Validate environment'

# 3. Fail fast
- script: |
    set -e  # Exit on any error
    npm ci
    npm test
  displayName: 'Build with fail-fast'

# 4. Add health checks
- script: |
    # Verify deployment
    curl --fail http://app/health || exit 1
  displayName: 'Health check'
  retryCountOnTaskFailure: 3
```

### 8. Troubleshooting Tools

**Azure DevOps CLI:**
```bash
# Get pipeline logs
az pipelines runs show --id <run-id> --open

# List failed runs
az pipelines runs list --status failed --top 5

# Show task logs
az pipelines runs show --id <run-id> --query "logs"
```

**REST API:**
```bash
# Get build details
curl -u :$PAT "https://dev.azure.com/{org}/{project}/_apis/build/builds/{buildId}?api-version=7.0"

# Get timeline (detailed task info)
curl -u :$PAT "https://dev.azure.com/{org}/{project}/_apis/build/builds/{buildId}/timeline?api-version=7.0"
```

## Output

Provide:
1. Root cause analysis of the failure
2. Detailed error explanation
3. Step-by-step fix with updated YAML
4. Verification commands to test fix
5. Prevention recommendations
6. Monitoring suggestions
7. Documentation of the issue and resolution
8. Related issues to watch for
