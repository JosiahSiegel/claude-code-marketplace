---
description: Work with Terraform Stacks for enterprise-scale infrastructure provisioning
---

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

# Terraform Stacks

## Purpose
Use Terraform Stacks (GA 2025) to rapidly create consistent infrastructure with differing inputs across multiple deployments through a single action.

## Overview

**What are Terraform Stacks?**
- **Generally Available (GA)** in 2025 for all HCP Terraform plans based on resources under management (RUM)
- Announced at HashiConf 2025
- Simplifies infrastructure provisioning at scale
- Deploys multiple instances of infrastructure with different configurations
- Single action to provision consistent infrastructure across environments/regions/accounts
- Native support in HCP Terraform only (not Terraform CLI standalone)

**When to Use:**
- Multi-region deployments with same infrastructure pattern
- Multi-account/multi-tenant infrastructure
- Multiple environments (dev/staging/prod) with slight variations
- Enterprise-scale infrastructure standardization
- Rapid infrastructure replication with different inputs

**When NOT to Use:**
- Single deployment scenarios (use standard Terraform)
- Highly divergent infrastructure per deployment
- Simple workspace-based deployments may be sufficient
- CLI-only workflows (Stacks require HCP Terraform)

## New Features in 2025 GA Release

### Linked Stacks
- **Cross-Stack Dependency Management**: Securely share outputs from upstream stacks to downstream stacks
- **Automatic Triggers**: HCP Terraform automatically triggers updates in downstream stacks when upstream outputs change
- **Simplified Dependencies**: No manual coordination needed between related stacks

### Unified CLI Experience
- **Backward-Compatible APIs**: Safe integration into CI/CD pipelines
- **Command-Line Management**: Create, manage, and iterate on stacks directly from CLI
- **Version Guarantees**: API stability for production workflows

### Expanded VCS Support
- **All Major Providers**: GitHub, GitLab, Azure DevOps, Bitbucket
- **Private VCS Access**: Secure repository connections without public internet exposure
- **Enterprise Integration**: Seamless integration with enterprise VCS systems

### Self-Hosted Agents
- **Private Infrastructure**: Execute deployments behind firewalls
- **Air-Gapped Environments**: Support for isolated networks
- **Compliance Requirements**: Meet security and compliance standards for sensitive workloads
- **Custom Execution Environments**: Control over execution environment

### Custom Deployment Groups (HCP Terraform Premium)
- **Auto-Approve Checks**: Automated approval workflows
- **Phased Rollouts**: Control deployment sequencing
- **Group-Level Policies**: Apply policies to deployment groups

### Deferred Changes
- **Partial Plans**: Terraform produces partial plans when encountering unknown values
- **Improved Performance**: Operations don't halt on unknowns
- **Better User Experience**: More informative planning process

## Key Concepts

### Stack vs Traditional Terraform

**Traditional Approach:**
```
workspace-dev/
  main.tf
  variables.tf
  terraform.tfvars

workspace-staging/
  main.tf  (duplicated)
  variables.tf  (duplicated)
  terraform.tfvars  (different values)

workspace-prod/
  main.tf  (duplicated)
  variables.tf  (duplicated)
  terraform.tfvars  (different values)
```
Problem: Code duplication, manual per-environment management

**Stacks Approach:**
```
stack/
  stack.tfstack  # Stack configuration
  main.tf        # Shared infrastructure code
  variables.tf   # Shared variables

deployments.tfdeploy.hcl  # All deployment configurations
```
Benefit: Single source of truth, deploy all at once

### Stack Components

1. **Stack Configuration (`.tfstack`):**
   - Defines the infrastructure template
   - References modules and providers
   - Declares inputs and outputs

2. **Deployment Configuration (`.tfdeploy.hcl`):**
   - Defines multiple deployments
   - Specifies input values per deployment
   - Controls orchestration order

3. **Components:**
   - Reusable infrastructure modules
   - Called by stack configuration
   - Receive deployment-specific inputs

## Creating a Terraform Stack

### 1. Stack Configuration File

Create `stack.tfstack`:
```hcl
# Terraform Stacks configuration
stack {
  name        = "multi-region-app"
  description = "Deploy application across multiple regions"
}

# Required providers
required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 5.0"
  }
}

# Input variables for the stack
variable "region" {
  type        = string
  description = "AWS region"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "instance_count" {
  type        = number
  description = "Number of instances"
  default     = 2
}

# Component: VPC
component "vpc" {
  source = "./modules/vpc"

  inputs = {
    region      = var.region
    environment = var.environment
    cidr_block  = "10.0.0.0/16"
  }

  providers = {
    aws = provider.aws.this
  }
}

# Component: Application
component "application" {
  source = "./modules/application"

  inputs = {
    region         = var.region
    environment    = var.environment
    vpc_id         = component.vpc.vpc_id
    subnet_ids     = component.vpc.private_subnet_ids
    instance_count = var.instance_count
  }

  providers = {
    aws = provider.aws.this
  }

  # Dependency on VPC component
  depends_on = [component.vpc]
}

# Provider configuration per deployment
provider "aws" "this" {
  config {
    region = var.region
  }
}

# Stack outputs
output "app_url" {
  value       = component.application.url
  description = "Application URL"
}

output "vpc_id" {
  value = component.vpc.vpc_id
}
```

### 2. Deployment Configuration File

Create `deployments.tfdeploy.hcl`:
```hcl
# Define multiple deployments of the stack

# Development deployment - US East
deployment "dev-us-east" {
  inputs = {
    region         = "us-east-1"
    environment    = "dev"
    instance_count = 1
  }
}

# Development deployment - EU West
deployment "dev-eu-west" {
  inputs = {
    region         = "eu-west-1"
    environment    = "dev"
    instance_count = 1
  }
}

# Staging deployments
deployment "staging-us-east" {
  inputs = {
    region         = "us-east-1"
    environment    = "staging"
    instance_count = 2
  }
}

deployment "staging-eu-west" {
  inputs = {
    region         = "eu-west-1"
    environment    = "staging"
    instance_count = 2
  }
}

# Production deployments
deployment "prod-us-east" {
  inputs = {
    region         = "us-east-1"
    environment    = "prod"
    instance_count = 4
  }
}

deployment "prod-eu-west" {
  inputs = {
    region         = "eu-west-1"
    environment    = "prod"
    instance_count = 4
  }
}

deployment "prod-ap-south" {
  inputs = {
    region         = "ap-south-1"
    environment    = "prod"
    instance_count = 4
  }
}

# Orchestration: control deployment order
orchestrate {
  # Deploy dev environments first
  group "development" {
    deployments = [
      deployment.dev-us-east,
      deployment.dev-eu-west,
    ]
  }

  # Then staging
  group "staging" {
    deployments = [
      deployment.staging-us-east,
      deployment.staging-eu-west,
    ]
    depends_on = [group.development]
  }

  # Finally production
  group "production" {
    deployments = [
      deployment.prod-us-east,
      deployment.prod-eu-west,
      deployment.prod-ap-south,
    ]
    depends_on = [group.staging]
  }
}
```

### 3. Module Structure

Organize reusable modules:
```
project/
  stack.tfstack
  deployments.tfdeploy.hcl
  modules/
    vpc/
      main.tf
      variables.tf
      outputs.tf
    application/
      main.tf
      variables.tf
      outputs.tf
```

## Working with Stacks

### Initialize Stack

```bash
# Initialize the stack (HCP Terraform)
terraform stack init

# Validate stack configuration
terraform stack validate
```

### Plan Stack Deployments

```bash
# Plan all deployments
terraform stack plan

# Plan specific deployment
terraform stack plan -deployment=prod-us-east

# Plan specific group
terraform stack plan -group=production
```

### Apply Stack Deployments

```bash
# Apply all deployments
terraform stack apply

# Apply specific deployment
terraform stack apply -deployment=dev-us-east

# Apply specific group (e.g., only production)
terraform stack apply -group=production

# Auto-approve
terraform stack apply -auto-approve
```

### View Stack Status

```bash
# List all deployments
terraform stack list

# Show deployment status
terraform stack show

# Show specific deployment
terraform stack show -deployment=prod-us-east

# View outputs for all deployments
terraform stack output

# View outputs for specific deployment
terraform stack output -deployment=prod-us-east
```

### Update Stack

```bash
# Update all deployments with changes
terraform stack plan
terraform stack apply

# Update only specific deployments
terraform stack apply -deployment=staging-us-east -deployment=staging-eu-west
```

### Destroy Stack Deployments

```bash
# Destroy all deployments
terraform stack destroy

# Destroy specific deployment
terraform stack destroy -deployment=dev-us-east

# Destroy specific group
terraform stack destroy -group=development
```

## Advanced Stack Patterns

### Dynamic Deployment Generation

```hcl
# Generate deployments programmatically
locals {
  regions = ["us-east-1", "eu-west-1", "ap-south-1"]
  environments = ["dev", "staging", "prod"]
}

# Create deployment for each region/environment combination
deployment "app" {
  for_each = {
    for combo in setproduct(local.environments, local.regions) :
    "${combo[0]}-${combo[1]}" => {
      environment = combo[0]
      region      = combo[1]
    }
  }

  inputs = {
    region      = each.value.region
    environment = each.value.environment
    instance_count = each.value.environment == "prod" ? 4 : 2
  }
}
```

### Conditional Deployments

```hcl
# Deploy based on conditions
variable "enable_disaster_recovery" {
  type    = bool
  default = true
}

deployment "dr-region" {
  count = var.enable_disaster_recovery ? 1 : 0

  inputs = {
    region      = "us-west-2"
    environment = "dr"
  }
}
```

### Cross-Stack Dependencies

```hcl
# Reference outputs from another stack
stack "networking" {
  source = "./stacks/networking"
}

deployment "application" {
  inputs = {
    vpc_id     = stack.networking.output.vpc_id
    subnet_ids = stack.networking.output.subnet_ids
  }
}
```

### Deployment Promotion Pattern

```hcl
# Promote configuration from dev to prod
locals {
  dev_config = deployment.dev-us-east.inputs
}

deployment "prod-us-east" {
  inputs = merge(
    local.dev_config,
    {
      environment    = "prod"
      instance_count = 4  # Override for production
    }
  )
}
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Deploy Terraform Stack

on:
  push:
    branches: [main]

jobs:
  deploy-dev:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2

      - name: Terraform Stack Init
        run: terraform stack init

      - name: Deploy Development
        run: terraform stack apply -group=development -auto-approve
        env:
          TF_TOKEN_app_terraform_io: ${{ secrets.TF_API_TOKEN }}

  deploy-staging:
    needs: deploy-dev
    runs-on: ubuntu-latest
    steps:
      - name: Deploy Staging
        run: terraform stack apply -group=staging -auto-approve

  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Deploy Production
        run: terraform stack apply -group=production
        # No auto-approve for production
```

## Benefits of Terraform Stacks

1. **Reduced Duplication:**
   - Single infrastructure definition
   - Shared modules and logic
   - DRY (Don't Repeat Yourself) principle

2. **Rapid Scaling:**
   - Deploy to multiple regions/accounts simultaneously
   - Add new deployments without code duplication
   - Single command for all deployments

3. **Consistency:**
   - Same infrastructure pattern everywhere
   - Guaranteed configuration parity
   - Centralized updates affect all deployments

4. **Simplified Management:**
   - Single source of truth
   - Centralized orchestration
   - Easier compliance and governance

5. **Controlled Rollout:**
   - Orchestration groups
   - Phased deployment strategies
   - Rollback capabilities

## Best Practices

1. **Start Simple:**
   - Begin with 2-3 deployments
   - Add complexity gradually
   - Test thoroughly before scaling

2. **Use Orchestration Groups:**
   - Group deployments logically (dev, staging, prod)
   - Control deployment order
   - Enable phased rollouts

3. **Leverage Outputs:**
   - Export critical information
   - Enable cross-stack dependencies
   - Document outputs clearly

4. **Test Thoroughly:**
   - Validate stack configuration
   - Test with dev deployments first
   - Use `-deployment` flag to test individual deployments

5. **Version Control:**
   - Commit stack configurations
   - Use branches for changes
   - Review deployment configurations

6. **Monitor Deployments:**
   - Track deployment status
   - Monitor for failures
   - Set up alerting

7. **Document Variations:**
   - Explain deployment differences
   - Document input purposes
   - Maintain README for stack

## Comparison: Stacks vs Workspaces vs Modules

| Feature | Stacks | Workspaces | Modules |
|---------|--------|------------|---------|
| Purpose | Multi-deployment orchestration | State isolation | Code reuse |
| Scope | Multiple related deployments | Single deployment | Single component |
| Code duplication | Minimal | High (separate configs) | None |
| Management | Centralized | Per-workspace | Per-module call |
| Best for | Enterprise scale | Simple multi-env | Component libraries |

## Troubleshooting

**Stack validation fails:**
```bash
# Check syntax
terraform stack validate

# Review error messages for component/deployment issues
```

**Deployment fails:**
```bash
# Check specific deployment
terraform stack show -deployment=DEPLOYMENT_NAME

# Review logs
terraform stack logs -deployment=DEPLOYMENT_NAME

# Retry single deployment
terraform stack apply -deployment=DEPLOYMENT_NAME
```

**Orchestration issues:**
```bash
# Verify group dependencies
terraform stack plan -group=GROUP_NAME

# Check deployment order
cat deployments.tfdeploy.hcl | grep -A 10 "orchestrate"
```

## Limitations and Considerations

- **Requires HCP Terraform** (not available in Terraform CLI only)
- **Maximum 20 deployments per stack** (current limit)
- **Deployment groups support single deployment per stack** (current limit)
- Learning curve for complex orchestrations
- Performance considerations for large-scale deployments
- Cost based on resources under management (RUM pricing model)

## Migration from Traditional Terraform

1. **Identify common patterns** across existing workspaces
2. **Extract shared code** into modules
3. **Create stack configuration** referencing modules
4. **Define deployments** for each environment/region
5. **Test with non-production** deployments first
6. **Migrate state** if needed
7. **Deprecate old workspaces** after validation

## Next Steps

- Review `terraform-expert` agent for stack architecture guidance
- Use `/terraform-master:tf-modules` for module best practices
- Use `/terraform-master:tf-security` for stack security considerations
- Explore HCP Terraform documentation for latest stack features
