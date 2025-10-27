---
description: Optimize Azure DevOps pipelines for performance, cost, and efficiency
---

# Optimize Azure DevOps Pipeline

## Purpose
Analyze and optimize existing Azure DevOps pipelines for better performance, reduced costs, and improved efficiency following current best practices.

## Before Optimizing

**Research current optimization strategies:**
1. Check latest Azure Pipelines performance best practices
2. Review current agent pool recommendations
3. Check for new caching strategies
4. Review task version updates and improvements
5. Check Azure DevOps pricing and cost optimization guides

## Optimization Analysis Process

### 1. Baseline Assessment

**Gather current metrics:**
```bash
# Using Azure DevOps CLI
az pipelines runs list --pipeline-id <id> --top 20 --query "[].{id:id, result:result, finishTime:finishTime, queueTime:queueTime}"

# Calculate average duration
az pipelines runs list --pipeline-id <id> --query "avg([].durationInSeconds)"
```

**Identify bottlenecks:**
- Long-running jobs or stages
- Sequential dependencies that could be parallel
- Expensive tasks (time or cost)
- Inefficient resource usage
- Redundant operations

### 2. Performance Optimization Strategies

#### A. Parallelize Jobs

**Before (Sequential):**
```yaml
stages:
  - stage: Test
    jobs:
      - job: UnitTests
        steps:
          - script: npm test:unit
      - job: IntegrationTests
        dependsOn: UnitTests  # Unnecessary dependency
        steps:
          - script: npm test:integration
```

**After (Parallel):**
```yaml
stages:
  - stage: Test
    jobs:
      - job: UnitTests
        steps:
          - script: npm test:unit

      - job: IntegrationTests
        # No dependsOn - runs in parallel
        steps:
          - script: npm test:integration
```

#### B. Use Caching

**npm/yarn Caching:**
```yaml
- task: Cache@2
  displayName: 'Cache npm packages'
  inputs:
    key: 'npm | "$(Agent.OS)" | package-lock.json'
    restoreKeys: |
      npm | "$(Agent.OS)"
    path: '$(npm_config_cache)'

- script: npm ci
  displayName: 'Install dependencies'
```

**NuGet Caching:**
```yaml
- task: Cache@2
  inputs:
    key: 'nuget | "$(Agent.OS)" | **/packages.lock.json'
    restoreKeys: |
      nuget | "$(Agent.OS)"
    path: '$(NUGET_PACKAGES)'

- task: NuGetCommand@2
  inputs:
    command: 'restore'
```

**Maven/Gradle Caching:**
```yaml
- task: Cache@2
  inputs:
    key: 'maven | "$(Agent.OS)" | **/pom.xml'
    restoreKeys: |
      maven | "$(Agent.OS)"
    path: '$(MAVEN_CACHE_FOLDER)'
```

**Docker Layer Caching:**
```yaml
- task: Docker@2
  displayName: 'Build with cache'
  inputs:
    command: 'build'
    arguments: '--cache-from $(imageRepository):latest --build-arg BUILDKIT_INLINE_CACHE=1'
```

#### C. Optimize Agent Selection

**Use appropriate agent pools:**
```yaml
# For Linux workloads
pool:
  vmImage: 'ubuntu-24.04'  # Recommended for 2025 - fast startup

# For specific capabilities
pool:
  name: 'Default'  # Self-hosted with specific tools
  demands:
    - agent.os -equals Linux
    - docker
```

**Scale-set agents for cost efficiency:**
```yaml
pool:
  name: 'azure-vmss-pool'  # Auto-scaling
  demands:
    - ImageOverride -equals ubuntu-20.04
```

#### D. Reduce Checkout Time

**Shallow clone:**
```yaml
steps:
  - checkout: self
    fetchDepth: 1  # Only fetch latest commit
    clean: true
```

**Sparse checkout (specific paths):**
```yaml
steps:
  - checkout: self
    fetchDepth: 1
    path: 's'
    # Configure sparse checkout if needed
```

**Skip checkout when not needed:**
```yaml
steps:
  - checkout: none  # For jobs that don't need source
```

#### E. Optimize Task Execution

**Combine commands:**
```yaml
# Before
- script: npm install
- script: npm run lint
- script: npm test
- script: npm run build

# After
- script: |
    npm ci
    npm run lint
    npm test
    npm run build
  displayName: 'Build and test'
```

**Use task conditions wisely:**
```yaml
- task: PublishTestResults@2
  condition: succeededOrFailed()  # Run even if tests fail
  inputs:
    testResultsFiles: '**/test-results.xml'

- script: npm run deploy
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
```

### 3. Cost Optimization

#### A. Parallel Job Limits

**Optimize concurrent jobs:**
```yaml
# Limit matrix strategy
strategy:
  matrix:
    node14:
      nodeVersion: '14.x'
    node16:
      nodeVersion: '16.x'
    node18:
      nodeVersion: '18.x'
  maxParallel: 2  # Balance speed vs cost
```

#### B. Self-Hosted Agents

**When to use self-hosted:**
- Frequent builds (saves Microsoft-hosted costs)
- Special tool requirements
- Compliance/security requirements
- Access to internal resources

**Setup:**
```yaml
pool:
  name: 'self-hosted-pool'
  demands:
    - docker
    - kubectl
```

#### C. Artifact Retention

**Optimize storage costs:**
```yaml
# In Azure DevOps UI
# Project Settings → Pipelines → Settings → Retention
# Set appropriate retention days (default: 30 days)

# For specific runs, use retention leases
- task: UpdateBuildNumber@1
  inputs:
    buildNumber: '$(Build.BuildNumber)'
    retainBuild: true  # Keep this build
```

#### D. Pipeline Run Frequency

**Optimize triggers:**
```yaml
# Instead of every commit
trigger:
  batch: true  # Batch commits
  branches:
    include:
      - main

# Path filters
trigger:
  paths:
    include:
      - src/*
    exclude:
      - docs/*
      - '**/*.md'

# Scheduled builds instead of continuous
schedules:
  - cron: '0 2 * * *'  # Once daily at 2 AM
    displayName: 'Nightly build'
    branches:
      include:
        - main
```

### 4. Build Efficiency

#### A. Incremental Builds

```yaml
# For .NET
- task: DotNetCoreCLI@2
  inputs:
    command: 'build'
    arguments: '--no-restore'  # Skip if restore already done

# For TypeScript
- script: npx tsc --incremental
```

#### B. Skip Redundant Steps

```yaml
- script: npm run lint
  condition: ne(variables['Build.Reason'], 'PullRequest')  # Skip on PR if done elsewhere

- script: npm run e2e
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))  # Only on main
```

#### C. Early Termination

```yaml
# Fail fast on critical errors
- script: npm run lint
  displayName: 'Lint code'
  # Pipeline stops here if linting fails

- script: npm test
  displayName: 'Run tests'
  continueOnError: false  # Stop on test failure
```

### 5. Resource Optimization

#### A. Job Timeout Settings

```yaml
jobs:
  - job: Build
    timeoutInMinutes: 30  # Prevent runaway jobs
    cancelTimeoutInMinutes: 5
    steps:
      # Build steps
```

#### B. Agent Pool Strategy

```yaml
# Use cheaper agent for simple tasks
- stage: Lint
  pool:
    vmImage: 'ubuntu-24.04'  # Linux agents are more cost-effective
  jobs:
    - job: Linting
      steps:
        - script: npm run lint

# Use powerful agent only when needed
- stage: Build
  pool:
    vmImage: 'windows-latest'  # Only if Windows required
  jobs:
    - job: WindowsBuild
      steps:
        - script: msbuild
```

### 6. Optimization Metrics

**Key Performance Indicators:**
- **Pipeline duration:** Total time from queue to completion
- **Wait time:** Time waiting for agent
- **Task duration:** Individual task execution time
- **Agent cost:** Cost per pipeline run
- **Success rate:** Percentage of successful runs
- **Artifact size:** Storage costs

**Monitoring:**
```bash
# Get pipeline analytics
az pipelines runs list --pipeline-id <id> --query "[].{duration:durationInSeconds, status:status}"

# Check agent pool usage
az pipelines pool list --query "[].{name:name, size:size}"
```

### 7. Advanced Optimization Techniques

#### A. Matrix Build Optimization

```yaml
strategy:
  matrix:
    ${{ if eq(variables['Build.SourceBranch'], 'refs/heads/main') }}:
      # Full matrix on main
      linux_python38:
        imageName: 'ubuntu-latest'
        pythonVersion: '3.8'
      linux_python39:
        imageName: 'ubuntu-latest'
        pythonVersion: '3.9'
      windows_python38:
        imageName: 'windows-latest'
        pythonVersion: '3.8'
    ${{ else }}:
      # Reduced matrix on branches
      linux_python39:
        imageName: 'ubuntu-latest'
        pythonVersion: '3.9'
```

#### B. Template Optimization

**Create reusable, efficient templates:**
```yaml
# templates/optimized-build.yml
parameters:
  - name: useCache
    type: boolean
    default: true

steps:
  - ${{ if parameters.useCache }}:
    - task: Cache@2
      inputs:
        key: 'deps | "$(Agent.OS)" | package.json'
        path: '$(System.DefaultWorkingDirectory)/node_modules'

  - script: npm ci
    condition: ne(variables['CacheRestored'], 'true')
```

#### C. Conditional Stages

```yaml
stages:
  - stage: Build
    # Always run

  - stage: SecurityScan
    condition: or(eq(variables['Build.SourceBranch'], 'refs/heads/main'), eq(variables['Build.Reason'], 'Schedule'))
    # Only on main or scheduled

  - stage: PerformanceTest
    condition: eq(variables['Build.Reason'], 'Schedule')
    # Only on scheduled runs
```

### 8. Optimization Checklist

**Performance:**
- [ ] Jobs run in parallel where possible
- [ ] Caching implemented for dependencies
- [ ] Shallow git clone (fetchDepth: 1)
- [ ] Agent pool optimized for workload
- [ ] Task versions are latest
- [ ] Unnecessary tasks removed
- [ ] Early termination on failures

**Cost:**
- [ ] Self-hosted agents considered
- [ ] Parallel job limits set appropriately
- [ ] Artifact retention policy configured
- [ ] Triggers optimized (batch, path filters)
- [ ] Matrix builds limited on branches
- [ ] Scheduled builds instead of continuous
- [ ] Job timeouts set

**Efficiency:**
- [ ] Incremental builds enabled
- [ ] Redundant steps eliminated
- [ ] Templates reused
- [ ] Conditions used appropriately
- [ ] Workspace cleanup configured

### 9. Before/After Comparison

**Document improvements:**
```markdown
## Pipeline Optimization Results

### Before
- Duration: 45 minutes
- Parallel jobs: 2
- Cache: Not used
- Agent: windows-latest for all jobs
- Cost per run: ~$1.50

### After
- Duration: 18 minutes (60% faster)
- Parallel jobs: 5
- Cache: npm, NuGet, Docker layers
- Agent: ubuntu-latest (Linux jobs), windows-latest (Windows-specific only)
- Cost per run: ~$0.60 (60% reduction)

### Changes Made
1. Parallelized independent test jobs
2. Implemented multi-level caching
3. Switched to Linux agents where possible
4. Added path filters to triggers
5. Optimized checkout with shallow clone
```

### 10. Continuous Optimization

**Regular reviews:**
- Monthly pipeline duration analysis
- Quarterly cost analysis
- Review new Azure DevOps features
- Update task versions
- Monitor agent pool performance
- Review and update caching strategies

**Automation:**
```yaml
# Pipeline to analyze other pipelines
schedules:
  - cron: '0 0 1 * *'  # First of every month
    displayName: 'Monthly pipeline analysis'
    branches:
      include:
        - main

steps:
  - task: AzureCLI@2
    inputs:
      azureSubscription: 'service-connection'
      scriptType: 'bash'
      scriptLocation: 'inlineScript'
      inlineScript: |
        # Generate pipeline performance report
        az pipelines runs list --output table
        # Analyze and send report
```

## Output

Provide:
1. Current pipeline analysis with bottlenecks identified
2. Optimized YAML with changes highlighted
3. Expected performance improvements (time, cost)
4. Before/after metrics comparison
5. Implementation plan with priorities
6. Monitoring recommendations
7. Documentation of changes made
8. Additional optimization opportunities for future
