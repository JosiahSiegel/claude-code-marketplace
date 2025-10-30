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


# Configure and Manage Terraform Providers

Configure, manage, and troubleshoot Terraform providers across all cloud platforms and community providers.

## Your Task

You are helping configure and manage Terraform providers. Assess the user's needs and provide comprehensive guidance.

## Provider Configuration Basics

### Required Providers Block

```hcl
# versions.tf
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.75"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.9"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}
```

## Major Cloud Providers

### Azure (AzureRM)

**Provider Configuration**:
```hcl
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = false
      skip_shutdown_and_force_delete = false
    }
  }

  # Optional: Specific subscription
  subscription_id = var.subscription_id

  # Optional: Skip provider registration
  skip_provider_registration = false
}
```

**Authentication Methods**:

1. **Azure CLI** (Development):
```bash
# Login
az login

# Set subscription
az account set --subscription "subscription-id"

# Terraform will use these credentials
terraform plan
```

2. **Service Principal** (CI/CD):
```bash
# Environment variables
export ARM_CLIENT_ID="xxxxx"
export ARM_CLIENT_SECRET="xxxxx"
export ARM_SUBSCRIPTION_ID="xxxxx"
export ARM_TENANT_ID="xxxxx"

# Or in provider block (not recommended)
provider "azurerm" {
  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}
```

3. **Managed Identity** (Azure VM/Container):
```hcl
provider "azurerm" {
  features {}
  use_msi = true
}
```

4. **OIDC** (GitHub Actions):
```hcl
provider "azurerm" {
  features {}
  use_oidc = true
}
```

**AzAPI Provider** (For preview features):
```hcl
provider "azapi" {
  # Uses same authentication as azurerm
}

resource "azapi_resource" "example" {
  type      = "Microsoft.Network/virtualNetworks@2023-05-01"
  parent_id = azurerm_resource_group.example.id
  name      = "example-vnet"
  location  = "eastus"

  body = jsonencode({
    properties = {
      addressSpace = {
        addressPrefixes = ["10.0.0.0/16"]
      }
    }
  })
}
```

### AWS

**Provider Configuration**:
```hcl
provider "aws" {
  region = var.aws_region

  # Optional: Profile from ~/.aws/credentials
  profile = "default"

  # Optional: Assume role
  assume_role {
    role_arn     = "arn:aws:iam::123456789:role/TerraformRole"
    session_name = "terraform-session"
  }

  # Optional: Default tags for all resources
  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}
```

**Authentication Methods**:

1. **AWS CLI** (Development):
```bash
# Configure AWS CLI
aws configure

# Or use specific profile
export AWS_PROFILE=myprofile
```

2. **Environment Variables** (CI/CD):
```bash
export AWS_ACCESS_KEY_ID="xxxxx"
export AWS_SECRET_ACCESS_KEY="xxxxx"
export AWS_DEFAULT_REGION="us-east-1"
```

3. **IAM Role** (EC2 Instance):
```hcl
provider "aws" {
  region = "us-east-1"
  # Automatically uses instance profile
}
```

4. **OIDC** (GitHub Actions):
```yaml
# GitHub Actions workflow
- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v2
  with:
    role-to-assume: arn:aws:iam::123456789:role/GitHubActionsRole
    aws-region: us-east-1

- name: Terraform Apply
  run: terraform apply
```

**Multiple AWS Regions/Accounts**:
```hcl
# Default provider
provider "aws" {
  region = "us-east-1"
  alias  = "primary"
}

# Secondary region
provider "aws" {
  region = "us-west-2"
  alias  = "secondary"
}

# Cross-account
provider "aws" {
  region = "us-east-1"
  alias  = "production"

  assume_role {
    role_arn = "arn:aws:iam::prod-account:role/TerraformRole"
  }
}

# Use aliased providers
resource "aws_s3_bucket" "primary" {
  provider = aws.primary
  bucket   = "my-bucket-primary"
}

resource "aws_s3_bucket" "secondary" {
  provider = aws.secondary
  bucket   = "my-bucket-secondary"
}
```

### Google Cloud (GCP)

**Provider Configuration**:
```hcl
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone

  # Optional: Service account key file
  credentials = file("service-account-key.json")

  # Optional: User project override
  user_project_override = true
  billing_project       = var.billing_project
}
```

**Authentication Methods**:

1. **gcloud CLI** (Development):
```bash
# Login
gcloud auth application-default login

# Set project
gcloud config set project PROJECT_ID
```

2. **Service Account Key** (CI/CD):
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
```

3. **Workload Identity** (GKE):
```hcl
provider "google" {
  project = var.project_id
  region  = var.region
}
```

## Community Providers

### Kubernetes

```hcl
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.example.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.cluster_ca_certificate)
}

# Or use kubeconfig file
provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "my-context"
}
```

### Helm

```hcl
provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.example.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.cluster_ca_certificate)
  }
}
```

### Datadog

```hcl
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.datadoghq.com/"  # US site
}
```

### PagerDuty

```hcl
provider "pagerduty" {
  token = var.pagerduty_token
}
```

### GitHub

```hcl
provider "github" {
  token = var.github_token
  owner = var.github_org
}
```

### GitLab

```hcl
provider "gitlab" {
  token    = var.gitlab_token
  base_url = "https://gitlab.com/api/v4/"  # Or self-hosted URL
}
```

## Provider Version Management

### Lock File

**terraform.lock.hcl**:
```hcl
# This file is maintained by "terraform init"
provider "registry.terraform.io/hashicorp/azurerm" {
  version     = "3.75.0"
  constraints = "~> 3.75"
  hashes = [
    "h1:abc...",
    "zh:123...",
  ]
}
```

**Lock File Operations**:
```bash
# Create/update lock file
terraform init

# Upgrade providers within constraints
terraform init -upgrade

# Upgrade specific provider
terraform init -upgrade=hashicorp/azurerm
```

### Version Constraints

**Constraint Operators**:
```hcl
# Exact version
version = "3.75.0"

# Greater than or equal
version = ">= 3.75.0"

# Pessimistic constraint (~>)
version = "~> 3.75"    # Allows 3.75.x, not 3.76.0
version = "~> 3.75.0"  # Allows 3.75.x, not 3.76.0

# Range
version = ">= 3.70.0, < 4.0.0"

# Multiple constraints
version = "~> 3.75, != 3.75.1"  # Allow 3.75.x except 3.75.1
```

### Upgrading Providers

**Check for Updates**:
```bash
# See available updates
terraform providers

# Check outdated providers (if using Terraform Cloud)
terraform version

# Manually check provider releases
# - GitHub releases
# - Terraform Registry
```

**Upgrade Process**:
```bash
# 1. Review CHANGELOG for breaking changes
#    https://github.com/hashicorp/terraform-provider-azurerm/blob/main/CHANGELOG.md

# 2. Update version constraint
# versions.tf: version = "~> 3.80"

# 3. Upgrade and update lock file
terraform init -upgrade

# 4. Test with plan
terraform plan

# 5. Check for deprecation warnings
# 6. Update code if needed
# 7. Test in non-production first
```

## Provider Plugin Cache

**Enable Plugin Cache** (Improves init performance):

**Windows PowerShell**:
```powershell
# Set environment variable
$env:TF_PLUGIN_CACHE_DIR = "$HOME\.terraform.d\plugin-cache"
New-Item -ItemType Directory -Force -Path $env:TF_PLUGIN_CACHE_DIR

# Or add to PowerShell profile
```

**Linux/macOS**:
```bash
# Add to ~/.bashrc or ~/.zshrc
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
mkdir -p $TF_PLUGIN_CACHE_DIR
```

**Benefits**:
- Faster `terraform init`
- Reduced downloads
- Shared cache across projects

## Multi-Provider Scenarios

### Multi-Cloud Deployment

```hcl
# versions.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.75"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Configure all providers
provider "azurerm" {
  features {}
}

provider "aws" {
  region = "us-east-1"
}

provider "google" {
  project = var.gcp_project
  region  = "us-central1"
}

# Use resources from all providers
resource "azurerm_resource_group" "example" {
  name     = "my-rg"
  location = "East US"
}

resource "aws_s3_bucket" "example" {
  bucket = "my-bucket"
}

resource "google_storage_bucket" "example" {
  name     = "my-gcs-bucket"
  location = "US"
}
```

## Provider Aliasing

**Use Case**: Multiple regions, accounts, or configurations

```hcl
provider "azurerm" {
  alias           = "primary"
  subscription_id = var.primary_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "secondary"
  subscription_id = var.secondary_subscription_id
  features {}
}

resource "azurerm_resource_group" "primary" {
  provider = azurerm.primary
  name     = "primary-rg"
  location = "East US"
}

resource "azurerm_resource_group" "secondary" {
  provider = azurerm.secondary
  name     = "secondary-rg"
  location = "West Europe"
}

# In modules
module "networking" {
  source = "./modules/networking"

  providers = {
    azurerm = azurerm.primary
  }
}
```

## Troubleshooting

### Common Issues

**Issue: Provider not found**
```bash
Error: Could not load plugin

# Solution: Run terraform init
terraform init
```

**Issue: Version constraint conflict**
```bash
Error: Failed to query available provider packages

# Solution: Check and adjust version constraints
# Review required_providers blocks
# Ensure compatibility between modules
```

**Issue: Authentication failure**
```bash
# Azure
az account show  # Verify logged in
az account set --subscription "xxxxx"

# AWS
aws sts get-caller-identity  # Verify credentials

# GCP
gcloud auth application-default login
```

**Issue: Rate limiting**
```bash
# Adjust parallelism
terraform apply -parallelism=5

# For GitHub provider
provider "github" {
  token = var.github_token

  # Add retry logic
  max_retries = 3
}
```

## Provider Development

### Custom Provider Usage

```hcl
terraform {
  required_providers {
    custom = {
      source  = "mycorp.com/custom/provider"
      version = "1.0.0"
    }
  }
}
```

### Local Provider Development

```bash
# Build provider
go build -o terraform-provider-custom

# Copy to plugin directory
# Linux/macOS
mkdir -p ~/.terraform.d/plugins/mycorp.com/custom/provider/1.0.0/linux_amd64
cp terraform-provider-custom ~/.terraform.d/plugins/mycorp.com/custom/provider/1.0.0/linux_amd64/

# Windows
mkdir -p %APPDATA%\terraform.d\plugins\mycorp.com\custom\provider\1.0.0\windows_amd64
copy terraform-provider-custom %APPDATA%\terraform.d\plugins\mycorp.com\custom\provider\1.0.0\windows_amd64\
```

## Best Practices

- ✅ Always pin provider versions in production
- ✅ Use version constraints (~>) for flexibility
- ✅ Keep providers up-to-date (review changelogs)
- ✅ Use provider aliases for multi-region/account
- ✅ Enable plugin cache for faster init
- ✅ Store credentials securely (not in code)
- ✅ Use managed identities/OIDC when possible
- ✅ Test provider upgrades in non-production first
- ✅ Review provider deprecation notices
- ❌ Never commit credentials to version control
- ❌ Never use latest/unpinned versions in production

Activate the terraform-expert agent for provider-specific guidance and troubleshooting.
