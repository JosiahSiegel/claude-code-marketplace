---
description: Secure Azure DevOps pipelines following security best practices and compliance standards
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

# Secure Azure DevOps Pipeline

## Purpose
Implement security best practices in Azure DevOps pipelines, including secrets management, code scanning, compliance, and secure deployment strategies.

## Before Securing

**Research current security standards:**
1. Latest Azure DevOps security best practices (2025)
2. Microsoft Defender for DevOps capabilities
3. Microsoft Security DevOps (MSDO) extension
4. GitHub Advanced Security for Azure DevOps
5. OWASP CI/CD security guidelines
6. Compliance requirements (SOC 2, ISO 27001, etc.)

**Key resources:**
- https://learn.microsoft.com/azure/devops/pipelines/security/overview
- https://learn.microsoft.com/azure/defender-for-cloud/azure-devops-extension
- https://learn.microsoft.com/azure/devops/pipelines/security/secrets
- https://learn.microsoft.com/azure/devops/pipelines/library/connect-to-azure (Workload Identity)

## Security Assessment Process

### 1. Security Audit Checklist

**Pipeline Security:**
- [ ] No hardcoded secrets or credentials
- [ ] Service connections use managed identities
- [ ] Pipeline permissions follow least privilege
- [ ] Branch protection policies enabled
- [ ] Required reviewers configured
- [ ] Build validation required
- [ ] No direct access to production from pipelines

**Code Security:**
- [ ] Static Application Security Testing (SAST) implemented
- [ ] Dependency scanning enabled
- [ ] Secret scanning configured
- [ ] Code signing for artifacts
- [ ] Container image scanning

**Access Control:**
- [ ] Pipeline permissions restricted
- [ ] Variable groups protected
- [ ] Service connections scoped appropriately
- [ ] Agent pools secured
- [ ] Approval gates configured

### 2. Secrets Management

#### A. Never Hardcode Secrets

**BAD:**
```yaml
# NEVER DO THIS
variables:
  apiKey: 'hardcoded-secret-123'
  connectionString: 'Server=myserver;Database=mydb;Password=password123'
```

**GOOD - Use Variable Groups:**
```yaml
variables:
  - group: 'prod-secrets'  # Linked to Azure Key Vault

steps:
  - script: |
      echo "Using secret from Key Vault"
      # Secret is available as $(secretName)
    env:
      API_KEY: $(apiKey)
```

#### B. Azure Key Vault Integration

**Setup:**
1. Create Azure Key Vault
2. Add secrets to Key Vault
3. Link Variable Group to Key Vault
4. Grant pipeline service principal access

**Usage:**
```yaml
variables:
  - group: 'keyvault-secrets'  # Auto-synced from Key Vault

steps:
  - task: AzureKeyVault@2
    displayName: 'Get secrets from Key Vault'
    inputs:
      azureSubscription: 'service-connection'
      KeyVaultName: 'my-keyvault'
      SecretsFilter: '*'
      RunAsPreJob: true

  - script: |
      # Secrets now available as pipeline variables
      echo "Deploying with secret"
    env:
      DB_PASSWORD: $(database-password)
```

#### C. Secret Variables

**In pipeline:**
```yaml
variables:
  - name: apiToken
    value: ''  # Set in UI as secret variable

steps:
  - script: |
      curl -H "Authorization: Bearer $(apiToken)" https://api.example.com
    displayName: 'API call with secret token'
```

**Secret detection in logs:**
```yaml
steps:
  - script: |
      # ADO automatically masks secret variables in logs
      echo "Token: $(apiToken)"  # Shows "Token: ***"
```

### 3. Service Connection Security

**Principles:**
- **Prefer workload identity federation** (OIDC) over secrets
- Use managed identities over service principals where possible
- Scope connections to specific pipelines
- Avoid long-lived credentials
- Regular credential rotation for service principals
- Audit access logs

#### A. Workload Identity Federation (OIDC) - Recommended

**Best practice for 2025:** Use OpenID Connect (OIDC) for passwordless authentication to Azure.

**Setup:**
1. Create service connection with workload identity federation in Azure DevOps UI
2. No secrets stored in Azure DevOps
3. Azure DevOps issues tokens automatically

**Usage:**
```yaml
steps:
  - task: AzureCLI@2
    inputs:
      azureSubscription: 'production-connection-oidc'  # Workload identity federation enabled
      scriptType: 'bash'
      scriptLocation: 'inlineScript'
      inlineScript: |
        # Automatic OIDC authentication - no secrets!
        az account show
        az group list
```

**Benefits:**
- No secrets to manage or rotate
- Tokens are short-lived and automatically refreshed
- Reduced attack surface
- Meets zero-trust requirements
- Microsoft recommended approach

#### B. Managed Identity (For Azure-hosted agents)

```yaml
pool:
  name: 'azure-vm-pool'  # Self-hosted agents on Azure VMs

steps:
  - task: AzureCLI@2
    inputs:
      azureSubscription: 'managed-identity-connection'
      scriptType: 'bash'
      scriptLocation: 'inlineScript'
      useGlobalConfig: true
      inlineScript: |
        # Uses VM's managed identity
        az account show
```

#### C. Service Principal (Legacy - Avoid if possible)

**Only use if OIDC/Managed Identity unavailable:**
```yaml
steps:
  - task: AzureCLI@2
    inputs:
      azureSubscription: 'production-connection'  # Service principal with secret
      scriptType: 'bash'
      scriptLocation: 'inlineScript'
      addSpnToEnvironment: true
      inlineScript: |
        # Service principal added to environment
        # Credentials not exposed in logs
        az account show

# Rotate credentials every 90 days
# Use Azure Key Vault for secret storage
```

### 4. Code Security Scanning (2025 - Microsoft Security DevOps)

#### A. Microsoft Security DevOps Extension (Recommended)

**Replaces legacy tools:** CredScan deprecated September 2023. Use MSDO extension for comprehensive security scanning.

**Install:** Azure DevOps Marketplace → Microsoft Security DevOps

**Complete Security Scan:**
```yaml
steps:
  # Build application first
  - task: DotNetCoreCLI@2
    displayName: 'Build Application'
    inputs:
      command: 'build'
      projects: '**/*.csproj'

  # Comprehensive security scanning
  - task: MicrosoftSecurityDevOps@1
    displayName: 'Microsoft Security DevOps'
    inputs:
      categories: 'secrets,code,dependencies,IaC,containers'
      break: true  # Fail pipeline on critical/high findings
      breakSeverity: 'high'
      publishResults: true

  # Publish SARIF results
  - task: PublishSecurityAnalysisLogs@3
    displayName: 'Publish Security Logs'
    inputs:
      ArtifactName: 'CodeAnalysisLogs'

  # Display in Scans tab
  - task: PostAnalysis@2
    displayName: 'Post Analysis'
    inputs:
      break: true

# View results: Pipeline run → Scans tab
```

**What MSDO Scans:**
- **Secrets:** API keys, tokens, credentials (replaces CredScan)
- **Code:** Static analysis (SAST) for vulnerabilities
- **Dependencies:** Known CVEs in packages
- **IaC:** Terraform, ARM, Bicep security issues
- **Containers:** Image vulnerabilities with Trivy

#### B. GitHub Advanced Security for Azure DevOps

**Alternative/Complement to MSDO:**

Provides:
- Secret scanning with GitHub's detection engine
- CodeQL for advanced code analysis
- Dependency vulnerability alerts
- Security overview dashboard

**Note:** Requires GitHub Advanced Security license

#### C. Alternative Security Tools
    displayName: 'Anti-Malware Scan'

  - task: BinSkim@4
    displayName: 'BinSkim Binary Analyzer'
    inputs:
      InputType: 'Basic'
      Function: 'analyze'

  - task: PublishSecurityAnalysisLogs@3
    displayName: 'Publish Security Analysis Logs'

  - task: PostAnalysis@2
    displayName: 'Post Analysis'
    inputs:
      AllTools: true
      BinSkim: true
      CredScan: true
      ToolLogsNotFoundAction: 'Error'
```

**SonarQube Integration:**
```yaml
steps:
  - task: SonarQubePrepare@5
    displayName: 'Prepare SonarQube'
    inputs:
      SonarQube: 'sonarqube-connection'
      scannerMode: 'MSBuild'
      projectKey: 'my-project'

  - task: DotNetCoreCLI@2
    displayName: 'Build'
    inputs:
      command: 'build'

  - task: SonarQubeAnalyze@5
    displayName: 'Run SonarQube Analysis'

  - task: SonarQubePublish@5
    displayName: 'Publish Quality Gate'
    inputs:
      pollingTimeoutSec: '300'
```

#### B. Dependency Scanning

**OWASP Dependency Check:**
```yaml
steps:
  - task: dependency-check-build-task@6
    displayName: 'OWASP Dependency Check'
    inputs:
      projectName: 'my-application'
      scanPath: '$(Build.SourcesDirectory)'
      format: 'HTML,JSON'
      failOnCVSS: '7'  # Fail if critical/high vulnerabilities

  - task: PublishBuildArtifacts@1
    inputs:
      pathToPublish: '$(Common.TestResultsDirectory)'
      artifactName: 'dependency-check-report'
```

**WhiteSource Bolt:**
```yaml
steps:
  - task: WhiteSource@21
    displayName: 'WhiteSource Scan'
    inputs:
      cwd: '$(System.DefaultWorkingDirectory)'
      projectName: 'my-project'
```

**npm audit:**
```yaml
steps:
  - script: |
      npm audit --audit-level=high
      if [ $? -ne 0 ]; then
        echo "##vso[task.logissue type=error]High or critical vulnerabilities found"
        exit 1
      fi
    displayName: 'npm Security Audit'
```

#### C. Container Image Scanning

**Trivy Scan:**
```yaml
steps:
  - task: Docker@2
    displayName: 'Build Docker Image'
    inputs:
      command: 'build'
      repository: 'myapp'
      tags: '$(Build.BuildId)'

  - script: |
      docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
        aquasec/trivy image \
        --severity HIGH,CRITICAL \
        --exit-code 1 \
        myapp:$(Build.BuildId)
    displayName: 'Scan Image with Trivy'

  - task: Docker@2
    displayName: 'Push Image'
    condition: succeeded()
    inputs:
      command: 'push'
```

**Azure Container Registry Scan:**
```yaml
steps:
  - task: AzureCLI@2
    displayName: 'Scan ACR Image'
    inputs:
      azureSubscription: 'service-connection'
      scriptType: 'bash'
      scriptLocation: 'inlineScript'
      inlineScript: |
        az acr task run \
          --registry myregistry \
          --name security-scan \
          --image myapp:$(Build.BuildId)
```

### 5. Pipeline Permissions

#### A. Least Privilege Access

**Repository permissions:**
```yaml
# In azure-pipelines.yml
resources:
  repositories:
    - repository: templates
      type: git
      name: shared/templates
      ref: refs/heads/main
      # Only grant read access to pipeline
```

**Variable group permissions:**
- Restrict variable group access by pipeline
- Use separate groups for dev/staging/prod
- Limit who can add/modify variables

**Service connection permissions:**
```yaml
# In ADO UI: Project Settings → Service Connections
# → Select connection → Security
# Grant access to specific pipelines only
```

#### B. Branch Protection

**Configure in ADO:**
1. Branch Policies for main/production branches
2. Require pull request reviews
3. Build validation (pipeline must pass)
4. Status checks required
5. Limit who can push directly

**Pipeline enforcement:**
```yaml
trigger:
  branches:
    include:
      - main
    exclude:
      - feature/*  # Don't auto-trigger on feature branches

# Require manual approval for production
- stage: Production
  dependsOn: Staging
  condition: succeeded()
  jobs:
    - deployment: DeployProd
      environment: 'production'  # Configure approval in ADO UI
```

### 6. Deployment Security

#### A. Approval Gates

**Environment approvals:**
```yaml
stages:
  - stage: DeployProduction
    jobs:
      - deployment: Deploy
        environment: 'production'  # Requires approval in ADO
        strategy:
          runOnce:
            deploy:
              steps:
                - script: echo "Deploying to production"
```

**Configure approvals in ADO UI:**
- Environments → Select environment → Approvals and checks
- Add required approvers
- Set timeout
- Configure notifications

#### B. Deployment Gates

**Pre-deployment checks:**
```yaml
# Configure in ADO UI: Environments → Checks
# Available checks:
# - Azure Function
# - Azure Monitor
# - REST API call
# - Query Work Items
# - Required template
```

**Example REST API gate:**
```yaml
# In ADO UI, configure REST API check
# URL: https://api.security.com/validate
# Success criteria: eq(root['status'], 'approved')
```

#### C. Deployment Strategies

**Blue-Green Deployment:**
```yaml
- deployment: BlueGreenDeploy
  environment: 'production'
  strategy:
    runOnce:
      deploy:
        steps:
          - script: echo "Deploy to green slot"
          - script: echo "Run smoke tests on green"
          - script: echo "Swap green to blue"
          - script: echo "Monitor for issues"
```

**Canary Deployment:**
```yaml
- deployment: CanaryDeploy
  environment: 'production'
  strategy:
    canary:
      increments: [10, 25, 50, 100]
      preDeploy:
        steps:
          - script: echo "Pre-deployment checks"
      deploy:
        steps:
          - script: echo "Deploy to $(strategy.increment)%"
      routeTraffic:
        steps:
          - script: echo "Route $(strategy.increment)% traffic"
      postRouteTraffic:
        steps:
          - script: echo "Monitor metrics"
```

### 7. Audit and Compliance

#### A. Audit Logs

**Enable pipeline runs retention:**
```yaml
# In ADO: Project Settings → Pipelines → Settings
# Retention: 30+ days for production pipelines
```

**Export audit logs:**
```bash
# Using Azure DevOps CLI
az devops configure --defaults organization=https://dev.azure.com/myorg project=myproject

# Get pipeline runs
az pipelines runs list --pipeline-id <id> --query "[].{id:id, result:result, requestedBy:requestedBy.displayName}"
```

#### B. Compliance Scanning

**Policy as Code:**
```yaml
steps:
  - script: |
      # Check compliance before deployment
      python compliance-check.py --config compliance.yaml
    displayName: 'Compliance Validation'
```

**Required checks:**
- Code coverage threshold
- Security scan pass
- License compliance
- Container image from approved registry

### 8. Secure Build Agents

#### A. Hosted Agents

**Use Microsoft-hosted agents when possible:**
```yaml
pool:
  vmImage: 'ubuntu-24.04'  # Managed and updated by Microsoft, latest LTS
```

**Advantages:**
- Automatically updated
- Isolated per job
- No maintenance required
- Latest security patches

#### B. Self-Hosted Agents

**Security hardening:**
1. Regular OS and tool updates
2. Minimal software installed
3. Network isolation
4. Dedicated service account
5. Disable interactive login
6. Enable disk encryption
7. Audit agent access

**Agent configuration:**
```bash
# Run agent as non-privileged user
./config.sh --unattended \
  --agent myagent \
  --pool self-hosted \
  --work _work \
  --runAsService \
  --noRestart
```

### 9. Continuous Access Evaluation (CAE) - 2025

**New Security Feature (GA: August 2025):**

Azure DevOps now supports Continuous Access Evaluation, enabling near real-time enforcement of Conditional Access policies.

**Automatic Benefits:**
- Instant access revocation on security events
- No configuration required (enabled automatically)
- Works with Microsoft Entra ID policies

**When Access is Revoked Immediately:**
- User account disabled
- Password reset
- Location/IP changes
- Risk detection events
- Policy violations

**Example Impact:**
```yaml
stages:
  - stage: Production
    jobs:
      - deployment: Deploy
        environment: 'production'
        strategy:
          runOnce:
            deploy:
              steps:
                - script: |
                    # If user credentials revoked mid-deployment,
                    # CAE terminates access immediately (seconds, not hours)
                    az webapp deployment source config --name myapp
```

**Security Improvements:**
- Reduces attack window from hours/days to seconds
- Complements existing security measures
- Zero-trust enforcement

### 10. Security Best Practices Summary

**DO:**
- ✅ Use **workload identity federation (OIDC)** for Azure connections (2025 best practice)
- ✅ Use Azure Key Vault for secrets
- ✅ Implement SAST and dependency scanning
- ✅ Require code reviews and approvals
- ✅ Use service connections with least privilege
- ✅ Enable branch protection
- ✅ Scan container images
- ✅ Use managed identities where possible
- ✅ Implement deployment gates
- ✅ Enable audit logging
- ✅ Regular security reviews
- ✅ Leverage Continuous Access Evaluation (automatic)

**DON'T:**
- ❌ Hardcode secrets in YAML
- ❌ Use overly permissive service connections
- ❌ Skip security scanning
- ❌ Deploy directly to production
- ❌ Grant pipeline access to all repos
- ❌ Use admin credentials in pipelines
- ❌ Disable security features
- ❌ Ignore vulnerability scan results
- ❌ Share service connection passwords
- ❌ Skip approval gates

### 11. Security Incident Response

**Pipeline compromise response:**
1. Immediately disable compromised service connections
2. Rotate all secrets and credentials
3. Review pipeline run history for unauthorized changes
4. Audit repository access logs
5. Update security policies
6. Implement additional controls
7. Document and communicate incident

**Monitoring:**
```bash
# Monitor for suspicious pipeline activity
az pipelines runs list --query "[?result=='failed' || result=='canceled']"

# Check for unauthorized pipeline modifications
az repos pr list --status completed --query "[?contains(title, 'azure-pipelines')]"
```

## Output

Provide:
1. Security assessment of current pipeline
2. Hardened YAML with security improvements
3. List of identified vulnerabilities and risks
4. Service connection security review
5. Secrets management implementation plan
6. Required ADO configuration changes
7. Compliance checklist with status
8. Monitoring and alerting recommendations
9. Security documentation
10. Incident response procedures
