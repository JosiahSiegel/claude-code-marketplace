---
description: Implement quality gates and code quality enforcement in Azure Pipelines
---

## 🚨 CRITICAL GUIDELINES

### Windows File Path Requirements

**MANDATORY: Always Use Backslashes on Windows for File Paths**

When using Edit or Write tools on Windows, you MUST use backslashes (`\`) in file paths, NOT forward slashes (`/`).

**Examples:**
- ❌ WRONG: `C:/projects/file.yml`
- ✅ CORRECT: `C:\projects\file.yml`

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

# Quality Gates and Code Quality Enforcement

## Purpose

Implement automated quality gates in Azure Pipelines to enforce code quality standards, prevent defects, and maintain high code health. Integrate SonarQube, code coverage requirements, and policy enforcement.

## Quality Gate Components

### 1. Code Coverage Requirements

**Enforce minimum coverage:**
```yaml
stages:
  - stage: Test
    jobs:
      - job: UnitTests
        steps:
          - task: DotNetCoreCLI@2
            displayName: 'Run tests with coverage'
            inputs:
              command: 'test'
              arguments: '--collect:"XPlat Code Coverage" --logger trx'
              publishTestResults: true

          - task: PublishCodeCoverageResults@1
            displayName: 'Publish coverage'
            inputs:
              codeCoverageTool: 'Cobertura'
              summaryFileLocation: '$(Agent.TempDirectory)/**/coverage.cobertura.xml'

          - script: |
              # Extract coverage percentage
              COVERAGE=$(xmllint --xpath "string(//coverage/@line-rate)" coverage.cobertura.xml)
              COVERAGE_PCT=$(echo "$COVERAGE * 100" | bc)
              THRESHOLD=80

              echo "Code coverage: ${COVERAGE_PCT}%"

              if (( $(echo "$COVERAGE_PCT < $THRESHOLD" | bc -l) )); then
                echo "##vso[task.logissue type=error]Code coverage ${COVERAGE_PCT}% is below threshold ${THRESHOLD}%"
                exit 1
              fi
            displayName: 'Enforce coverage threshold'
```

### 2. SonarQube Integration

**Complete SonarQube workflow:**
```yaml
variables:
  - name: sonarQubeConnection
    value: 'sonarqube-connection'
  - name: sonarProjectKey
    value: 'my-project'

stages:
  - stage: QualityGate
    displayName: 'Code Quality Analysis'
    jobs:
      - job: SonarAnalysis
        pool:
          vmImage: 'ubuntu-24.04'
        steps:
          # Prepare SonarQube analysis
          - task: SonarQubePrepare@5
            displayName: 'Prepare SonarQube'
            inputs:
              SonarQube: $(sonarQubeConnection)
              scannerMode: 'MSBuild'
              projectKey: $(sonarProjectKey)
              projectName: 'My Project'
              projectVersion: '$(Build.BuildNumber)'
              extraProperties: |
                sonar.exclusions=**/bin/**,**/obj/**,**/node_modules/**
                sonar.coverage.exclusions=**/*.Tests/**,**/*Test.cs
                sonar.cs.opencover.reportsPaths=$(Agent.TempDirectory)/**/coverage.opencover.xml

          # Build application
          - task: DotNetCoreCLI@2
            displayName: 'Build'
            inputs:
              command: 'build'
              projects: '**/*.csproj'
              arguments: '--configuration Release'

          # Run tests with coverage
          - task: DotNetCoreCLI@2
            displayName: 'Test'
            inputs:
              command: 'test'
              projects: '**/*Tests.csproj'
              arguments: '--configuration Release --collect:"XPlat Code Coverage" -- DataCollectionRunSettings.DataCollectors.DataCollector.Configuration.Format=opencover'

          # Run SonarQube analysis
          - task: SonarQubeAnalyze@5
            displayName: 'Run SonarQube Analysis'

          # Publish quality gate result
          - task: SonarQubePublish@5
            displayName: 'Publish Quality Gate Result'
            inputs:
              pollingTimeoutSec: '300'

          # Break build on quality gate failure
          - script: |
              # Check quality gate status
              STATUS=$(curl -u $(SONAR_TOKEN): \
                "$(SONAR_HOST_URL)/api/qualitygates/project_status?projectKey=$(sonarProjectKey)" | \
                jq -r '.projectStatus.status')

              if [ "$STATUS" != "OK" ]; then
                echo "##vso[task.logissue type=error]SonarQube Quality Gate failed"
                exit 1
              fi
            displayName: 'Enforce Quality Gate'
            env:
              SONAR_TOKEN: $(sonarToken)
              SONAR_HOST_URL: $(sonarHostUrl)
```

**SonarCloud alternative:**
```yaml
- task: SonarCloudPrepare@1
  displayName: 'Prepare SonarCloud'
  inputs:
    SonarCloud: 'sonarcloud-connection'
    organization: 'my-org'
    scannerMode: 'MSBuild'
    projectKey: 'my-project'
    projectName: 'My Project'

- task: DotNetCoreCLI@2
  displayName: 'Build and test'
  inputs:
    command: 'test'

- task: SonarCloudAnalyze@1
  displayName: 'Run Analysis'

- task: SonarCloudPublish@1
  displayName: 'Publish Quality Gate'
  inputs:
    pollingTimeoutSec: '300'
```

### 3. Linting and Static Analysis

**Multi-language linting:**
```yaml
jobs:
  - job: Lint
    displayName: 'Linting and Static Analysis'
    steps:
      # JavaScript/TypeScript
      - script: |
          npm install
          npm run lint
        displayName: 'ESLint'
        condition: contains(variables['Build.SourcesDirectory'], 'package.json')

      # Python
      - script: |
          pip install flake8 pylint black
          flake8 . --max-line-length=120
          pylint **/*.py --fail-under=8.0
          black --check .
        displayName: 'Python linting'
        condition: contains(variables['Build.SourcesDirectory'], 'setup.py')

      # C#
      - task: DotNetCoreCLI@2
        displayName: 'dotnet format'
        inputs:
          command: 'custom'
          custom: 'format'
          arguments: '--verify-no-changes'

      # Go
      - script: |
          go install golang.org/x/lint/golint@latest
          golint -set_exit_status ./...
          go vet ./...
        displayName: 'Go linting'
        condition: contains(variables['Build.SourcesDirectory'], 'go.mod')
```

### 4. Security Quality Gates

**Security scan enforcement:**
```yaml
- task: MicrosoftSecurityDevOps@1
  displayName: 'Security scan'
  inputs:
    categories: 'secrets,code,dependencies'
    break: true
    breakSeverity: 'high'

# Only proceed if security scan passes
- deployment: Deploy
  dependsOn: SecurityScan
  condition: succeeded()
  environment: 'production'
```

### 5. Build Quality Checks

**Comprehensive build validation:**
```yaml
stages:
  - stage: QualityChecks
    displayName: 'Quality Validation'
    jobs:
      - job: BuildQuality
        steps:
          # Check for compiler warnings
          - task: DotNetCoreCLI@2
            displayName: 'Build with warnings as errors'
            inputs:
              command: 'build'
              arguments: '/p:TreatWarningsAsErrors=true'

          # Check for TODO/FIXME comments
          - script: |
              TODO_COUNT=$(grep -r "TODO\|FIXME" --include="*.cs" --include="*.js" | wc -l)
              if [ $TODO_COUNT -gt 10 ]; then
                echo "##vso[task.logissue type=warning]Found $TODO_COUNT TODO/FIXME comments"
              fi
            displayName: 'Check code comments'

          # Dependency vulnerabilities
          - script: |
              dotnet list package --vulnerable --include-transitive
            displayName: 'Check vulnerable packages'
```

## Policy Enforcement

### Branch Policy Integration

**Required build validation:**
```yaml
# azure-pipelines-pr.yml
trigger: none

pr:
  branches:
    include:
      - main
      - develop

stages:
  - stage: PRValidation
    displayName: 'Pull Request Validation'
    jobs:
      # All quality gates must pass
      - job: Lint
        steps:
          - script: npm run lint
            displayName: 'Linting'

      - job: Test
        steps:
          - script: npm test -- --coverage
            displayName: 'Tests with coverage'

      - job: Security
        steps:
          - task: MicrosoftSecurityDevOps@1
            inputs:
              break: true

      - job: QualityGate
        dependsOn:
          - Lint
          - Test
          - Security
        condition: succeeded()
        steps:
          - script: echo "All quality gates passed"
```

**Configure in Azure DevOps UI:**
1. Project Settings → Repositories → Select repository
2. Policies → Branch policies → main branch
3. Build validation → Add build policy
4. Select PR validation pipeline
5. Check "Required" to block merge on failure

### Environment Gates

**Pre-deployment quality validation:**
```yaml
- stage: DeployProduction
  dependsOn: QualityGate
  condition: succeeded()
  jobs:
    - deployment: Deploy
      environment: 'production'  # Configure checks in UI
      strategy:
        runOnce:
          deploy:
            steps:
              - script: echo "Deploying"
```

**Configure environment checks in UI:**
1. Environments → Select environment → Approvals and checks
2. Add check → Invoke Azure Function
3. Function checks quality metrics before approval

## Quality Metrics Dashboard

**Track quality trends:**
```yaml
- script: |
    # Export quality metrics
    cat > $(Build.ArtifactStagingDirectory)/quality-metrics.json <<EOF
    {
      "buildNumber": "$(Build.BuildNumber)",
      "coverage": "${COVERAGE_PCT}",
      "qualityGate": "${QUALITY_GATE_STATUS}",
      "vulnerabilities": ${VULN_COUNT},
      "testsPassed": ${TESTS_PASSED},
      "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    }
    EOF
  displayName: 'Export quality metrics'

- task: PublishBuildArtifacts@1
  inputs:
    pathToPublish: '$(Build.ArtifactStagingDirectory)/quality-metrics.json'
    artifactName: 'quality-metrics'
```

## Custom Quality Gates

**Build custom validation:**
```yaml
- script: |
    # Custom quality gate logic
    COVERAGE=$(get_coverage)
    COMPLEXITY=$(calculate_complexity)
    DEBT_RATIO=$(calculate_tech_debt)

    PASSED=true

    if [ $COVERAGE -lt 80 ]; then
      echo "##vso[task.logissue type=error]Coverage below 80%"
      PASSED=false
    fi

    if [ $COMPLEXITY -gt 15 ]; then
      echo "##vso[task.logissue type=error]Complexity too high"
      PASSED=false
    fi

    if [ $DEBT_RATIO -gt 5 ]; then
      echo "##vso[task.logissue type=warning]Technical debt ratio high"
    fi

    if [ "$PASSED" = false ]; then
      exit 1
    fi
  displayName: 'Custom quality gate'
```

## Quality Gate Templates

**Reusable quality gate:**
```yaml
# templates/quality-gate.yml
parameters:
  - name: coverageThreshold
    type: number
    default: 80
  - name: breakOnFailure
    type: boolean
    default: true

steps:
  - task: SonarQubePrepare@5
    inputs:
      SonarQube: 'sonarqube'

  - task: DotNetCoreCLI@2
    inputs:
      command: 'test'
      arguments: '--collect:"XPlat Code Coverage"'

  - task: SonarQubeAnalyze@5

  - task: SonarQubePublish@5
    inputs:
      pollingTimeoutSec: '300'

  - script: |
      COVERAGE=$(extract_coverage)
      if [ $COVERAGE -lt ${{ parameters.coverageThreshold }} ]; then
        echo "##vso[task.logissue type=error]Coverage failed"
        ${{ if parameters.breakOnFailure }}:
          exit 1
      fi
    displayName: 'Enforce quality standards'
```

**Use template:**
```yaml
stages:
  - stage: Quality
    jobs:
      - job: QualityCheck
        steps:
          - template: templates/quality-gate.yml
            parameters:
              coverageThreshold: 85
              breakOnFailure: true
```

## Best Practices

**Quality gate strategy:**
1. Start lenient, tighten gradually
2. Different thresholds for main vs branches
3. Warn before blocking
4. Provide clear remediation guidance
5. Track trends over time

**Recommended thresholds:**
- Code coverage: 80% minimum, 90% target
- Complexity: Cyclomatic complexity < 15
- Maintainability: Maintainability index > 70
- Duplications: < 3% duplicated lines
- Security: Zero critical/high vulnerabilities

**Quality gate matrix:**

| Metric | Warning | Error |
|--------|---------|-------|
| Coverage | < 85% | < 80% |
| Bugs | > 0 | N/A (fail on any) |
| Vulnerabilities | High | Critical |
| Code smells | > 10 | > 50 |
| Duplication | > 3% | > 5% |
| Complexity | > 12 | > 15 |

## Reporting

**Generate quality report:**
```yaml
- script: |
    cat > quality-report.md <<EOF
    # Quality Report - Build $(Build.BuildNumber)

    ## Metrics
    - Coverage: ${COVERAGE}%
    - Quality Gate: ${STATUS}
    - Test Results: ${TESTS_PASSED}/${TESTS_TOTAL}
    - Vulnerabilities: ${VULN_COUNT}

    ## Trends
    $(generate_trend_data)
    EOF

- task: PublishBuildArtifacts@1
  inputs:
    pathToPublish: 'quality-report.md'
    artifactName: 'quality-report'
```

## Integration with Azure Boards

**Link quality to work items:**
```yaml
- script: |
    # Comment quality gate result on work items
    az boards work-item update \
      --id $(System.WorkItemId) \
      --discussion "Quality Gate: ${STATUS}, Coverage: ${COVERAGE}%"
  env:
    AZURE_DEVOPS_EXT_PAT: $(System.AccessToken)
```

## Resources

- [SonarQube Integration](https://learn.microsoft.com/azure/devops/pipelines/ecosystems/sonarqube)
- [Code Coverage](https://learn.microsoft.com/azure/devops/pipelines/ecosystems/dotnet-core#collect-code-coverage)
- [Branch Policies](https://learn.microsoft.com/azure/devops/repos/git/branch-policies)
- [Environment Checks](https://learn.microsoft.com/azure/devops/pipelines/process/approvals)

## Summary

Quality gates ensure code meets standards before merging or deployment. Implement automated validation for coverage, complexity, security, and style. Enforce policies through branch protection and environment checks. Track trends to maintain and improve code health over time.
