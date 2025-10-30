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


# Apply Terraform Changes

Apply Terraform changes safely with comprehensive pre-apply checks, approval workflows, and rollback strategies.

## Your Task

You are helping apply Terraform changes to infrastructure. Follow these steps with extreme care:

1. **Pre-Apply Safety Checks**:

   **Mandatory Checks**:
   - ✅ Plan has been generated and reviewed
   - ✅ Plan has been approved by authorized personnel (for production)
   - ✅ Backup/snapshot strategy confirmed for critical resources
   - ✅ Rollback plan is in place
   - ✅ Maintenance window scheduled (if needed)
   - ✅ Team notifications sent (if applicable)

   **Verification**:
   ```bash
   # Verify correct environment
   terraform workspace show

   # Review what will be applied
   terraform show tfplan

   # Confirm state lock is available
   terraform force-unlock -force <LOCK_ID>  # Only if needed
   ```

2. **Determine Apply Strategy**:

   Ask the user:
   - Is this for dev, staging, or production?
   - Do they have a saved plan or applying directly?
   - Are there any specific resources to target?
   - What is the acceptable downtime window?
   - Do they need approval before proceeding?

3. **Apply Methods**:

   **Standard Apply with Saved Plan** (RECOMMENDED):
   ```bash
   # Most secure - uses pre-approved plan
   terraform apply tfplan
   ```

   **Direct Apply**:
   ```bash
   # Less secure - generates new plan
   terraform apply
   # Will prompt for approval unless -auto-approve
   ```

   **Auto-Approve** (CI/CD only, with safeguards):
   ```bash
   terraform apply -auto-approve
   # ⚠️ Use only in CI/CD with proper approval gates
   ```

   **Environment-Specific Apply**:
   ```bash
   # With tfvars
   terraform apply -var-file="environments/prod.tfvars"

   # With workspace
   terraform workspace select prod
   terraform apply tfplan
   ```

   **Targeted Apply** (use sparingly):
   ```bash
   # Specific resource
   terraform apply -target=azurerm_virtual_machine.web

   # Specific module
   terraform apply -target=module.networking
   ```

4. **Platform-Specific Execution**:

   **Windows PowerShell**:
   ```powershell
   # Set environment variables if needed
   $env:ARM_CLIENT_ID = "xxxxx"
   $env:ARM_CLIENT_SECRET = "xxxxx"
   $env:ARM_SUBSCRIPTION_ID = "xxxxx"
   $env:ARM_TENANT_ID = "xxxxx"

   # Apply with logging
   $env:TF_LOG = "INFO"
   $env:TF_LOG_PATH = "terraform-apply-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
   terraform apply tfplan
   ```

   **Linux/macOS**:
   ```bash
   # Set environment variables
   export ARM_CLIENT_ID="xxxxx"
   export ARM_CLIENT_SECRET="xxxxx"
   export ARM_SUBSCRIPTION_ID="xxxxx"
   export ARM_TENANT_ID="xxxxx"

   # Apply with logging
   TF_LOG=INFO TF_LOG_PATH="terraform-apply-$(date +%Y%m%d-%H%M%S).log" terraform apply tfplan
   ```

5. **CI/CD Apply Workflows**:

   **Azure DevOps**:
   ```yaml
   - stage: Apply
     condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
     jobs:
     - deployment: TerraformApply
       environment: 'Production'  # Requires approval
       strategy:
         runOnce:
           deploy:
             steps:
             - download: current
               artifact: tfplan

             - task: TerraformCLI@0
               inputs:
                 command: 'apply'
                 workingDirectory: '$(Pipeline.Workspace)/terraform'
                 commandOptions: 'tfplan'
                 environmentServiceName: 'Azure-Connection'
   ```

   **GitHub Actions**:
   ```yaml
   apply:
     name: Terraform Apply
     runs-on: ubuntu-latest
     environment: production  # Requires approval
     needs: plan
     if: github.ref == 'refs/heads/main'

     steps:
       - name: Download Plan
         uses: actions/download-artifact@v3
         with:
           name: tfplan

       - name: Terraform Apply
         run: terraform apply -auto-approve tfplan
   ```

6. **Apply Monitoring**:

   Watch for:
   - Resource creation progress
   - Error messages (save for troubleshooting)
   - Timeout warnings
   - Provider rate limiting
   - State lock conflicts

   **Long-Running Applies**:
   ```bash
   # Increase timeout
   terraform apply -lock-timeout=30m tfplan

   # Adjust parallelism
   terraform apply -parallelism=10 tfplan
   ```

7. **Post-Apply Validation**:

   **Immediate Checks**:
   ```bash
   # Verify resources created
   terraform state list

   # Check outputs
   terraform output

   # Verify no drift
   terraform plan -refresh-only
   ```

   **Application-Level Validation**:
   - Test application connectivity
   - Verify DNS resolution
   - Check load balancer health
   - Confirm monitoring alerts
   - Validate security group rules
   - Test authentication

8. **Rollback Procedures**:

   **Immediate Rollback** (if apply partially failed):
   ```bash
   # Review current state
   terraform state list

   # Remove failed resources
   terraform state rm <RESOURCE>

   # Apply previous configuration
   git checkout HEAD~1 -- .
   terraform apply
   ```

   **Full Rollback** (revert to previous state):
   ```bash
   # Download previous state from backend
   terraform state pull > terraform.tfstate.backup

   # Restore specific resource from backup
   terraform state push terraform.tfstate.backup

   # Or recreate from code
   git revert <COMMIT>
   terraform apply
   ```

9. **Error Handling**:

   **Common Apply Errors**:

   **Error: Resource already exists**
   ```bash
   # Import existing resource
   terraform import <RESOURCE_TYPE>.<NAME> <RESOURCE_ID>
   ```

   **Error: Timeout waiting for resource**
   ```bash
   # Increase timeout in resource configuration
   # Or use -parallelism to reduce concurrent operations
   terraform apply -parallelism=5
   ```

   **Error: State lock**
   ```bash
   # Check who has lock
   terraform force-unlock <LOCK_ID>
   # ⚠️ Only use if you're certain no other apply is running
   ```

   **Error: Provider authentication failed**
   - Verify credentials are current
   - Check service principal/IAM permissions
   - Confirm subscription/account access
   - Platform-specific credential renewal

10. **Apply Best Practices**:

    **Production Applies**:
    - ✅ ALWAYS use saved, approved plans
    - ✅ ALWAYS have rollback plan ready
    - ✅ ALWAYS apply during maintenance window
    - ✅ ALWAYS monitor during and after apply
    - ✅ ALWAYS validate post-apply
    - ❌ NEVER use -auto-approve in production manually
    - ❌ NEVER apply without reviewing plan
    - ❌ NEVER apply untested changes to production

    **Development/Staging**:
    - Can use direct apply for speed
    - Still review plan output
    - Test disaster recovery procedures

    **All Environments**:
    - Enable detailed logging
    - Save apply logs for audit
    - Document changes in ticketing system
    - Update infrastructure documentation
    - Notify relevant teams

## Advanced Apply Scenarios

**Blue-Green Deployments**:
```bash
# Create new infrastructure
terraform apply -var="environment_color=green"

# Validate green environment
# ...

# Switch traffic
# ...

# Destroy blue environment
terraform destroy -var="environment_color=blue"
```

**Partial Infrastructure Updates**:
```bash
# Update only network layer
terraform apply -target=module.network

# Then update compute layer
terraform apply -target=module.compute
```

**Multi-Region Applies**:
```bash
# Apply to each region sequentially
for region in eastus westus centralus; do
  terraform workspace select $region
  terraform apply -var="region=$region" tfplan-$region
done
```

## State Management During Apply

**State Locking**:
- Prevents concurrent applies
- Platform-specific lock mechanisms (Azure: blob lease, AWS: DynamoDB)
- Timeout configuration for long applies

**State Backup**:
```bash
# Backup before major changes
terraform state pull > terraform.tfstate.backup-$(date +%Y%m%d-%H%M%S)
```

## Critical Safety Warnings

- 🔴 STOP if apply wants to destroy critical resources unexpectedly
- 🔴 VERIFY you're in the correct workspace/environment
- 🔴 NEVER force-unlock unless absolutely certain no apply is running
- 🔴 ALWAYS have backups before applying destructive changes
- 🔴 NEVER apply to production without approval workflow
- 🔴 CHECK for resource replacements that will cause downtime
- 🔴 CONFIRM authentication is to correct subscription/account

## Emergency Procedures

**If Apply Hangs**:
1. Check provider API status
2. Verify network connectivity
3. Review Terraform logs (TF_LOG=DEBUG)
4. Consider increasing timeout
5. Last resort: Ctrl+C (may leave resources in inconsistent state)

**If Apply Fails Midway**:
1. Review error message carefully
2. Check state file for partial changes
3. Run `terraform plan` to see current state
4. Fix underlying issue
5. Re-run `terraform apply`
6. Consider targeted apply for remaining resources

Activate the terraform-expert agent for comprehensive apply guidance, troubleshooting, and platform-specific assistance.
