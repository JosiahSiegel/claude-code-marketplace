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


# Terraform Module Registry and Distribution

Implement private module registries, manage module lifecycle, enable no-code provisioning, and establish enterprise module governance for scalable infrastructure delivery.

## Your Task

You are helping implement Terraform module registry and distribution strategies. Provide registry setup, module governance, and no-code provisioning implementation.

## Registry Types Overview

### 1. HCP Terraform Private Registry (Recommended)

**Features:**
- Native integration with HCP Terraform/Enterprise
- Module versioning and lifecycle management
- No-code provisioning support
- Module curation and governance
- VCS integration (GitHub, GitLab, Bitbucket, Azure DevOps)
- Access control and permissions
- Module usage analytics
- Compliance enforcement

**When to Use:**
- Enterprise organizations
- Multi-team environments
- Governance requirements
- No-code self-service needs
- Already using HCP Terraform

### 2. Terraform Public Registry

**Features:**
- Community modules
- Provider documentation
- Verified modules
- Public sharing

**When to Use:**
- Open source modules
- Community contribution
- Public documentation
- Standard providers

### 3. Self-Hosted Private Registries

**Options:**
- Citizen (Community)
- Terraform Enterprise (HashiCorp)
- Custom implementations

**When to Use:**
- Air-gapped environments
- Strict security requirements
- Custom integration needs
- Budget constraints

## HCP Terraform Private Registry Setup

### Adding Modules to Private Registry

**Via VCS Connection:**

1. **Connect VCS Provider**:
```
HCP Terraform > Organization Settings > VCS Providers > Add VCS Provider
```

2. **Publish Module**:
```
Registry > Publish > Module > Connect to VCS
```

3. **Configure Module**:
- Repository: `my-org/terraform-azure-networking`
- Module Name: `networking`
- Provider: `azure`
- VCS Branch: `main` (or tags for versions)

**Module Structure (Required):**
```
terraform-azure-networking/
├── main.tf
├── variables.tf
├── outputs.tf
├── README.md
├── LICENSE
└── examples/
    └── complete/
        ├── main.tf
        └── README.md
```

### Module Versioning

**Git Tags (Recommended):**
```bash
# Tag module version
git tag -a v1.0.0 -m "Initial release"
git push origin v1.0.0

# HCP Terraform automatically creates registry version v1.0.0
```

**Semantic Versioning:**
- **Major (v2.0.0)**: Breaking changes
- **Minor (v1.1.0)**: New features, backward compatible
- **Patch (v1.0.1)**: Bug fixes

### Using Private Registry Modules

```hcl
# main.tf

terraform {
  required_version = ">= 1.5.0"

  cloud {
    organization = "my-org"
    workspaces {
      name = "infrastructure"
    }
  }
}

# Use private registry module
module "networking" {
  source  = "app.terraform.io/my-org/networking/azure"
  version = "~> 2.0"

  vnet_name           = "prod-vnet"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}
```

**Version Constraints:**
```hcl
# Exact version
version = "1.0.0"

# Minimum version
version = ">= 1.0.0"

# Pessimistic constraint (recommended)
version = "~> 2.0"  # >= 2.0.0, < 3.0.0
version = "~> 2.1"  # >= 2.1.0, < 3.0.0
```

## Module Governance and Curation

### Module Publishing Policy

**Approval Workflow:**

1. **Module Development**: Developer creates module in VCS
2. **Testing**: Module passes automated tests (terraform test, Terratest)
3. **Security Scan**: Trivy/Checkov validation passes
4. **Documentation**: README, inputs/outputs documented
5. **Review**: Platform team reviews module
6. **Approval**: Approved for publishing
7. **Publish**: Module published to private registry
8. **Announce**: Team notified of new module

### Sentinel Policy for Registry Control

```hcl
# policy/restrict-module-sources.sentinel

import "tfconfig/v2" as tfconfig

# Allowed module sources
allowed_sources = [
  "app.terraform.io/my-org/",
  "./modules/",
  "../shared-modules/"
]

# Get all module calls
all_modules = tfconfig.module_calls

# Check module sources
unauthorized_modules = filter all_modules as address, module {
  all allowed_sources as source {
    not strings.has_prefix(module.source, source)
  }
}

main = rule {
  length(unauthorized_modules) is 0
}
```

### Module Deprecation Policy

**Deprecation Process:**

1. **Announce**: 90-day notice to teams
2. **Mark**: Update module description with deprecation notice
3. **Provide Alternative**: Document replacement module
4. **Monitor Usage**: Track module usage
5. **Remove**: After 90 days, archive module

**Deprecation Notice:**
```hcl
# modules/legacy-networking/README.md

# ⚠️ DEPRECATED - Use `networking` module instead

This module is deprecated and will be removed on 2026-03-01.

**Migration Path:**
- Replace: `source = "app.terraform.io/my-org/legacy-networking/azure"`
- With: `source = "app.terraform.io/my-org/networking/azure"`
- See: [Migration Guide](https://docs.example.com/migrate-networking)
```

### Module Standards Enforcement

**Required Module Components:**

1. **README.md**: Purpose, usage, examples
2. **variables.tf**: All inputs with descriptions
3. **outputs.tf**: All outputs with descriptions
4. **versions.tf**: Terraform and provider versions
5. **main.tf**: Primary resources
6. **examples/**: At least one complete example
7. **LICENSE**: Module license
8. **CHANGELOG.md**: Version history

**Module Validation CI/CD:**

```yaml
# .github/workflows/module-validation.yml

name: Module Validation

on:
  pull_request:
    paths:
      - 'modules/**'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.14.0

      - name: Terraform Format Check
        run: terraform fmt -check -recursive

      - name: Terraform Validate
        run: |
          cd modules/networking
          terraform init -backend=false
          terraform validate

      - name: Security Scan
        run: trivy config modules/networking

      - name: Generate Documentation
        uses: terraform-docs/gh-actions@v1.0.0
        with:
          working-dir: modules/networking
          output-file: README.md
          fail-on-diff: true

      - name: Run Tests
        run: |
          cd modules/networking
          terraform test
```

## No-Code Provisioning

### Creating No-Code Ready Modules

**Module Design Principles:**

1. **Sensible Defaults**: Pre-configure common settings
2. **Clear Descriptions**: Help non-technical users
3. **Validation**: Prevent invalid configurations
4. **Limited Options**: Reduce complexity
5. **Safe Defaults**: Security by default

**Example No-Code Module:**

```hcl
# modules/no-code-database/variables.tf

variable "database_name" {
  type        = string
  description = "Database name (3-20 lowercase letters and numbers only)"

  validation {
    condition     = can(regex("^[a-z0-9]{3,20}$", var.database_name))
    error_message = "Database name must be 3-20 lowercase alphanumeric characters."
  }
}

variable "environment" {
  type        = string
  description = "Environment (dev, staging, or prod)"
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "tier" {
  type        = string
  description = "Database tier"
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.tier)
    error_message = "Tier must be Basic, Standard, or Premium."
  }
}

variable "backup_enabled" {
  type        = bool
  description = "Enable automated backups"
  default     = true
}

variable "high_availability" {
  type        = bool
  description = "Enable high availability (prod only)"
  default     = false

  validation {
    condition     = var.environment == "prod" ? var.high_availability : true
    error_message = "High availability requires prod environment."
  }
}
```

```hcl
# modules/no-code-database/main.tf

locals {
  # Security defaults
  enable_ssl              = true
  minimum_tls_version     = "TLS1_2"
  public_network_access   = var.environment == "dev" ? true : false
  firewall_rules_enabled  = true

  # Naming convention
  name_prefix = "${var.environment}-${var.database_name}"

  # Tagging
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Module      = "no-code-database"
    Tier        = var.tier
  }
}

resource "azurerm_postgresql_flexible_server" "main" {
  name                = "${local.name_prefix}-db"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku_name   = local.sku_map[var.tier]
  storage_mb = local.storage_map[var.tier]
  version    = "14"

  # Security settings
  public_network_access_enabled = local.public_network_access
  ssl_enforcement_enabled       = local.enable_ssl

  backup_retention_days        = var.backup_enabled ? 7 : null
  geo_redundant_backup_enabled = var.high_availability

  tags = local.common_tags
}
```

### Enabling No-Code Provisioning

**HCP Terraform Configuration:**

1. **Mark Module as No-Code Ready**:
```
Registry > Module > Settings > No-Code Provisioning > Enable
```

2. **Configure Variable Groups**:
```json
{
  "variable_options": [
    {
      "name": "environment",
      "type": "string",
      "options": ["dev", "staging", "prod"]
    },
    {
      "name": "tier",
      "type": "string",
      "options": ["Basic", "Standard", "Premium"]
    }
  ]
}
```

3. **Set Permissions**:
```
Organization Settings > Teams > Developers
- Allow no-code provisioning
- Restrict to specific modules
```

### No-Code User Experience

**Workspace Creation:**

1. User navigates to HCP Terraform
2. Clicks "New Workspace" > "No-Code Provisioning"
3. Selects module: "Database (PostgreSQL)"
4. Fills form with validated inputs:
   - Database name: `myapp`
   - Environment: `dev` (dropdown)
   - Tier: `Standard` (dropdown)
   - Backup enabled: ✓ (checkbox)
5. Clicks "Create workspace"
6. HCP Terraform runs plan automatically
7. User reviews plan, clicks "Apply"
8. Database provisioned

**Benefits:**
- No Terraform knowledge required
- Governed by platform team
- Consistent configurations
- Self-service provisioning
- Reduced ticket volume

## Module Lifecycle Management (GA 2025)

### Module Revocation

**Revoke Compromised Module:**

```
HCP Terraform > Registry > Module > Versions > v1.2.3 > Revoke

Reason: Security vulnerability CVE-2025-12345
Action: Revoked (workspaces prevented from using this version)
```

**Automated Detection:**
- CVE scanning
- Supply chain attack detection
- Malicious code patterns
- Dependency vulnerabilities

**Revocation Impact:**
- Existing workspaces: Continue functioning
- New workspaces: Cannot use revoked version
- Updates: Prevented from upgrading to revoked version
- Notifications: Teams notified of revocation

### Version Pinning Strategy

**Development Environment:**
```hcl
# Use latest minor version
module "networking" {
  source  = "app.terraform.io/my-org/networking/azure"
  version = "~> 2.1"  # Get bug fixes automatically
}
```

**Staging Environment:**
```hcl
# Pin to specific minor version
module "networking" {
  source  = "app.terraform.io/my-org/networking/azure"
  version = "2.1.0"  # Test specific version
}
```

**Production Environment:**
```hcl
# Pin to exact version
module "networking" {
  source  = "app.terraform.io/my-org/networking/azure"
  version = "2.1.0"  # Stability over updates
}
```

## Self-Hosted Private Registries

### Citizen (Open Source)

**Features:**
- Protocol-compliant Terraform registry
- VCS integration
- Module versioning
- Storage backends (S3, GCS, Azure Blob)

**Installation:**
```bash
# Docker deployment
docker run -d \
  -p 3000:3000 \
  -e CITIZEN_STORAGE_TYPE=s3 \
  -e CITIZEN_STORAGE_S3_BUCKET=my-terraform-modules \
  -e CITIZEN_STORAGE_S3_REGION=us-east-1 \
  outsideris/citizen:latest
```

**Module Usage:**
```hcl
module "networking" {
  source  = "registry.example.com/my-org/networking/azure"
  version = "~> 2.0"
}
```

### Terraform Enterprise

**Features:**
- Full enterprise features
- Private registry included
- Air-gapped support
- SAML SSO
- Audit logging
- Advanced governance

**Deployment:**
- Replicated installation
- Kubernetes deployment
- Active/active clustering

## Module Documentation Best Practices

### terraform-docs Integration

**.terraform-docs.yml:**
```yaml
# .terraform-docs.yml

formatter: markdown table

version: ""

header-from: header.md
footer-from: footer.md

sections:
  show:
    - header
    - requirements
    - providers
    - inputs
    - outputs
    - resources
    - modules

content: |-
  {{ .Header }}

  ## Requirements

  {{ .Requirements }}

  ## Providers

  {{ .Providers }}

  ## Inputs

  {{ .Inputs }}

  ## Outputs

  {{ .Outputs }}

  ## Resources

  {{ .Resources }}

  {{ .Footer }}

output:
  file: README.md
  mode: inject
  template: |-
    <!-- BEGIN_TF_DOCS -->
    {{ .Content }}
    <!-- END_TF_DOCS -->

sort:
  enabled: true
  by: name

settings:
  anchor: true
  color: true
  default: true
  description: true
  escape: true
  html: true
  indent: 2
  lockfile: true
  read-comments: true
  required: true
  sensitive: true
  type: true
```

**Generate Documentation:**
```bash
# Generate README
terraform-docs markdown table . > README.md

# With config file
terraform-docs .

# CI/CD integration
terraform-docs --config .terraform-docs.yml .
```

### Module README Template

```markdown
# Azure Networking Module

Provisions Azure Virtual Network with subnets, NSGs, and route tables.

## Usage

```hcl
module "networking" {
  source  = "app.terraform.io/my-org/networking/azure"
  version = "~> 2.0"

  vnet_name           = "prod-vnet"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  subnets = {
    web = {
      address_prefix = "10.0.1.0/24"
      service_endpoints = ["Microsoft.Storage"]
    }
    app = {
      address_prefix = "10.0.2.0/24"
      service_endpoints = ["Microsoft.Sql"]
    }
  }
}
```

## Examples

- [Complete](./examples/complete) - Full networking setup
- [Simple](./examples/simple) - Minimal configuration

<!-- BEGIN_TF_DOCS -->
<!-- Generated by terraform-docs -->
<!-- END_TF_DOCS -->

## Changelog

See [CHANGELOG.md](./CHANGELOG.md)

## License

MIT
```

## Module Testing

### Terratest Example

```go
// test/networking_test.go

package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestNetworkingModule(t *testing.T) {
    t.Parallel()

    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../examples/complete",
        Vars: map[string]interface{}{
            "vnet_name": "test-vnet",
            "location":  "eastus",
        },
    })

    defer terraform.Destroy(t, terraformOptions)

    terraform.InitAndApply(t, terraformOptions)

    vnetID := terraform.Output(t, terraformOptions, "vnet_id")
    assert.NotEmpty(t, vnetID)
}
```

## Platform-Specific Considerations

### Windows
```powershell
# Generate docs
terraform-docs markdown table . | Out-File -Encoding utf8 README.md

# Run tests
go test -v ./test/
```

### Linux/macOS
```bash
# Generate docs
terraform-docs markdown table . > README.md

# Run tests
go test -v ./test/
```

## Best Practices

### Module Design
1. **Single Responsibility**: One module, one purpose
2. **Composability**: Modules should work together
3. **Versioning**: Semantic versioning strictly
4. **Testing**: Automated tests required
5. **Documentation**: Complete and accurate

### Registry Management
1. **Access Control**: Restrict publishing permissions
2. **Approval Process**: Review before publishing
3. **Deprecation Policy**: Clear timeline
4. **Security Scanning**: Automated vulnerability detection
5. **Usage Tracking**: Monitor module adoption

### No-Code Provisioning
1. **Curated Modules**: Only publish tested modules
2. **Clear Descriptions**: Non-technical language
3. **Validation**: Prevent user errors
4. **Sensible Defaults**: Secure by default
5. **Training**: Educate users on self-service

## Troubleshooting

### Module Not Found
```bash
# Clear module cache
rm -rf .terraform/modules

# Re-initialize
terraform init

# Check authentication
terraform login
```

### Version Constraints
```bash
# Check available versions
terraform providers lock -upgrade

# Debug version resolution
terraform init -upgrade
```

### Registry Authentication
```bash
# HCP Terraform login
terraform login

# Custom registry credentials
# Add to ~/.terraformrc or terraform.rc
credentials "registry.example.com" {
  token = "xxxxxx"
}
```

## Resources

- [HCP Terraform Private Registry](https://developer.hashicorp.com/terraform/cloud-docs/registry)
- [Module Lifecycle Management](https://developer.hashicorp.com/terraform/cloud-docs/registry/module-lifecycle)
- [No-Code Provisioning](https://developer.hashicorp.com/terraform/cloud-docs/no-code-provisioning)
- [Citizen Registry](https://github.com/outsideris/citizen)
- [terraform-docs](https://terraform-docs.io/)
- [Module Best Practices](https://developer.hashicorp.com/terraform/language/modules/develop)
