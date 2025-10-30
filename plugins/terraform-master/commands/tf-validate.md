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


# Validate Terraform Configuration

Validate Terraform configuration syntax, semantics, and best practices across all platforms and providers.

## Your Task

You are helping validate Terraform configuration comprehensively. Follow these validation layers:

1. **Syntax Validation** (terraform validate):

   ```bash
   # Basic validation
   terraform validate

   # Validate in specific directory
   terraform -chdir=path/to/config validate

   # JSON output for CI/CD
   terraform validate -json
   ```

   **What it checks**:
   - HCL syntax correctness
   - Required attributes present
   - Type constraints satisfied
   - Provider schema compliance
   - Module input/output consistency

   **What it DOESN'T check**:
   - Code formatting (use terraform fmt)
   - Security issues (use tfsec, Checkov)
   - Best practices (manual review)
   - Resource naming conventions
   - Cost optimization

2. **Format Validation** (terraform fmt):

   ```bash
   # Check formatting without changes
   terraform fmt -check

   # Recursively check all subdirectories
   terraform fmt -check -recursive

   # Actually format files
   terraform fmt -recursive

   # Show diff of formatting changes
   terraform fmt -diff
   ```

   **CI/CD Integration**:
   ```bash
   # Exit with non-zero if formatting needed
   terraform fmt -check -recursive || exit 1
   ```

3. **Provider Validation**:

   Verify provider configuration is correct:
   ```bash
   # Initialize to download providers
   terraform init

   # Validate provider configurations
   terraform validate

   # Check provider versions
   terraform version

   # Review lock file
   cat .terraform.lock.hcl
   ```

4. **Security Validation**:

   **tfsec** (Static Security Analysis):
   ```bash
   # Install tfsec (if not already)
   # Windows (Chocolatey): choco install tfsec
   # macOS (Homebrew): brew install tfsec
   # Linux: wget -qO- https://github.com/aquasecurity/tfsec/releases/download/v1.28.0/tfsec-linux-amd64 > /usr/local/bin/tfsec && chmod +x /usr/local/bin/tfsec

   # Run security scan
   tfsec .

   # With specific severity
   tfsec . --minimum-severity HIGH

   # Output as JSON for CI/CD
   tfsec . --format json

   # Ignore specific checks
   tfsec . --exclude aws-s3-enable-bucket-logging
   ```

   **Checkov** (Policy as Code):
   ```bash
   # Install checkov
   pip install checkov

   # Run checkov
   checkov -d .

   # Specific framework
   checkov -d . --framework terraform

   # Skip specific checks
   checkov -d . --skip-check CKV_AWS_19

   # Output formats
   checkov -d . -o json
   checkov -d . -o junitxml
   ```

   **Terrascan**:
   ```bash
   # Install terrascan
   # See: https://github.com/tenable/terrascan

   # Run scan
   terrascan scan -t terraform

   # Specific policy
   terrascan scan -t terraform -p aws
   ```

5. **Compliance Validation**:

   **terraform-compliance** (BDD Testing):
   ```bash
   # Install
   pip install terraform-compliance

   # Run compliance tests
   terraform-compliance -p tfplan.json -f compliance/
   ```

   **Sentinel** (Enterprise only):
   ```bash
   # Terraform Enterprise/Cloud policy enforcement
   # Policies defined in Sentinel language
   ```

   **Open Policy Agent (OPA)**:
   ```bash
   # Validate with OPA policies
   terraform show -json tfplan | opa eval --data policy/ --input -
   ```

6. **Module Validation**:

   **For module developers**:
   ```bash
   # Navigate to module directory
   cd modules/my-module

   # Validate module
   terraform validate

   # Test with example configurations
   cd examples/basic
   terraform init
   terraform validate
   terraform plan
   ```

   **terraform-docs** (Documentation Generation):
   ```bash
   # Install terraform-docs
   # Windows: choco install terraform-docs
   # macOS: brew install terraform-docs
   # Linux: See https://github.com/terraform-docs/terraform-docs

   # Generate documentation
   terraform-docs markdown table . > README.md

   # Validate documentation is up-to-date
   terraform-docs markdown table . | diff - README.md
   ```

7. **Cost Validation**:

   **Infracost** (Cost Estimation):
   ```bash
   # Install infracost
   # See: https://www.infracost.io/docs/

   # Generate cost estimate
   infracost breakdown --path .

   # Compare cost with main branch
   infracost diff --path . --compare-to main

   # Output as JSON
   infracost breakdown --path . --format json
   ```

8. **Dependency Validation**:

   **terraform graph**:
   ```bash
   # Generate dependency graph
   terraform graph | dot -Tpng > graph.png

   # Requires Graphviz: https://graphviz.org/download/
   # Windows: choco install graphviz
   # macOS: brew install graphviz
   # Linux: apt-get install graphviz

   # Review for circular dependencies
   terraform graph | grep cycle
   ```

9. **Platform-Specific Validation**:

   **Windows PowerShell**:
   ```powershell
   # Run full validation suite
   function Validate-Terraform {
       Write-Host "Running terraform fmt..." -ForegroundColor Cyan
       terraform fmt -check -recursive
       if ($LASTEXITCODE -ne 0) { throw "Format check failed" }

       Write-Host "Running terraform validate..." -ForegroundColor Cyan
       terraform validate
       if ($LASTEXITCODE -ne 0) { throw "Validation failed" }

       Write-Host "Running tfsec..." -ForegroundColor Cyan
       tfsec . --minimum-severity MEDIUM
       if ($LASTEXITCODE -ne 0) { throw "Security scan failed" }

       Write-Host "All validations passed!" -ForegroundColor Green
   }

   Validate-Terraform
   ```

   **Linux/macOS Bash**:
   ```bash
   #!/bin/bash
   # Full validation script

   set -e

   echo "Running terraform fmt..."
   terraform fmt -check -recursive

   echo "Running terraform validate..."
   terraform validate

   echo "Running tfsec..."
   tfsec . --minimum-severity MEDIUM

   echo "All validations passed!"
   ```

10. **CI/CD Validation Workflows**:

    **Azure DevOps**:
    ```yaml
    - stage: Validate
      jobs:
      - job: TerraformValidation
        steps:
        - task: TerraformCLI@0
          displayName: 'Terraform Format Check'
          inputs:
            command: 'fmt'
            workingDirectory: '$(System.DefaultWorkingDirectory)/terraform'
            commandOptions: '-check -recursive'

        - task: TerraformCLI@0
          displayName: 'Terraform Validate'
          inputs:
            command: 'validate'
            workingDirectory: '$(System.DefaultWorkingDirectory)/terraform'

        - task: Bash@3
          displayName: 'tfsec Security Scan'
          inputs:
            targetType: 'inline'
            script: |
              tfsec $(System.DefaultWorkingDirectory)/terraform --format junit > tfsec-results.xml

        - task: PublishTestResults@2
          displayName: 'Publish tfsec Results'
          inputs:
            testResultsFormat: 'JUnit'
            testResultsFiles: 'tfsec-results.xml'
    ```

    **GitHub Actions**:
    ```yaml
    name: Terraform Validation

    on: [pull_request]

    jobs:
      validate:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v3

          - name: Setup Terraform
            uses: hashicorp/setup-terraform@v2

          - name: Terraform Format Check
            run: terraform fmt -check -recursive

          - name: Terraform Init
            run: terraform init -backend=false

          - name: Terraform Validate
            run: terraform validate

          - name: tfsec Security Scan
            uses: aquasecurity/tfsec-action@v1.0.0
            with:
              soft_fail: false

          - name: Checkov Scan
            uses: bridgecrewio/checkov-action@master
            with:
              directory: .
              framework: terraform
    ```

## Validation Checklist

Use this comprehensive checklist:

### Syntax & Structure
- [ ] `terraform fmt -check` passes
- [ ] `terraform validate` passes
- [ ] No circular dependencies in `terraform graph`
- [ ] All variables have descriptions
- [ ] All outputs have descriptions
- [ ] Variable validation rules are appropriate

### Security
- [ ] No hardcoded secrets in code
- [ ] tfsec scan passes (or exceptions documented)
- [ ] Checkov scan passes (or exceptions documented)
- [ ] Encryption at rest enabled for data resources
- [ ] Encryption in transit configured
- [ ] Network security groups/firewalls properly configured
- [ ] IAM/RBAC follows least privilege
- [ ] Secrets stored in Key Vault/Secrets Manager

### Best Practices
- [ ] Provider versions pinned in versions.tf
- [ ] Terraform version constraint specified
- [ ] Remote backend configured (not local)
- [ ] State locking enabled
- [ ] Resources follow naming conventions
- [ ] Required tags/labels applied
- [ ] Lifecycle rules configured where appropriate
- [ ] Sensitive outputs marked as sensitive

### Documentation
- [ ] README.md exists and is current
- [ ] All modules have terraform-docs generated docs
- [ ] Examples provided for modules
- [ ] Variable defaults are sensible
- [ ] Comments explain complex logic

### Cost
- [ ] Infracost estimate reviewed
- [ ] Resource sizing appropriate for environment
- [ ] Cost optimization opportunities identified
- [ ] Reserved instances/commitments considered

### Platform Compatibility
- [ ] Code tested on target platform (Windows/Linux/macOS)
- [ ] Path separators are platform-agnostic
- [ ] Line endings configured (.gitattributes)
- [ ] Scripts use appropriate shell syntax

## Common Validation Issues

**Issue: terraform validate fails with "Module not installed"**
```bash
# Solution: Run terraform init
terraform init
terraform validate
```

**Issue: tfsec reports false positives**
```hcl
# Solution: Add inline ignore comment
resource "aws_s3_bucket" "example" {
  #tfsec:ignore:aws-s3-enable-bucket-logging
  bucket = "my-bucket"
  # Logging not required for this use case
}
```

**Issue: Checkov fails with policy violations**
```hcl
# Solution: Add skip annotation
resource "azurerm_storage_account" "example" {
  # checkov:skip=CKV_AZURE_33: Public access required for static website
  name = "example"
  # ...
}
```

**Issue: Format check fails due to Windows line endings**
```bash
# Solution: Configure git and reconvert
git config core.autocrlf input
git rm --cached -r .
git reset --hard
```

## Validation in Different Environments

**Development**:
- Run quick validations (fmt, validate)
- Security scanning can be warnings
- Focus on syntax correctness

**Staging**:
- Full validation suite
- Security scanning required
- Cost estimation reviewed
- Documentation validation

**Production**:
- All validations must pass
- No security scan exceptions without approval
- Compliance validation required
- Full documentation review
- Change approval workflow

## Critical Reminders

- ✅ ALWAYS run `terraform fmt` before committing
- ✅ ALWAYS run `terraform validate` after changes
- ✅ ALWAYS run security scanning (tfsec/Checkov)
- ✅ NEVER commit code with validation failures
- ✅ NEVER skip security scans for production
- ✅ ALWAYS document exception reasons for skipped checks

Activate the terraform-expert agent for comprehensive validation guidance and troubleshooting.
