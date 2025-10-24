# Terraform Security and Best Practices

Implement comprehensive security scanning, compliance validation, and security best practices for Terraform infrastructure.

## Your Task

You are helping secure Terraform infrastructure. Provide security guidance, scanning, and compliance validation.

## Security Scanning Tools

### 1. tfsec (Static Security Scanner)

**Installation**:
```bash
# Windows (Chocolatey)
choco install tfsec

# macOS (Homebrew)
brew install tfsec

# Linux
curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash

# Or download binary from: https://github.com/aquasecurity/tfsec/releases
```

**Basic Usage**:
```bash
# Scan current directory
tfsec .

# Scan specific directory
tfsec /path/to/terraform

# Scan with minimum severity
tfsec . --minimum-severity HIGH
tfsec . --minimum-severity CRITICAL

# Output formats
tfsec . --format json
tfsec . --format junit
tfsec . --format sarif
tfsec . --format html > tfsec-report.html

# Scan with specific checks only
tfsec . --include-rule azure-storage-use-secure-tls-policy

# Exclude specific checks
tfsec . --exclude aws-s3-enable-bucket-logging
```

**Inline Ignore**:
```hcl
resource "aws_s3_bucket" "example" {
  #tfsec:ignore:aws-s3-enable-versioning
  bucket = "my-bucket"
  # Versioning not required for temporary bucket
}

# Or with expiry date
resource "azurerm_storage_account" "example" {
  #tfsec:ignore:azure-storage-use-secure-tls-policy:exp:2024-12-31
  name = "example"
  # TLS 1.0 required for legacy client, upgrading by EOY
}
```

**.tfsec.yml Configuration**:
```yaml
# .tfsec/config.yml
severity_overrides:
  azure-storage-use-secure-tls-policy: ERROR

exclude:
  - aws-s3-enable-bucket-logging  # Global exclude

minimum_severity: MEDIUM
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

### GitHub Actions

```yaml
name: Security Scan

on: [pull_request]

jobs:
  tfsec:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: tfsec
        uses: aquasecurity/tfsec-action@v1.0.0
        with:
          soft_fail: false
          format: sarif
          additional_args: --minimum-severity HIGH

      - name: Upload SARIF
        uses: github/codeql-action/upload-sarif@v2
        if: always()
        with:
          sarif_file: tfsec.sarif

  checkov:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Checkov
        uses: bridgecrewio/checkov-action@master
        with:
          directory: .
          framework: terraform
          soft_fail: false
          output_format: sarif
          output_file_path: checkov.sarif

      - name: Upload SARIF
        uses: github/codeql-action/upload-sarif@v2
        if: always()
        with:
          sarif_file: checkov.sarif
```

### Azure DevOps

```yaml
- stage: SecurityScan
  jobs:
  - job: tfsec
    steps:
    - task: Bash@3
      displayName: 'Run tfsec'
      inputs:
        targetType: 'inline'
        script: |
          curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
          tfsec . --format junit > tfsec-results.xml
      continueOnError: false

    - task: PublishTestResults@2
      displayName: 'Publish tfsec Results'
      condition: always()
      inputs:
        testResultsFormat: 'JUnit'
        testResultsFiles: 'tfsec-results.xml'

  - job: checkov
    steps:
    - task: UsePythonVersion@0
      inputs:
        versionSpec: '3.x'

    - script: |
        pip install checkov
        checkov -d . --framework terraform -o junitxml > checkov-results.xml
      displayName: 'Run Checkov'
      continueOnError: false

    - task: PublishTestResults@2
      displayName: 'Publish Checkov Results'
      condition: always()
      inputs:
        testResultsFormat: 'JUnit'
        testResultsFiles: 'checkov-results.xml'
```

## Pre-Commit Hooks

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.86.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
      - id: terraform_tfsec
        args:
          - --args=--minimum-severity=MEDIUM
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

### Code Quality
- [ ] tfsec scan passes
- [ ] Checkov scan passes
- [ ] No high/critical findings unaddressed
- [ ] Security exceptions documented
- [ ] Code review completed

## Critical Security Warnings

- 🔴 NEVER commit secrets to version control
- 🔴 NEVER use 0.0.0.0/0 for production inbound rules
- 🔴 NEVER disable encryption
- 🔴 ALWAYS use HTTPS/TLS
- 🔴 ALWAYS enforce minimum TLS 1.2
- 🔴 ALWAYS use least privilege IAM/RBAC
- 🔴 ALWAYS enable logging and monitoring
- 🔴 ALWAYS scan infrastructure code before deployment

Activate the terraform-expert agent for comprehensive security guidance.
