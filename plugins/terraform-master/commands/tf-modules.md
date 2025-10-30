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


# Manage Terraform Modules

Create, manage, and consume Terraform modules (local and remote) following best practices for reusability and maintainability.

## Your Task

You are helping with Terraform module development and usage. Determine the user's needs and provide appropriate guidance.

## Module Types

### 1. Local Modules
Modules stored in the same repository, typically in a `modules/` directory.

### 2. Remote Modules
Modules stored externally:
- **Git repositories** (GitHub, GitLab, Bitbucket, Azure Repos)
- **Terraform Registry** (Public and Private)
- **HTTP URLs**
- **S3 buckets, Azure Storage, GCS**

## Creating Local Modules

### Module Structure

```
modules/
└── my-module/
    ├── main.tf          # Primary resource definitions
    ├── variables.tf     # Input variables
    ├── outputs.tf       # Output values
    ├── versions.tf      # Provider version constraints
    ├── README.md        # Module documentation
    └── examples/        # Usage examples
        └── basic/
            ├── main.tf
            └── variables.tf
```

### Module Best Practices

**1. Module Inputs (variables.tf)**:
```hcl
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "resource_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_monitoring" {
  description = "Enable monitoring and alerting"
  type        = bool
  default     = true
}
```

**2. Module Outputs (outputs.tf)**:
```hcl
output "resource_id" {
  description = "The ID of the created resource"
  value       = azurerm_resource.example.id
}

output "resource_fqdn" {
  description = "Fully qualified domain name"
  value       = azurerm_resource.example.fqdn
  sensitive   = false  # Be explicit
}

output "connection_string" {
  description = "Database connection string"
  value       = azurerm_database.example.connection_string
  sensitive   = true  # Mark secrets as sensitive
}
```

**3. Provider Configuration**:
```hcl
# versions.tf
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.75.0, < 5.0.0"
    }
  }
}

# Do NOT include provider configuration in modules
# Let calling code configure providers
```

**4. Module Documentation**:

Use **terraform-docs** to generate documentation:
```bash
# Install terraform-docs
# Windows: choco install terraform-docs
# macOS: brew install terraform-docs
# Linux: See https://github.com/terraform-docs/terraform-docs

# Generate README
cd modules/my-module
terraform-docs markdown table . > README.md

# Or use config file
terraform-docs -c .terraform-docs.yml .
```

**.terraform-docs.yml**:
```yaml
formatter: "markdown table"

sections:
  show:
    - header
    - requirements
    - providers
    - inputs
    - outputs
    - resources

content: |-
  # {{ .Header }}

  {{ .Requirements }}

  {{ .Providers }}

  ## Usage

  ```hcl
  module "example" {
    source = "./modules/my-module"

    environment = "prod"
    # ... other variables
  }
  ```

  {{ .Inputs }}

  {{ .Outputs }}

sort:
  enabled: true
  by: name

output:
  file: "README.md"
  mode: inject
```

## Using Local Modules

**Simple Local Module**:
```hcl
module "networking" {
  source = "./modules/networking"

  environment      = var.environment
  vnet_cidr        = var.vnet_cidr
  resource_tags    = local.common_tags
}

# Reference module outputs
resource "azurerm_virtual_machine" "example" {
  subnet_id = module.networking.subnet_id
  # ...
}
```

**Module with Count**:
```hcl
module "regional_resources" {
  count  = length(var.regions)
  source = "./modules/regional-deployment"

  region        = var.regions[count.index]
  environment   = var.environment
}
```

**Module with For_Each**:
```hcl
module "application_stacks" {
  for_each = var.applications
  source   = "./modules/app-stack"

  app_name      = each.key
  app_config    = each.value
  environment   = var.environment
}

# Reference outputs
output "app_urls" {
  value = {
    for k, v in module.application_stacks : k => v.app_url
  }
}
```

## Remote Modules

### Git Repository Modules

**GitHub**:
```hcl
# Latest from main branch
module "vpc" {
  source = "git::https://github.com/org/terraform-modules.git//modules/vpc"
}

# Specific branch
module "vpc" {
  source = "git::https://github.com/org/terraform-modules.git//modules/vpc?ref=develop"
}

# Specific tag (recommended for stability)
module "vpc" {
  source = "git::https://github.com/org/terraform-modules.git//modules/vpc?ref=v1.2.3"
}

# Specific commit
module "vpc" {
  source = "git::https://github.com/org/terraform-modules.git//modules/vpc?ref=abc123"
}

# Private repo with SSH
module "vpc" {
  source = "git::ssh://git@github.com/org/terraform-modules.git//modules/vpc?ref=v1.2.3"
}
```

**Azure DevOps**:
```hcl
module "networking" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//modules/networking?ref=v1.0.0"
}

# With SSH
module "networking" {
  source = "git::ssh://git@ssh.dev.azure.com/v3/org/project/terraform-modules//modules/networking?ref=v1.0.0"
}
```

**GitLab**:
```hcl
module "compute" {
  source = "git::https://gitlab.com/org/terraform-modules.git//modules/compute?ref=v2.1.0"
}
```

### Terraform Registry Modules

**Public Registry**:
```hcl
# AWS VPC module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "my-vpc"
  cidr = "10.0.0.0/16"
  # ...
}

# Azure modules
module "resource_group" {
  source  = "Azure/resourcegroup/azurerm"
  version = "1.0.0"

  name     = "my-rg"
  location = "eastus"
}
```

**Private Registry** (Terraform Cloud/Enterprise):
```hcl
module "internal_module" {
  source  = "app.terraform.io/org/module-name/provider"
  version = "1.0.0"

  # Module inputs
}
```

### HTTP URL Modules

```hcl
module "example" {
  source = "https://example.com/terraform-modules/vpc.zip"
}
```

### Cloud Storage Modules

**Azure Blob Storage**:
```hcl
module "networking" {
  source = "azurerm://mystorageaccount.blob.core.windows.net/modules/networking.zip"
}
```

**AWS S3**:
```hcl
module "vpc" {
  source = "s3::https://s3-us-west-2.amazonaws.com/my-bucket/modules/vpc.zip"
}
```

**Google Cloud Storage**:
```hcl
module "network" {
  source = "gcs::https://www.googleapis.com/storage/v1/my-bucket/modules/network.zip"
}
```

## Module Versioning Strategies

### Semantic Versioning

Use semantic versioning for module releases:
- **Major (1.x.x)**: Breaking changes
- **Minor (x.1.x)**: New features (backward compatible)
- **Patch (x.x.1)**: Bug fixes

**Version Constraints**:
```hcl
# Exact version (not recommended except for testing)
source  = "terraform-aws-modules/vpc/aws"
version = "5.1.2"

# Pessimistic constraint (recommended)
version = "~> 5.1"  # Allows 5.1.x, but not 5.2.0

# Range
version = ">= 5.0.0, < 6.0.0"

# Latest in major version
version = "~> 5.0"  # Allows 5.x.x, but not 6.0.0
```

### Module Release Process

1. **Development**:
   ```bash
   # Create feature branch
   git checkout -b feature/add-monitoring

   # Make changes to module
   # Update examples
   # Update documentation

   # Test module
   cd examples/basic
   terraform init
   terraform plan
   ```

2. **Documentation**:
   ```bash
   # Generate updated docs
   terraform-docs markdown table . > README.md

   # Update CHANGELOG.md
   ```

3. **Testing**:
   ```bash
   # Validate
   terraform validate

   # Format
   terraform fmt -recursive

   # Security scan
   tfsec .

   # Integration tests (if using Terratest)
   cd test
   go test -v
   ```

4. **Release**:
   ```bash
   # Merge to main
   git checkout main
   git merge feature/add-monitoring

   # Tag release
   git tag -a v1.2.0 -m "Add monitoring capabilities"
   git push origin v1.2.0

   # GitHub: Create release with changelog
   ```

## Module Testing

### Basic Testing

**Example Configuration**:
```hcl
# modules/networking/examples/basic/main.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "test" {
  source = "../.."  # Point to module root

  environment   = "test"
  vnet_cidr     = "10.0.0.0/16"
  resource_tags = {
    Environment = "Test"
    ManagedBy   = "Terraform"
  }
}

output "test_output" {
  value = module.test.vnet_id
}
```

### Advanced Testing (Terratest)

**Go Test File**:
```go
// modules/networking/test/networking_test.go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestNetworkingModule(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/basic",
    }

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    vnetID := terraform.Output(t, terraformOptions, "test_output")
    assert.NotEmpty(t, vnetID)
}
```

## Module Registry (Private)

### Publishing to Private Registry

**Terraform Cloud/Enterprise**:
1. Connect VCS repository
2. Configure module registry settings
3. Tag releases (e.g., v1.0.0)
4. Registry automatically publishes tagged versions

**Module Registry Requirements**:
- Repository name format: `terraform-<PROVIDER>-<NAME>`
- Standard module structure
- Semantic versioning tags

## Module Composition

**Composing Multiple Modules**:
```hcl
# Root module that composes child modules
module "networking" {
  source = "./modules/networking"

  environment = var.environment
  vnet_cidr   = var.vnet_cidr
}

module "security" {
  source = "./modules/security"

  environment = var.environment
  vnet_id     = module.networking.vnet_id  # Pass output from networking
}

module "compute" {
  source = "./modules/compute"

  environment   = var.environment
  subnet_id     = module.networking.app_subnet_id
  nsg_id        = module.security.nsg_id
}
```

## Common Module Patterns

### 1. Resource Factory Module
Creates multiple similar resources based on input map.

### 2. Wrapper Module
Wraps provider resources with opinionated defaults.

### 3. Composition Module
Combines multiple modules into a complete solution.

### 4. Utility Module
Provides helper functions and data transformations.

## Troubleshooting

**Issue: Module not found**
```bash
# Re-initialize to download modules
terraform init -upgrade
```

**Issue: Module version conflicts**
```bash
# Check .terraform.lock.hcl
cat .terraform.lock.hcl

# Upgrade providers and modules
terraform init -upgrade
```

**Issue: Git authentication for private repos**
```bash
# Configure SSH key
ssh-add ~/.ssh/id_rsa

# Or use credential helper
git config --global credential.helper store

# Azure DevOps: Use PAT
git config --global credential.https://dev.azure.com.username "pat"
```

## Best Practices Summary

- ✅ Use semantic versioning for all modules
- ✅ Pin module versions in production (use ~> operator)
- ✅ Generate documentation with terraform-docs
- ✅ Provide usage examples for all modules
- ✅ Validate inputs with variable validation rules
- ✅ Mark sensitive outputs appropriately
- ✅ Test modules before releasing
- ✅ Use consistent naming conventions
- ✅ Avoid provider configuration in modules
- ❌ Never use latest/unversioned modules in production

Activate the terraform-expert agent for comprehensive module development guidance.
