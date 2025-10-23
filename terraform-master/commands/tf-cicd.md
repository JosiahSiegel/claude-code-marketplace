# Terraform CI/CD Integration

Implement comprehensive CI/CD pipelines for Terraform across Azure DevOps, GitHub Actions, GitLab CI, and Jenkins.

## Your Task

You are helping set up or troubleshoot Terraform CI/CD pipelines. Provide platform-specific guidance and best practices.

## CI/CD Best Practices

### Core Principles

1. **Separate Plan and Apply**: Never auto-apply without review
2. **Environment Isolation**: Separate pipelines or stages per environment
3. **State Locking**: Ensure state locks prevent concurrent runs
4. **Approval Gates**: Require manual approval for production
5. **Artifact Storage**: Save plans for audit and apply
6. **Security Scanning**: Run tfsec/Checkov in pipeline
7. **Drift Detection**: Regular scheduled drift checks
8. **Rollback Strategy**: Plan for rollback procedures

## Azure DevOps Pipelines

### Complete Multi-Stage Pipeline

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - main
      - develop
  paths:
    include:
      - terraform/**

variables:
  - group: terraform-variables  # Variable group for secrets
  - name: terraformVersion
    value: '1.7.0'
  - name: terraformWorkingDirectory
    value: '$(System.DefaultWorkingDirectory)/terraform'

stages:
  # ============================================
  # Stage 1: Validation
  # ============================================
  - stage: Validate
    displayName: 'Validate Terraform'
    jobs:
      - job: FormatCheck
        displayName: 'Terraform Format Check'
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - task: TerraformInstaller@1
            displayName: 'Install Terraform'
            inputs:
              terraformVersion: $(terraformVersion)

          - task: TerraformCLI@0
            displayName: 'Terraform Format Check'
            inputs:
              command: 'fmt'
              workingDirectory: $(terraformWorkingDirectory)
              commandOptions: '-check -recursive -diff'

      - job: Validate
        displayName: 'Terraform Validate'
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - task: TerraformInstaller@1
            displayName: 'Install Terraform'
            inputs:
              terraformVersion: $(terraformVersion)

          - task: TerraformCLI@0
            displayName: 'Terraform Init'
            inputs:
              command: 'init'
              workingDirectory: $(terraformWorkingDirectory)
              backendType: 'azurerm'
              backendServiceArm: 'Azure-Connection'
              backendAzureRmResourceGroupName: 'terraform-state-rg'
              backendAzureRmStorageAccountName: 'tfstatestore'
              backendAzureRmContainerName: 'tfstate'
              backendAzureRmKey: 'terraform.tfstate'

          - task: TerraformCLI@0
            displayName: 'Terraform Validate'
            inputs:
              command: 'validate'
              workingDirectory: $(terraformWorkingDirectory)

      - job: SecurityScan
        displayName: 'Security Scanning'
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - task: Bash@3
            displayName: 'Install tfsec'
            inputs:
              targetType: 'inline'
              script: |
                curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash

          - task: Bash@3
            displayName: 'Run tfsec'
            inputs:
              targetType: 'inline'
              script: |
                tfsec $(terraformWorkingDirectory) --format junit --minimum-severity MEDIUM > tfsec-results.xml
              workingDirectory: $(System.DefaultWorkingDirectory)

          - task: PublishTestResults@2
            displayName: 'Publish tfsec Results'
            condition: always()
            inputs:
              testResultsFormat: 'JUnit'
              testResultsFiles: '**/tfsec-results.xml'
              failTaskOnFailedTests: true

  # ============================================
  # Stage 2: Plan (Development)
  # ============================================
  - stage: Plan_Dev
    displayName: 'Plan - Development'
    dependsOn: Validate
    condition: succeeded()
    jobs:
      - job: TerraformPlan
        displayName: 'Terraform Plan (Dev)'
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - task: TerraformInstaller@1
            inputs:
              terraformVersion: $(terraformVersion)

          - task: TerraformCLI@0
            displayName: 'Terraform Init'
            inputs:
              command: 'init'
              workingDirectory: $(terraformWorkingDirectory)
              backendType: 'azurerm'
              backendServiceArm: 'Azure-Connection'
              backendAzureRmResourceGroupName: 'terraform-state-rg'
              backendAzureRmStorageAccountName: 'tfstatestore'
              backendAzureRmContainerName: 'tfstate'
              backendAzureRmKey: 'dev.tfstate'

          - task: TerraformCLI@0
            displayName: 'Terraform Plan'
            inputs:
              command: 'plan'
              workingDirectory: $(terraformWorkingDirectory)
              environmentServiceName: 'Azure-Connection'
              commandOptions: '-var-file="environments/dev.tfvars" -out=tfplan -detailed-exitcode'
              publishPlanResults: 'tfplan'

          - task: PublishPipelineArtifact@1
            displayName: 'Publish Plan Artifact'
            inputs:
              targetPath: '$(terraformWorkingDirectory)/tfplan'
              artifact: 'tfplan-dev'
              publishLocation: 'pipeline'

          - task: PublishPipelineArtifact@1
            displayName: 'Publish Terraform Files'
            inputs:
              targetPath: '$(terraformWorkingDirectory)'
              artifact: 'terraform-dev'
              publishLocation: 'pipeline'

  # ============================================
  # Stage 3: Apply (Development)
  # ============================================
  - stage: Apply_Dev
    displayName: 'Apply - Development'
    dependsOn: Plan_Dev
    condition: |
      and(
        succeeded(),
        eq(variables['Build.SourceBranch'], 'refs/heads/develop')
      )
    jobs:
      - deployment: TerraformApply
        displayName: 'Terraform Apply (Dev)'
        pool:
          vmImage: 'ubuntu-latest'
        environment: 'Development'  # Can add approval gates in Azure DevOps
        strategy:
          runOnce:
            deploy:
              steps:
                - task: TerraformInstaller@1
                  inputs:
                    terraformVersion: $(terraformVersion)

                - task: DownloadPipelineArtifact@2
                  displayName: 'Download Terraform Files'
                  inputs:
                    artifact: 'terraform-dev'
                    path: $(Pipeline.Workspace)/terraform

                - task: DownloadPipelineArtifact@2
                  displayName: 'Download Plan'
                  inputs:
                    artifact: 'tfplan-dev'
                    path: $(Pipeline.Workspace)/terraform

                - task: TerraformCLI@0
                  displayName: 'Terraform Init'
                  inputs:
                    command: 'init'
                    workingDirectory: '$(Pipeline.Workspace)/terraform'
                    backendType: 'azurerm'
                    backendServiceArm: 'Azure-Connection'
                    backendAzureRmResourceGroupName: 'terraform-state-rg'
                    backendAzureRmStorageAccountName: 'tfstatestore'
                    backendAzureRmContainerName: 'tfstate'
                    backendAzureRmKey: 'dev.tfstate'

                - task: TerraformCLI@0
                  displayName: 'Terraform Apply'
                  inputs:
                    command: 'apply'
                    workingDirectory: '$(Pipeline.Workspace)/terraform'
                    environmentServiceName: 'Azure-Connection'
                    commandOptions: 'tfplan'

  # ============================================
  # Stage 4: Plan (Production)
  # ============================================
  - stage: Plan_Prod
    displayName: 'Plan - Production'
    dependsOn: Validate
    condition: |
      and(
        succeeded(),
        eq(variables['Build.SourceBranch'], 'refs/heads/main')
      )
    jobs:
      - job: TerraformPlan
        displayName: 'Terraform Plan (Prod)'
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - task: TerraformInstaller@1
            inputs:
              terraformVersion: $(terraformVersion)

          - task: TerraformCLI@0
            displayName: 'Terraform Init'
            inputs:
              command: 'init'
              workingDirectory: $(terraformWorkingDirectory)
              backendType: 'azurerm'
              backendServiceArm: 'Azure-Connection'
              backendAzureRmResourceGroupName: 'terraform-state-rg'
              backendAzureRmStorageAccountName: 'tfstatestore'
              backendAzureRmContainerName: 'tfstate'
              backendAzureRmKey: 'prod.tfstate'

          - task: TerraformCLI@0
            displayName: 'Terraform Plan'
            inputs:
              command: 'plan'
              workingDirectory: $(terraformWorkingDirectory)
              environmentServiceName: 'Azure-Connection'
              commandOptions: '-var-file="environments/prod.tfvars" -out=tfplan -detailed-exitcode'

          - task: PublishPipelineArtifact@1
            inputs:
              targetPath: '$(terraformWorkingDirectory)/tfplan'
              artifact: 'tfplan-prod'

          - task: PublishPipelineArtifact@1
            inputs:
              targetPath: '$(terraformWorkingDirectory)'
              artifact: 'terraform-prod'

  # ============================================
  # Stage 5: Apply (Production)
  # ============================================
  - stage: Apply_Prod
    displayName: 'Apply - Production'
    dependsOn: Plan_Prod
    condition: succeeded()
    jobs:
      - deployment: TerraformApply
        displayName: 'Terraform Apply (Prod)'
        pool:
          vmImage: 'ubuntu-latest'
        environment: 'Production'  # Requires manual approval
        strategy:
          runOnce:
            deploy:
              steps:
                - task: TerraformInstaller@1
                  inputs:
                    terraformVersion: $(terraformVersion)

                - task: DownloadPipelineArtifact@2
                  inputs:
                    artifact: 'terraform-prod'
                    path: $(Pipeline.Workspace)/terraform

                - task: DownloadPipelineArtifact@2
                  inputs:
                    artifact: 'tfplan-prod'
                    path: $(Pipeline.Workspace)/terraform

                - task: TerraformCLI@0
                  displayName: 'Terraform Init'
                  inputs:
                    command: 'init'
                    workingDirectory: '$(Pipeline.Workspace)/terraform'
                    backendType: 'azurerm'
                    backendServiceArm: 'Azure-Connection'
                    backendAzureRmResourceGroupName: 'terraform-state-rg'
                    backendAzureRmStorageAccountName: 'tfstatestore'
                    backendAzureRmContainerName: 'tfstate'
                    backendAzureRmKey: 'prod.tfstate'

                - task: TerraformCLI@0
                  displayName: 'Terraform Apply'
                  inputs:
                    command: 'apply'
                    workingDirectory: '$(Pipeline.Workspace)/terraform'
                    environmentServiceName: 'Azure-Connection'
                    commandOptions: 'tfplan'

# ============================================
# Scheduled Drift Detection
# ============================================
schedules:
  - cron: "0 0 * * *"  # Daily at midnight
    displayName: 'Daily Drift Detection'
    branches:
      include:
        - main
    always: true
```

### Service Connection Setup

```bash
# Create service principal
az ad sp create-for-rbac --name "terraform-sp" --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID"

# Add to Azure DevOps:
# Project Settings > Service connections > New service connection > Azure Resource Manager > Service Principal (manual)
```

## GitHub Actions

### Complete Workflow

```yaml
# .github/workflows/terraform.yml
name: 'Terraform CI/CD'

on:
  push:
    branches:
      - main
      - develop
    paths:
      - 'terraform/**'
  pull_request:
    branches:
      - main
      - develop
    paths:
      - 'terraform/**'
  schedule:
    - cron: '0 0 * * *'  # Daily drift detection

env:
  TERRAFORM_VERSION: '1.7.0'
  WORKING_DIRECTORY: './terraform'

permissions:
  id-token: write  # Required for OIDC
  contents: read
  pull-requests: write  # For PR comments

jobs:
  # ==========================================
  # Validation Jobs
  # ==========================================
  terraform-fmt:
    name: 'Terraform Format'
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TERRAFORM_VERSION }}

      - name: Terraform Format Check
        run: terraform fmt -check -recursive
        working-directory: ${{ env.WORKING_DIRECTORY }}

  terraform-validate:
    name: 'Terraform Validate'
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TERRAFORM_VERSION }}

      - name: Terraform Init
        run: terraform init -backend=false
        working-directory: ${{ env.WORKING_DIRECTORY }}

      - name: Terraform Validate
        run: terraform validate
        working-directory: ${{ env.WORKING_DIRECTORY }}

  security-scan:
    name: 'Security Scanning'
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: tfsec
        uses: aquasecurity/tfsec-action@v1.0.0
        with:
          working_directory: ${{ env.WORKING_DIRECTORY }}
          soft_fail: false
          format: sarif
          additional_args: --minimum-severity MEDIUM

      - name: Upload SARIF file
        uses: github/codeql-action/upload-sarif@v2
        if: always()
        with:
          sarif_file: tfsec.sarif

      - name: Checkov
        uses: bridgecrewio/checkov-action@master
        with:
          directory: ${{ env.WORKING_DIRECTORY }}
          framework: terraform
          soft_fail: false

  # ==========================================
  # Plan Jobs
  # ==========================================
  terraform-plan-dev:
    name: 'Plan - Development'
    runs-on: ubuntu-latest
    needs: [terraform-fmt, terraform-validate, security-scan]
    environment: development
    if: github.event_name == 'pull_request' || github.ref == 'refs/heads/develop'
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TERRAFORM_VERSION }}

      - name: Configure AWS Credentials (OIDC)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/GitHubActionsRole
          aws-region: us-east-1

      - name: Terraform Init
        run: terraform init
        working-directory: ${{ env.WORKING_DIRECTORY }}

      - name: Terraform Plan
        run: terraform plan -var-file="environments/dev.tfvars" -out=tfplan -no-color
        working-directory: ${{ env.WORKING_DIRECTORY }}

      - name: Upload Plan
        uses: actions/upload-artifact@v3
        with:
          name: tfplan-dev
          path: ${{ env.WORKING_DIRECTORY }}/tfplan
          retention-days: 5

      - name: Comment PR
        uses: actions/github-script@v7
        if: github.event_name == 'pull_request'
        with:
          script: |
            const fs = require('fs');
            const plan = fs.readFileSync('${{ env.WORKING_DIRECTORY }}/tfplan', 'utf8');
            const comment = `#### Terraform Plan (Development)\n\`\`\`\n${plan}\n\`\`\``;
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: comment
            });

  terraform-plan-prod:
    name: 'Plan - Production'
    runs-on: ubuntu-latest
    needs: [terraform-fmt, terraform-validate, security-scan]
    environment: production
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TERRAFORM_VERSION }}

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID_PROD }}:role/GitHubActionsRole
          aws-region: us-east-1

      - name: Terraform Init
        run: terraform init
        working-directory: ${{ env.WORKING_DIRECTORY }}

      - name: Terraform Plan
        run: terraform plan -var-file="environments/prod.tfvars" -out=tfplan
        working-directory: ${{ env.WORKING_DIRECTORY }}

      - name: Upload Plan
        uses: actions/upload-artifact@v3
        with:
          name: tfplan-prod
          path: ${{ env.WORKING_DIRECTORY }}/tfplan
          retention-days: 30

  # ==========================================
  # Apply Jobs
  # ==========================================
  terraform-apply-dev:
    name: 'Apply - Development'
    runs-on: ubuntu-latest
    needs: terraform-plan-dev
    environment: development
    if: github.ref == 'refs/heads/develop'
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TERRAFORM_VERSION }}

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/GitHubActionsRole
          aws-region: us-east-1

      - name: Download Plan
        uses: actions/download-artifact@v3
        with:
          name: tfplan-dev
          path: ${{ env.WORKING_DIRECTORY }}

      - name: Terraform Init
        run: terraform init
        working-directory: ${{ env.WORKING_DIRECTORY }}

      - name: Terraform Apply
        run: terraform apply -auto-approve tfplan
        working-directory: ${{ env.WORKING_DIRECTORY }}

  terraform-apply-prod:
    name: 'Apply - Production'
    runs-on: ubuntu-latest
    needs: terraform-plan-prod
    environment: production  # Requires approval in GitHub
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TERRAFORM_VERSION }}

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID_PROD }}:role/GitHubActionsRole
          aws-region: us-east-1

      - name: Download Plan
        uses: actions/download-artifact@v3
        with:
          name: tfplan-prod
          path: ${{ env.WORKING_DIRECTORY }}

      - name: Terraform Init
        run: terraform init
        working-directory: ${{ env.WORKING_DIRECTORY }}

      - name: Terraform Apply
        run: terraform apply -auto-approve tfplan
        working-directory: ${{ env.WORKING_DIRECTORY }}

  # ==========================================
  # Drift Detection
  # ==========================================
  drift-detection:
    name: 'Drift Detection'
    runs-on: ubuntu-latest
    if: github.event_name == 'schedule'
    strategy:
      matrix:
        environment: [dev, prod]
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TERRAFORM_VERSION }}

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ matrix.environment == 'prod' && secrets.AWS_ROLE_PROD || secrets.AWS_ROLE_DEV }}
          aws-region: us-east-1

      - name: Terraform Init
        run: terraform init
        working-directory: ${{ env.WORKING_DIRECTORY }}

      - name: Drift Detection
        run: |
          terraform plan -var-file="environments/${{ matrix.environment }}.tfvars" -detailed-exitcode || EXIT_CODE=$?
          if [ $EXIT_CODE -eq 2 ]; then
            echo "DRIFT_DETECTED=true" >> $GITHUB_ENV
          fi
        working-directory: ${{ env.WORKING_DIRECTORY }}

      - name: Create Issue on Drift
        if: env.DRIFT_DETECTED == 'true'
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: `Terraform Drift Detected - ${{ matrix.environment }}`,
              body: `Drift detected in ${{ matrix.environment }} environment. Please review.`,
              labels: ['terraform', 'drift', '${{ matrix.environment }}']
            });
```

### OIDC Setup (No Stored Secrets)

**AWS Trust Policy**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:ORG/REPO:ref:refs/heads/main"
        }
      }
    }
  ]
}
```

## GitLab CI

```yaml
# .gitlab-ci.yml
image:
  name: hashicorp/terraform:1.7
  entrypoint: [""]

variables:
  TF_ROOT: ${CI_PROJECT_DIR}/terraform
  TF_STATE_NAME: default

cache:
  paths:
    - ${TF_ROOT}/.terraform

stages:
  - validate
  - plan
  - apply

before_script:
  - cd ${TF_ROOT}
  - terraform init

validate:
  stage: validate
  script:
    - terraform fmt -check -recursive
    - terraform validate

security-scan:
  stage: validate
  image: aquasec/tfsec:latest
  script:
    - tfsec ${TF_ROOT} --minimum-severity MEDIUM

plan:
  stage: plan
  script:
    - terraform plan -out=tfplan
  artifacts:
    paths:
      - ${TF_ROOT}/tfplan
    expire_in: 1 week
  only:
    - branches

apply:
  stage: apply
  script:
    - terraform apply -auto-approve tfplan
  dependencies:
    - plan
  when: manual
  only:
    - main
```

## Best Practices Summary

- ✅ Separate plan and apply stages
- ✅ Save and artifact plans
- ✅ Require approval for production
- ✅ Run security scans in pipeline
- ✅ Use OIDC/managed identities (no stored secrets)
- ✅ Implement drift detection
- ✅ Use environment-specific variables
- ✅ Enable detailed logging
- ✅ Implement rollback procedures
- ✅ Test in non-production first

Activate the terraform-expert agent for comprehensive CI/CD guidance.
