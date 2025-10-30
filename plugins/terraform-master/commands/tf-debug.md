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


# Debug Terraform Issues

Systematically debug and troubleshoot Terraform issues across all platforms with comprehensive diagnostic techniques.

## Your Task

You are helping debug Terraform issues. Gather information systematically and provide platform-aware troubleshooting guidance.

## Diagnostic Information Gathering

### 1. Basic Environment Info

```bash
# Terraform version
terraform version

# Provider versions
terraform providers

# Current workspace
terraform workspace show

# Platform information (automatically include in debugging)
# Windows: PowerShell $PSVersionTable
# Linux/macOS: uname -a
```

### 2. Enable Debug Logging

**Windows PowerShell**:
```powershell
# Set log level
$env:TF_LOG = "DEBUG"  # Levels: TRACE, DEBUG, INFO, WARN, ERROR

# Save logs to file
$env:TF_LOG_PATH = "terraform-debug-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

# Run Terraform command
terraform plan

# Disable logging when done
Remove-Item Env:TF_LOG
Remove-Item Env:TF_LOG_PATH
```

**Linux/macOS**:
```bash
# Set log level
export TF_LOG=DEBUG  # Levels: TRACE, DEBUG, INFO, WARN, ERROR

# Save logs to file
export TF_LOG_PATH="terraform-debug-$(date +%Y%m%d-%H%M%S).log"

# Run Terraform command
terraform plan

# Disable logging when done
unset TF_LOG
unset TF_LOG_PATH
```

**Provider-Specific Logging**:
```bash
# Azure provider debugging
export TF_LOG_PROVIDER=DEBUG
export ARM_TERRAFORM_PROVIDER_LOG_PATH="azurerm-debug.log"

# AWS provider debugging
export TF_LOG_PROVIDER=DEBUG
export AWS_SDK_LOG_LEVEL=debug
```

### 3. State Inspection

```bash
# List all resources in state
terraform state list

# Show specific resource
terraform state show azurerm_resource_group.example

# Pull entire state (careful with sensitive data)
terraform state pull > current-state.json

# Check state lock status
# Azure: Check blob lease in storage account
# AWS: Check DynamoDB lock table
# Manual unlock (use with caution):
# terraform force-unlock <LOCK_ID>
```

## Common Issues and Solutions

### Issue Category: Initialization Problems

**Error: Failed to install provider**
```bash
# Symptoms:
Error: Failed to query available provider packages
Could not retrieve the list of available versions

# Platform-Specific Solutions:

# Windows - Check proxy settings
$env:HTTP_PROXY = "http://proxy:port"
$env:HTTPS_PROXY = "http://proxy:port"
terraform init

# Windows - Trust certificate
# Add certificate to Trusted Root Certification Authorities

# Linux/macOS - Check proxy
export HTTP_PROXY=http://proxy:port
export HTTPS_PROXY=http://proxy:port
terraform init

# Air-gapped/offline environments
# Use filesystem mirror or network mirror
terraform {
  provider_installation {
    filesystem_mirror {
      path    = "/usr/share/terraform/providers"
      include = ["registry.terraform.io/*/*"]
    }
  }
}
```

**Error: Backend configuration changed**
```bash
# Symptoms:
Error: Backend configuration changed

# Solution:
# Reinitialize with new backend configuration
terraform init -reconfigure

# Or migrate state to new backend
terraform init -migrate-state
```

### Issue Category: Authentication Problems

**Azure Authentication Failures**:
```bash
# Verify Azure CLI login
az account show
az account set --subscription "subscription-id"

# Service Principal authentication
# Check environment variables
echo $ARM_CLIENT_ID
echo $ARM_TENANT_ID
# Don't echo ARM_CLIENT_SECRET in logs!

# Managed Identity
# Verify identity assigned to VM/Container
az identity show --ids /subscriptions/.../Microsoft.ManagedIdentity/userAssignedIdentities/...

# OIDC (GitHub Actions)
# Verify federated credentials configured
# Check token expiration
```

**AWS Authentication Failures**:
```bash
# Verify credentials
aws sts get-caller-identity

# Check profile
aws configure list

# Verify assume role
aws sts assume-role --role-arn arn:aws:iam::123456789:role/Role --role-session-name test

# Check permissions
# Use IAM Policy Simulator
```

**GCP Authentication Failures**:
```bash
# Verify application default credentials
gcloud auth application-default login

# Check active account
gcloud config list

# Verify service account
gcloud iam service-accounts list

# Test service account permissions
gcloud projects get-iam-policy PROJECT_ID
```

### Issue Category: Resource Creation Failures

**Timeout Errors**:
```bash
# Symptoms:
Error: context deadline exceeded
Error: timeout while waiting for resource

# Solutions:
1. Increase provider timeout
resource "azurerm_virtual_machine" "example" {
  timeouts {
    create = "60m"  # Increase from default
    read   = "5m"
    update = "60m"
    delete = "60m"
  }
}

2. Reduce parallelism
terraform apply -parallelism=5

3. Check resource provider API status
# Azure: https://status.azure.com/
# AWS: https://health.aws.amazon.com/
# GCP: https://status.cloud.google.com/

4. Network connectivity issues
# Test API endpoint connectivity
# Windows:
Test-NetConnection -ComputerName management.azure.com -Port 443
# Linux/macOS:
curl -I https://management.azure.com/
```

**Resource Already Exists**:
```bash
# Symptoms:
Error: A resource with the ID "/subscriptions/..." already exists

# Solutions:
1. Import existing resource
terraform import azurerm_resource_group.example /subscriptions/.../resourceGroups/my-rg

2. Remove from state if duplicate
terraform state rm azurerm_resource_group.example

3. Use lifecycle prevent_destroy
resource "azurerm_resource_group" "example" {
  lifecycle {
    prevent_destroy = true
  }
}
```

**Dependency Errors**:
```bash
# Symptoms:
Error: Cycle: resource A -> resource B -> resource A

# Solutions:
1. Review dependency graph
terraform graph | dot -Tpng > graph.png

2. Use depends_on to break implicit cycles
resource "azurerm_resource" "example" {
  depends_on = [azurerm_other_resource.example]
}

3. Refactor configuration to eliminate circular dependencies
```

### Issue Category: State Problems

**State Lock Conflicts**:
```bash
# Symptoms:
Error: Error acquiring the state lock

# Solutions:
1. Wait for lock to release (another apply running)

2. Check lock status
# Azure: Check blob properties
az storage blob show --account-name <storage> --container-name tfstate --name terraform.tfstate

# AWS: Check DynamoDB
aws dynamodb get-item --table-name terraform-locks --key '{"LockID":{"S":"<state-file-path>"}}'

3. Force unlock (USE WITH EXTREME CAUTION)
terraform force-unlock <LOCK_ID>
# Only use if you're absolutely certain no other process is running

4. Platform-specific lock troubleshooting
# Azure - Check for stale blob lease
# Use Azure Portal or Storage Explorer to break lease

# AWS - Delete lock item from DynamoDB (last resort)
aws dynamodb delete-item --table-name terraform-locks --key '{"LockID":{"S":"..."}}'
```

**State Drift**:
```bash
# Symptoms:
Resources in state don't match reality

# Diagnosis:
terraform plan -refresh-only

# Solutions:
1. Refresh state
terraform apply -refresh-only

2. Import missing resources
terraform import address id

3. Remove orphaned resources
terraform state rm address

4. Rebuild state
# Last resort - export resources, delete state, reimport
```

**Corrupted State**:
```bash
# Symptoms:
Error: Failed to load state
Error: state snapshot was created by Terraform X, but this is Y

# Solutions:
1. Restore from backup
# Azure Blob: Previous versions
# AWS S3: Versioning
# Local: git history or manual backups
terraform state push terraform.tfstate.backup

2. Repair state file
# Very risky - manual JSON editing

3. Rebuild state from scratch
# Nuclear option
```

### Issue Category: Platform-Specific Issues

**Windows Issues**:

**Path Length Limitations**:
```powershell
# Error: Path too long (260 character limit in some cases)

# Solution: Enable long paths
# Registry: HKLM\SYSTEM\CurrentControlSet\Control\FileSystem
# Set LongPathsEnabled = 1

# Or use shorter directory structure
```

**PowerShell Execution Policy**:
```powershell
# Error: Script execution disabled

# Solution: Set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or bypass for specific command
powershell -ExecutionPolicy Bypass -File script.ps1
```

**Line Ending Issues**:
```bash
# Symptoms:
# Provisioners fail with "^M: bad interpreter"

# Solution: Configure git
git config --global core.autocrlf input

# Add .gitattributes
*.tf text eol=lf
*.sh text eol=lf
```

**Linux/macOS Issues**:

**Permission Denied**:
```bash
# Error: Permission denied when running Terraform

# Solution: Check binary permissions
chmod +x /usr/local/bin/terraform

# Or script permissions
chmod +x scripts/deploy.sh
```

**Plugin Installation Permissions**:
```bash
# Error: Cannot create plugin directory

# Solution: Fix ownership
sudo chown -R $USER:$USER ~/.terraform.d
```

### Issue Category: Performance Issues

**Slow Plans/Applies**:
```bash
# Diagnosis:
1. Enable debug logging to see where time is spent
TF_LOG=DEBUG terraform plan

2. Review resource count
terraform state list | wc -l

# Solutions:
1. Increase parallelism
terraform apply -parallelism=20

2. Use targeted operations
terraform plan -target=module.networking

3. Split large state files
# Separate workspaces or backends per environment/layer

4. Enable provider plugin cache
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"

5. Use -refresh=false for plan (if safe)
terraform plan -refresh=false
```

**Large State File Issues**:
```bash
# Diagnosis:
# State file > 100MB

# Solutions:
1. Split state into multiple backends
# Separate by environment, team, or layer

2. Remove unused resources
terraform state list
terraform state rm 'unused.resource'

3. Use remote state data sources instead of direct dependencies
data "terraform_remote_state" "networking" {
  backend = "azurerm"
  config = {
    # ...
  }
}
```

## Advanced Debugging Techniques

### Crash Log Analysis

```bash
# Terraform crash creates crash.log
# Location varies by platform:
# Windows: Current directory
# Linux/macOS: Current directory

# Analyze crash log
cat crash.log

# Report crash with log
# File issue: https://github.com/hashicorp/terraform/issues
```

### Provider Debug Mode

**AzureRM Provider**:
```hcl
provider "azurerm" {
  features {}

  # Additional logging
  skip_provider_registration = false

  # Partner ID for support
  partner_id = "your-partner-id"
}
```

**AWS Provider**:
```bash
# Enable AWS SDK logging
export AWS_SDK_LOG_LEVEL=debug
```

### Network Trace

**Windows**:
```powershell
# Use Fiddler or Wireshark
# Or netsh trace
netsh trace start capture=yes
# Run terraform command
netsh trace stop
```

**Linux/macOS**:
```bash
# tcpdump
sudo tcpdump -i any -w terraform-traffic.pcap

# Or mitmproxy
mitmproxy -p 8080
export HTTP_PROXY=http://localhost:8080
export HTTPS_PROXY=http://localhost:8080
```

### Graph Analysis

```bash
# Generate dependency graph
terraform graph > graph.dot

# Convert to PNG (requires Graphviz)
dot -Tpng graph.dot > graph.png

# Or use online viewer
# https://dreampuf.github.io/GraphvizOnline/
```

## CI/CD Debugging

**Azure DevOps**:
```yaml
- task: TerraformCLI@0
  inputs:
    command: 'plan'
    workingDirectory: '$(System.DefaultWorkingDirectory)'
    commandOptions: '-detailed-exitcode'
  env:
    TF_LOG: 'DEBUG'
    TF_LOG_PATH: '$(Build.ArtifactStagingDirectory)/terraform-debug.log'

- task: PublishBuildArtifacts@1
  condition: always()
  inputs:
    PathtoPublish: '$(Build.ArtifactStagingDirectory)/terraform-debug.log'
    ArtifactName: 'terraform-logs'
```

**GitHub Actions**:
```yaml
- name: Terraform Plan
  run: terraform plan
  env:
    TF_LOG: DEBUG
    TF_LOG_PATH: terraform-debug.log

- name: Upload Debug Logs
  if: always()
  uses: actions/upload-artifact@v3
  with:
    name: terraform-logs
    path: terraform-debug.log
```

## Debugging Checklist

### Initial Triage
- [ ] What command failed?
- [ ] What is the exact error message?
- [ ] When did it start failing?
- [ ] What changed recently?
- [ ] Does it work elsewhere (local vs CI/CD)?

### Environment Check
- [ ] Terraform version
- [ ] Provider versions
- [ ] Platform (Windows/Linux/macOS)
- [ ] Authentication method
- [ ] Network connectivity

### Enable Logging
- [ ] TF_LOG=DEBUG enabled
- [ ] TF_LOG_PATH set
- [ ] Provider-specific logging
- [ ] Save logs for analysis

### State Investigation
- [ ] State file accessible
- [ ] State lock status
- [ ] State vs reality comparison
- [ ] Recent state changes

### Provider/API Check
- [ ] Authentication valid
- [ ] Permissions sufficient
- [ ] API service status
- [ ] Rate limiting

### Reproduce
- [ ] Reproduce in isolation
- [ ] Minimal reproduction case
- [ ] Document steps

## Getting Help

**Community Resources**:
- HashiCorp Discuss: https://discuss.hashicorp.com/c/terraform-core
- GitHub Issues: Provider-specific repositories
- Stack Overflow: terraform tag

**When Asking for Help**:
Include:
1. Terraform version (`terraform version`)
2. Provider versions (`terraform providers`)
3. Platform (OS, version)
4. Minimal reproduction code
5. Full error message
6. Debug logs (sanitized)
7. What you've tried

Activate the terraform-expert agent for comprehensive debugging assistance.
