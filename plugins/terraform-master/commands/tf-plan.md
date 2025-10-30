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


# Generate and Review Terraform Plan

Generate a Terraform execution plan and help analyze it for correctness, security, and best practices.

## Your Task

You are helping generate and review a Terraform plan. Follow these steps:

1. **Pre-Plan Assessment**:
   - Verify Terraform is initialized (`terraform init` completed)
   - Check current state lock status
   - Identify the target environment (dev/staging/prod)
   - Determine platform (Windows/Linux/macOS) for command syntax

2. **Gather Context**:
   - Ask what changes they're planning to make
   - Determine if this is for specific resources or entire configuration
   - Check if they need plan saved for later apply
   - Understand their approval workflow requirements

3. **Validate First**:
   Before planning, always run validation:
   ```bash
   terraform fmt -check
   terraform validate
   ```
   Address any validation errors before proceeding.

4. **Generate Plan**:

   **Basic Plan**:
   ```bash
   terraform plan
   ```

   **Save Plan for Apply** (recommended for CI/CD):
   ```bash
   terraform plan -out=tfplan
   ```

   **Environment-Specific**:
   ```bash
   # Using tfvars
   terraform plan -var-file="environments/prod.tfvars"

   # Using workspace
   terraform workspace select prod
   terraform plan
   ```

   **Targeted Plan**:
   ```bash
   # Specific resource
   terraform plan -target=azurerm_resource_group.example

   # Specific module
   terraform plan -target=module.networking
   ```

5. **Plan Analysis**:
   Review the plan output for:

   **Resource Changes**:
   - ✅ Additions: Review if new resources are necessary
   - ⚠️ Changes: Verify in-place updates vs replacements
   - 🔴 Deletions: CRITICAL - Confirm before proceeding
   - 🔄 Replacements: Understand impact (downtime, data loss)

   **Security Review**:
   - Check for public exposure (public IPs, open security groups)
   - Verify encryption settings
   - Confirm network isolation
   - Review IAM/RBAC permissions
   - Check for secrets in output (should use sensitive flag)

   **Compliance Check**:
   - Verify resource naming conventions
   - Check required tags/labels
   - Confirm compliance with organizational policies
   - Review cost implications

6. **Platform-Specific Considerations**:

   **Windows PowerShell**:
   ```powershell
   # Save plan with Windows-friendly path
   terraform plan -out="plans\tfplan-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

   # Review plan
   terraform show plans\tfplan-20240101-120000
   ```

   **Linux/macOS**:
   ```bash
   # Save with timestamp
   terraform plan -out="plans/tfplan-$(date +%Y%m%d-%H%M%S)"

   # Review plan
   terraform show plans/tfplan-20240101-120000
   ```

7. **Advanced Plan Options**:

   **Refresh Only** (check for drift):
   ```bash
   terraform plan -refresh-only
   ```

   **Destroy Plan**:
   ```bash
   terraform plan -destroy
   ```

   **Parallelism Control**:
   ```bash
   terraform plan -parallelism=20
   ```

   **Detailed Logs**:
   ```bash
   # Windows PowerShell
   $env:TF_LOG="DEBUG"
   terraform plan

   # Linux/macOS
   TF_LOG=DEBUG terraform plan
   ```

8. **CI/CD Plan Generation**:

   **Azure DevOps**:
   ```yaml
   - task: TerraformCLI@0
     inputs:
       command: 'plan'
       workingDirectory: '$(System.DefaultWorkingDirectory)/terraform'
       environmentServiceName: 'Azure-Connection'
       commandOptions: '-out=tfplan -detailed-exitcode'
   ```

   **GitHub Actions**:
   ```yaml
   - name: Terraform Plan
     run: terraform plan -out=tfplan -no-color

   - name: Upload Plan
     uses: actions/upload-artifact@v3
     with:
       name: tfplan
       path: tfplan
   ```

9. **Plan Review Workflow**:
   - Generate plan and save as artifact
   - Review plan output for unexpected changes
   - Run security scanning on plan (tfsec, Checkov)
   - Share plan with team for approval
   - Store plan for audit trail

10. **Security Scanning**:
    ```bash
    # tfsec scanning
    tfsec .

    # Checkov scanning on plan
    terraform show -json tfplan | checkov -f -

    # Terrascan
    terrascan scan -t terraform
    ```

## Common Plan Issues and Solutions

**Issue: Terraform wants to destroy and recreate resources**
- Cause: Breaking changes in resource configuration
- Solution: Review what changed, consider lifecycle prevent_destroy

**Issue: Plan shows no changes but resources are modified outside Terraform**
- Cause: State drift
- Solution: Run `terraform plan -refresh-only` first

**Issue: Plan times out or is very slow**
- Cause: Large state file or too many resources
- Solution: Use `-parallelism`, `-target`, or split state

**Issue: Plan fails with authentication errors**
- Cause: Expired credentials or incorrect provider config
- Solution: Platform-specific credential renewal

**Issue: Plan shows unexpected changes**
- Cause: Terraform version or provider version differences
- Solution: Check terraform.lock.hcl, ensure version consistency

## Plan Best Practices

1. **Always save plans** for production applies
2. **Review before apply** - never blind apply
3. **Use -detailed-exitcode** in CI/CD (exit 2 = changes present)
4. **Run security scanning** on all plans
5. **Document plan approvals** for audit compliance
6. **Set plan timeouts** appropriately for large infrastructures
7. **Use targeted plans** for large state files when appropriate
8. **Archive plans** for compliance and rollback reference

## Critical Warnings

- ⚠️ ALWAYS review deletion operations carefully
- ⚠️ NEVER apply without reviewing plan first
- ⚠️ CHECK for resource replacements that may cause downtime
- ⚠️ VERIFY data resources are using correct filters
- ⚠️ CONFIRM secrets are marked as sensitive in outputs

Activate the terraform-expert agent for detailed plan analysis and troubleshooting.
