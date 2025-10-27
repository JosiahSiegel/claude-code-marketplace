# Terraform Security and Best Practices

Implement comprehensive security scanning, compliance validation, and security best practices for Terraform infrastructure.

## Your Task

You are helping secure Terraform infrastructure. Provide security guidance, scanning, and compliance validation.

## Security Scanning Tools (2025)

### 1. Trivy (Unified Security Scanner) - RECOMMENDED

**Overview:**
- **tfsec functionality merged into Trivy in 2025** - tfsec no longer actively developed
- Unified scanner for IaC, containers, filesystems, and more
- Aqua Security's comprehensive security solution
- Supports Terraform, CloudFormation, Kubernetes, Helm, Dockerfile

**Installation**:
```bash
# Windows (Chocolatey)
choco install trivy

# macOS (Homebrew)
brew install trivy

# Linux
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy

# Or via script
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Docker
docker pull aquasec/trivy:latest
```

**Terraform Scanning**:
```bash
# Scan Terraform configuration
trivy config .

# Scan specific directory
trivy config /path/to/terraform

# Scan with minimum severity
trivy config --severity HIGH,CRITICAL .

# Output formats
trivy config --format json .
trivy config --format sarif -o trivy-results.sarif .
trivy config --format table .

# Include passed checks
trivy config --include-passed .

# Scan specific module
trivy config --namespaces terraform ./modules/networking
```

**Inline Ignore**:
```hcl
resource "aws_s3_bucket" "example" {
  #trivy:ignore:AVD-AWS-0086
  bucket = "my-bucket"
  # Versioning not required for temporary bucket
}

# Or with expiry date
resource "azurerm_storage_account" "example" {
  #trivy:ignore:AVD-AZU-0037:exp:2025-12-31
  name = "example"
  # TLS 1.0 required for legacy client, upgrading by EOY
}
```

**trivy.yaml Configuration**:
```yaml
# trivy.yaml
severity:
  - HIGH
  - CRITICAL

scan:
  skip-dirs:
    - "**/.terraform"

skip-checks:
  - AVD-AWS-0086  # S3 bucket versioning

format: table
```

**Advanced Features**:
```bash
# Scan with custom policies
trivy config --policy ./policies .

# Check misconfigurations and secrets
trivy fs --scanners config,secret .

# Scan Terraform plan
terraform show -json tfplan.bin > tfplan.json
trivy config --tf-vars tfplan.json .
```

### 2. Checkov (Policy as Code)

**Installation**:
```bash
# Python pip
pip install checkov

# Or using pipx
pipx install checkov

# Homebrew
brew install checkov
```

**Basic Usage**:
```bash
# Scan current directory
checkov -d .

# Scan specific framework
checkov -d . --framework terraform

# Skip specific checks
checkov -d . --skip-check CKV_AWS_19,CKV_AWS_20

# Only run specific checks
checkov -d . --check CKV_AWS_18

# Output formats
checkov -d . -o json
checkov -d . -o junitxml
checkov -d . -o sarif
checkov -d . -o cli

# Save results to file
checkov -d . -o json > checkov-results.json

# Scan Terraform plan
terraform show -json tfplan > tfplan.json
checkov -f tfplan.json
```

**Inline Skip**:
```hcl
resource "azurerm_storage_account" "example" {
  #checkov:skip=CKV_AZURE_33:Public access required for static website hosting
  name                     = "example"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

**.checkov.yml Configuration**:
```yaml
# .checkov.yml
framework:
  - terraform

skip-check:
  - CKV_AWS_19  # Ensure S3 bucket has server-side encryption enabled
  - CKV_AZURE_33  # Ensure storage account is not publicly accessible

compact: true
quiet: false
```

### 3. Terrascan

**Installation**:
```bash
# Binary install
# Download from: https://github.com/tenable/terrascan/releases

# Homebrew
brew install terrascan

# Docker
docker run --rm -v $(pwd):/iac tenable/terrascan scan -t terraform
```

**Usage**:
```bash
# Scan current directory
terrascan scan -t terraform

# Scan specific policy
terrascan scan -t terraform -p aws

# Skip rules
terrascan scan -t terraform --skip-rules="accurics.kubernetes.IAM.107,accurics.kubernetes.OPS.341"

# Output formats
terrascan scan -t terraform -o json
terrascan scan -t terraform -o sarif
terrascan scan -t terraform -o human
```

### 4. Sentinel (Terraform Cloud/Enterprise)

**Policy Example**:
```hcl
# sentinel.hcl
policy "require-tags" {
  source = "./require-tags.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "restrict-instance-type" {
  source = "./restrict-instance-type.sentinel"
  enforcement_level = "soft-mandatory"
}
```

**Sentinel Policy**:
```python
# require-tags.sentinel
import "tfplan/v2" as tfplan

mandatory_tags = ["Environment", "Owner", "CostCenter"]

# Get all resources
all_resources = filter tfplan.resource_changes as _, rc {
  rc.mode is "managed"
}

# Check tags
main = rule {
  all all_resources as _, resource {
    all mandatory_tags as tag {
      resource.change.after.tags contains tag
    }
  }
}
```

### 5. OPA (Open Policy Agent)

**Rego Policy**:
```rego
# policy.rego
package terraform

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_s3_bucket"
  not resource.change.after.versioning[_].enabled
  msg := sprintf("S3 bucket %s must have versioning enabled", [resource.address])
}
```

**Usage**:
```bash
# Generate Terraform plan as JSON
terraform show -json tfplan > tfplan.json

# Evaluate policy
opa eval --data policy.rego --input tfplan.json "data.terraform.deny"
```

## Security Best Practices

### 1. Secrets Management

**NEVER Store Secrets in Code**:
```hcl
# ❌ BAD - Never do this
resource "azurerm_postgresql_server" "example" {
  administrator_login          = "admin"
  administrator_login_password = "P@ssw0rd123!"  # NEVER!
}

# ✅ GOOD - Use variables
resource "azurerm_postgresql_server" "example" {
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password  # Mark as sensitive
}

variable "admin_password" {
  type      = string
  sensitive = true
}
```

**Use Secret Management Services**:

**Azure Key Vault**:
```hcl
data "azurerm_key_vault" "example" {
  name                = "example-keyvault"
  resource_group_name = "example-rg"
}

data "azurerm_key_vault_secret" "db_password" {
  name         = "database-password"
  key_vault_id = data.azurerm_key_vault.example.id
}

resource "azurerm_postgresql_server" "example" {
  administrator_login_password = data.azurerm_key_vault_secret.db_password.value
}
```

**AWS Secrets Manager**:
```hcl
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "database-password"
}

resource "aws_db_instance" "example" {
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
}
```

**Google Secret Manager**:
```hcl
data "google_secret_manager_secret_version" "db_password" {
  secret = "database-password"
}

resource "google_sql_user" "example" {
  password = data.google_secret_manager_secret_version.db_password.secret_data
}
```

**SOPS (Encrypted Files)**:
```yaml
# secrets.enc.yaml (encrypted with sops)
db_password: ENC[AES256_GCM,data:xxx,type:str]

# Decrypt and use
data "sops_file" "secrets" {
  source_file = "secrets.enc.yaml"
}

resource "azurerm_postgresql_server" "example" {
  administrator_login_password = data.sops_file.secrets.data["db_password"]
}
```

### 2. Network Security

**Private Endpoints**:
```hcl
# Azure - Private endpoint for storage
resource "azurerm_private_endpoint" "storage" {
  name                = "storage-pe"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  subnet_id           = azurerm_subnet.private.id

  private_service_connection {
    name                           = "storage-psc"
    private_connection_resource_id = azurerm_storage_account.example.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}

# Disable public access
resource "azurerm_storage_account" "example" {
  public_network_access_enabled = false
}
```

**Security Groups/NSGs**:
```hcl
# Least privilege - specific sources only
resource "azurerm_network_security_rule" "https" {
  name                        = "AllowHTTPS"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "10.0.0.0/8"  # Specific network
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.example.name
}

# ❌ Avoid 0.0.0.0/0 for production
```

### 3. Encryption

**At Rest Encryption**:
```hcl
# Azure Storage - Customer managed keys
resource "azurerm_storage_account" "example" {
  name                     = "example"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  customer_managed_key {
    key_vault_key_id          = azurerm_key_vault_key.example.id
    user_assigned_identity_id = azurerm_user_assigned_identity.example.id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.example.id]
  }
}

# AWS S3 - KMS encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.example.arn
    }
  }
}
```

**In Transit Encryption**:
```hcl
# Enforce HTTPS only
resource "azurerm_storage_account" "example" {
  name                      = "example"
  resource_group_name       = azurerm_resource_group.example.name
  location                  = azurerm_resource_group.example.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  min_tls_version          = "TLS1_2"
}

# AWS - Enforce SSL
resource "aws_s3_bucket_policy" "example" {
  bucket = aws_s3_bucket.example.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceSSL"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.example.arn,
          "${aws_s3_bucket.example.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}
```

### 4. IAM/RBAC Least Privilege

**Azure RBAC**:
```hcl
# Specific role, specific scope
resource "azurerm_role_assignment" "example" {
  scope                = azurerm_storage_account.example.id
  role_definition_name = "Storage Blob Data Reader"  # Specific role
  principal_id         = azurerm_user_assigned_identity.example.principal_id
}

# ❌ Avoid Owner/Contributor at subscription level
```

**AWS IAM**:
```hcl
# Least privilege policy
resource "aws_iam_role_policy" "example" {
  name = "example-policy"
  role = aws_iam_role.example.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.example.arn,
          "${aws_s3_bucket.example.arn}/*"
        ]
      }
    ]
  })
}

# ❌ Avoid AdministratorAccess
```

### 5. Monitoring and Auditing

**Enable Logging**:
```hcl
# Azure - Diagnostic settings
resource "azurerm_monitor_diagnostic_setting" "example" {
  name               = "example-diag"
  target_resource_id = azurerm_storage_account.example.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  metric {
    category = "Transaction"
  }
}

# AWS - CloudTrail
resource "aws_cloudtrail" "example" {
  name                          = "example-trail"
  s3_bucket_name                = aws_s3_bucket.logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
}
```

## CI/CD Security Integration

### GitHub Actions (2025)

```yaml
name: Security Scan

on: [pull_request]

jobs:
  trivy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run Trivy Scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'config'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'HIGH,CRITICAL'

      - name: Upload Trivy SARIF
        uses: github/codeql-action/upload-sarif@v3
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'

  checkov:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Checkov
        uses: bridgecrewio/checkov-action@master
        with:
          directory: .
          framework: terraform
          soft_fail: false
          output_format: sarif
          output_file_path: checkov.sarif

      - name: Upload Checkov SARIF
        uses: github/codeql-action/upload-sarif@v3
        if: always()
        with:
          sarif_file: checkov.sarif
```

### Azure DevOps (2025)

```yaml
- stage: SecurityScan
  jobs:
  - job: trivy
    steps:
    - task: Bash@3
      displayName: 'Install Trivy'
      inputs:
        targetType: 'inline'
        script: |
          curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

    - task: Bash@3
      displayName: 'Run Trivy Scanner'
      inputs:
        targetType: 'inline'
        script: |
          trivy config --format sarif --output trivy-results.sarif .
          trivy config --format table .
      continueOnError: false

    - task: PublishBuildArtifacts@1
      displayName: 'Publish Trivy Results'
      condition: always()
      inputs:
        PathtoPublish: 'trivy-results.sarif'
        ArtifactName: 'Trivy Security Scan'

  - job: checkov
    steps:
    - task: UsePythonVersion@0
      inputs:
        versionSpec: '3.x'

    - script: |
        pip install checkov
        checkov -d . --framework terraform -o junitxml > checkov-results.xml
        checkov -d . --framework terraform
      displayName: 'Run Checkov'
      continueOnError: false

    - task: PublishTestResults@2
      displayName: 'Publish Checkov Results'
      condition: always()
      inputs:
        testResultsFormat: 'JUnit'
        testResultsFiles: 'checkov-results.xml'
```

## Pre-Commit Hooks (2025)

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.90.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
      - id: terraform_trivy
        args:
          - --args=--severity=HIGH,CRITICAL
      - id: terraform_checkov
        args:
          - --args=--framework terraform
```

## Security Checklist

### Configuration Security
- [ ] No secrets in code (use secret management)
- [ ] Sensitive variables marked as sensitive
- [ ] Secrets from vault/secret manager
- [ ] .gitignore includes state files
- [ ] State backend encrypted at rest
- [ ] State backend access restricted

### Network Security
- [ ] Private endpoints for PaaS services
- [ ] NSG/Security Groups with least privilege
- [ ] No 0.0.0.0/0 inbound (except load balancers)
- [ ] Network isolation enforced
- [ ] DDoS protection enabled (where applicable)

### Encryption
- [ ] Encryption at rest enabled
- [ ] Customer-managed keys used (where required)
- [ ] HTTPS/TLS enforced
- [ ] Minimum TLS version 1.2
- [ ] Certificate validation enabled

### IAM/RBAC
- [ ] Least privilege access
- [ ] No wildcard permissions
- [ ] Service accounts/managed identities used
- [ ] Regular access reviews planned
- [ ] MFA enforced (where applicable)

### Monitoring & Compliance
- [ ] Logging enabled
- [ ] Audit logs collected
- [ ] Security alerts configured
- [ ] Compliance policies enforced
- [ ] Regular security scans

### Code Quality (2025)
- [ ] Trivy scan passes (replaces tfsec)
- [ ] Checkov scan passes
- [ ] No high/critical findings unaddressed
- [ ] Security exceptions documented
- [ ] Code review completed
- [ ] Ephemeral values used for secrets (Terraform 1.10+)

## NIST SP 800-53 Rev 5 Compliance (2025)

HashiCorp and AWS have released 350+ pre-written Sentinel policies for NIST SP 800-53 Rev 5 compliance, making it easier to meet government and compliance requirements.

### Overview

**NIST SP 800-53 Rev 5:**
- Security and privacy controls for information systems
- Required for federal agencies and contractors
- Widely adopted for commercial compliance frameworks (FedRAMP, StateRAMP, CMMC)

**HashiCorp Sentinel for NIST:**
- Policy-as-code framework integrated with HCP Terraform
- 350+ pre-written policies covering NIST controls
- Automatic enforcement during terraform plan/apply

### Installing NIST Policies

```bash
# Clone NIST policy library
git clone https://github.com/hashicorp/policy-library-NIST-800-53

# Review available policies
cd policy-library-NIST-800-53
ls policies/
# Access Control (AC)
# Audit and Accountability (AU)
# Configuration Management (CM)
# Identification and Authentication (IA)
# System and Communications Protection (SC)
# ...and more
```

### Using NIST Policies in HCP Terraform

**1. Create Policy Set:**
```hcl
# sentinel.hcl
policy "nist-800-53-ac-2-account-management" {
  source = "./policies/access-control/ac-2.sentinel"
  enforcement_level = "advisory"  # or "soft-mandatory" or "hard-mandatory"
}

policy "nist-800-53-ac-3-access-enforcement" {
  source = "./policies/access-control/ac-3.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "nist-800-53-au-2-audit-events" {
  source = "./policies/audit/au-2.sentinel"
  enforcement_level = "soft-mandatory"
}

policy "nist-800-53-sc-7-boundary-protection" {
  source = "./policies/system-protection/sc-7.sentinel"
  enforcement_level = "hard-mandatory"
}
```

**2. Enforcement Levels:**
- **Advisory**: Log violations but allow apply
- **Soft-mandatory**: Require override to apply (approval workflow)
- **Hard-mandatory**: Block apply on violation

**3. Apply to Workspaces:**
```bash
# Via HCP Terraform UI:
# Settings → Policy Sets → Create Policy Set
# - Add NIST policies
# - Select enforcement level
# - Assign to workspaces

# Or via API/Terraform:
resource "tfe_policy_set" "nist-800-53" {
  name         = "NIST-800-53-Rev5"
  description  = "NIST SP 800-53 Rev 5 compliance policies"
  organization = var.org_name

  policy_ids = [
    tfe_sentinel_policy.ac_2.id,
    tfe_sentinel_policy.ac_3.id,
    tfe_sentinel_policy.au_2.id,
    tfe_sentinel_policy.sc_7.id,
  ]

  workspace_ids = [
    tfe_workspace.production.id,
  ]
}
```

### Example NIST Policy Checks

**AC-2: Account Management**
```sentinel
# Ensures IAM users/roles follow least privilege
import "tfplan/v2" as tfplan

# Check AWS IAM policies don't have wildcard permissions
aws_iam_policies = filter tfplan.resource_changes as _, rc {
  rc.type is "aws_iam_policy" and
  rc.change.actions contains "create"
}

violating_policies = filter aws_iam_policies as _, policy {
  policy.change.after.policy contains '"Action": "*"'
}

main = rule {
  length(violating_policies) is 0
}
```

**SC-7: Boundary Protection**
```sentinel
# Ensures security groups don't allow unrestricted inbound
import "tfplan/v2" as tfplan

security_groups = filter tfplan.resource_changes as _, rc {
  rc.type is "aws_security_group" and
  rc.change.actions contains "create"
}

violating_sgs = filter security_groups as _, sg {
  any sg.change.after.ingress as rule {
    rule.cidr_blocks contains "0.0.0.0/0"
  }
}

main = rule {
  length(violating_sgs) is 0
}
```

**AU-2: Audit Events**
```sentinel
# Ensures logging is enabled
import "tfplan/v2" as tfplan

s3_buckets = filter tfplan.resource_changes as _, rc {
  rc.type is "aws_s3_bucket"
}

buckets_without_logging = filter s3_buckets as _, bucket {
  bucket.change.after.logging is empty
}

main = rule {
  length(buckets_without_logging) is 0
}
```

### NIST Control Families Covered

| Control Family | Example Policies | Focus Area |
|---------------|------------------|------------|
| AC (Access Control) | Least privilege, MFA, role-based access | Who can access what |
| AU (Audit & Accountability) | Logging enabled, audit trail, monitoring | Tracking activities |
| CM (Configuration Management) | Baseline configs, change control | Managing changes |
| IA (Identification & Authentication) | Strong passwords, MFA, certificate management | Verifying identity |
| SC (System Protection) | Boundary protection, encryption, separation | Protecting systems |
| SI (System Integrity) | Flaw remediation, malware protection, monitoring | System health |

### CI/CD Integration with NIST Policies

```yaml
# GitHub Actions
name: NIST Compliance Check

on: [pull_request]

jobs:
  nist-compliance:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Terraform Plan
        run: terraform plan -out=tfplan

      - name: NIST Policy Check
        run: |
          # HCP Terraform runs policies automatically
          # Or run Sentinel CLI locally
          sentinel test policies/

      - name: Compliance Report
        run: |
          # Generate compliance attestation
          echo "NIST SP 800-53 Rev 5 compliance verified"
          echo "Date: $(date)" >> compliance-report.txt
          echo "Policies passed: All" >> compliance-report.txt
```

### Benefits

1. **Automated Compliance:** No manual checklist reviews
2. **Shift-Left Security:** Catch violations before deployment
3. **Audit Trail:** Policy decisions logged in HCP Terraform
4. **Cost Savings:** Reduce manual compliance reviews
5. **Consistency:** Same policies across all infrastructure

### Best Practices

1. **Start with Advisory:** Test policies before enforcement
2. **Customize Policies:** Adapt to your organization's needs
3. **Document Exceptions:** Clearly justify policy overrides
4. **Regular Reviews:** Update policies as requirements change
5. **Training:** Educate teams on NIST requirements

## Private VCS Access (2025)

Secure repository access for HCP Terraform without exposing source code or credentials over the public internet.

### Overview

**What is Private VCS Access?**
- Direct, private connection between HCP Terraform and VCS (GitHub, GitLab, Bitbucket, Azure DevOps)
- Traffic never traverses public internet
- Eliminates exposure of source code in transit
- Secures API tokens and credentials

**When to Use:**
- Enterprise security requirements
- Highly regulated industries (finance, healthcare, government)
- Zero-trust network architecture
- Organizations with private code repositories
- Compliance requirements (SOC2, ISO 27001, FedRAMP)

### Architecture

**Traditional VCS Connection:**
```
HCP Terraform → Public Internet → GitHub/GitLab/etc.
❌ Source code exposed in transit
❌ Credentials sent over internet
❌ Subject to internet threats
```

**Private VCS Access:**
```
HCP Terraform → Private Link/VPN → VCS Provider
✅ Private network connection
✅ Traffic never leaves private network
✅ End-to-end encryption
✅ No public exposure
```

### Setup for GitHub Enterprise Server

```bash
# 1. Enable private connectivity in HCP Terraform
# Settings → VCS Providers → Add VCS Provider
# Select "GitHub Enterprise" with "Private Connectivity"

# 2. Configure private endpoint
# Provide internal URL (not public)
GITHUB_URL="https://github.internal.example.com"

# 3. Set up network path
# Options:
# - AWS PrivateLink
# - Azure Private Link
# - GCP Private Service Connect
# - Site-to-site VPN
```

### Setup with AWS PrivateLink

**1. Create VPC Endpoint Service (AWS side):**
```hcl
# Network load balancer for VCS
resource "aws_lb" "vcs" {
  name               = "vcs-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnet_ids
}

# VPC Endpoint Service
resource "aws_vpc_endpoint_service" "vcs" {
  acceptance_required        = true
  network_load_balancer_arns = [aws_lb.vcs.arn]

  tags = {
    Name = "VCS Private Access"
  }
}
```

**2. Configure HCP Terraform:**
```bash
# In HCP Terraform UI:
# Settings → Network Settings → AWS PrivateLink
# - Add VPC Endpoint Service name
# - Configure allowed principals
# - Accept connection request

# Or via Terraform:
resource "tfe_organization_membership" "vcs_access" {
  organization = var.org_name
  email        = var.admin_email
}
```

**3. Update VCS Provider:**
```hcl
# Point to internal hostname
resource "tfe_oauth_client" "github_private" {
  organization     = var.org_name
  api_url          = "https://github.internal.example.com/api/v3"
  http_url         = "https://github.internal.example.com"
  oauth_token      = var.github_token
  service_provider = "github_enterprise"

  # Use private connectivity
  private_connectivity = true
}
```

### Setup with Azure Private Link

```hcl
# Azure DevOps with Private Link
resource "azurerm_private_endpoint" "ado" {
  name                = "ado-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "ado-connection"
    private_connection_resource_id = var.ado_service_id
    is_manual_connection           = false
    subresource_names              = ["Dev Azure"]
  }
}

# Configure in HCP Terraform
resource "tfe_oauth_client" "ado_private" {
  organization     = var.org_name
  api_url          = "https://dev.azure.com"
  http_url         = "https://dev.azure.com"
  oauth_token      = var.ado_token
  service_provider = "ado_server"

  private_connectivity = true
}
```

### Verify Private Connectivity

```bash
# Test connectivity
curl -I https://github.internal.example.com

# Check HCP Terraform connection status
# UI: VCS Providers → Connection Status: "Private (Connected)"

# Verify traffic doesn't traverse public internet
# Monitor network logs - should show private IPs only
```

### Security Benefits

1. **Zero Public Exposure:**
   - Source code never on public internet
   - Credentials stay private
   - API tokens not exposed

2. **Compliance:**
   - Meets zero-trust requirements
   - Satisfies data residency rules
   - Enables air-gapped environments

3. **Threat Reduction:**
   - No man-in-the-middle attacks
   - Protected from internet threats
   - Reduced attack surface

4. **Auditability:**
   - All traffic auditable
   - Clear network path
   - Logging at multiple points

### Cost Considerations

- AWS PrivateLink: ~$7.50/month per endpoint + data transfer
- Azure Private Link: Similar pricing structure
- VPN: Variable based on throughput
- Worth it for security-critical environments

### Troubleshooting

**Connection fails:**
```bash
# Check network path
# 1. Verify VPC endpoint service exists
aws ec2 describe-vpc-endpoint-services

# 2. Check security groups allow traffic
aws ec2 describe-security-groups --group-ids sg-xxx

# 3. Verify DNS resolution
nslookup github.internal.example.com

# 4. Test from HCP Terraform network
curl -v https://github.internal.example.com
```

**Performance issues:**
- Check NLB/private link bandwidth
- Verify no packet loss
- Monitor latency metrics
- Consider multi-AZ deployment

## Critical Security Warnings

- 🔴 NEVER commit secrets to version control
- 🔴 NEVER use 0.0.0.0/0 for production inbound rules
- 🔴 NEVER disable encryption
- 🔴 ALWAYS use HTTPS/TLS
- 🔴 ALWAYS enforce minimum TLS 1.2
- 🔴 ALWAYS use least privilege IAM/RBAC
- 🔴 ALWAYS enable logging and monitoring
- 🔴 ALWAYS scan infrastructure code before deployment
- 🔴 **2025:** Use Trivy instead of tfsec (tfsec merged into Trivy)
- 🔴 **2025:** Use ephemeral values for secrets (Terraform 1.10+)
- 🔴 **2025:** Use NIST Sentinel policies for government/regulated workloads
- 🔴 **2025:** Use private VCS access for sensitive repositories (HCP Terraform)
- 🔴 **2025:** Consider HYOK for full encryption key control (HCP Terraform)

## Tool Comparison 2025

| Tool | Focus | Policies | Active Development | Recommendation |
|------|-------|----------|-------------------|----------------|
| **Trivy** | Unified IaC+Containers | Hundreds | ✅ Active | **Recommended** - replaces tfsec |
| **Checkov** | Policy-as-code | 750+ | ✅ Active | Recommended |
| tfsec | Terraform-only | Hundreds | ❌ Merged into Trivy | Legacy - use Trivy |
| Terrascan | Compliance | 500+ | ✅ Active | Specialized use |
| Sentinel | HCP Terraform | Custom | ✅ Active | Enterprise |

Activate the terraform-expert agent for comprehensive security guidance.
