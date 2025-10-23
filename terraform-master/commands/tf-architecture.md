# Terraform Architecture Design and Review

Design and review Terraform infrastructure architectures including multi-environment, multi-region, and enterprise-scale patterns.

## Your Task

You are helping design or review Terraform architecture. Provide comprehensive guidance on architecture patterns, scalability, and best practices.

## Architecture Patterns

### 1. State Management Architectures

#### Resource Group/Component Level (Azure) / Service Level (AWS)

**Structure**:
```
terraform/
├── networking/
│   ├── main.tf
│   ├── variables.tf
│   ├── backend.tf (state: networking.tfstate)
│   └── outputs.tf
├── security/
│   ├── main.tf
│   ├── variables.tf
│   ├── backend.tf (state: security.tfstate)
│   └── outputs.tf
├── compute/
│   ├── main.tf
│   ├── variables.tf
│   ├── backend.tf (state: compute.tfstate)
│   └── outputs.tf
└── data/
    ├── main.tf
    ├── variables.tf
    ├── backend.tf (state: data.tfstate)
    └── outputs.tf
```

**Pros**:
- Small blast radius (failures isolated)
- Faster plan/apply operations
- Parallel team development
- Clear ownership boundaries
- Easier state management

**Cons**:
- More state files to manage
- Cross-component dependencies via remote state
- More complex CI/CD pipelines
- Potential circular dependencies

**When to Use**:
- Large organizations with multiple teams
- Need for isolated ownership
- Frequent changes requiring fast operations
- Risk-averse environments

#### Subscription/Account Level (Monolithic)

**Structure**:
```
terraform/
├── main.tf
├── variables.tf
├── backend.tf (single state file)
├── outputs.tf
├── networking.tf
├── security.tf
├── compute.tf
└── data.tf
```

**Pros**:
- Single state file (simpler management)
- Easy cross-resource references
- No remote state data sources needed
- Simpler CI/CD pipeline

**Cons**:
- Large blast radius
- Slow plan/apply for large infrastructures
- State lock contention
- Difficult team collaboration
- All-or-nothing deployments

**When to Use**:
- Small to medium infrastructure
- Single team ownership
- Closely coupled resources
- Rapid prototyping

#### Layered Architecture (Hybrid)

**Structure**:
```
terraform/
├── 01-foundation/
│   ├── networking/
│   ├── identity/
│   └── logging/
├── 02-platform/
│   ├── kubernetes/
│   ├── databases/
│   └── storage/
└── 03-applications/
    ├── app1/
    └── app2/
```

**Pros**:
- Logical separation
- Controlled blast radius
- Clear deployment order
- Manageable dependencies

**Cons**:
- More complex structure
- Requires careful dependency management
- Multiple pipelines needed

**When to Use**:
- Enterprise environments
- Layered infrastructure (foundation → platform → apps)
- Need for staged deployments
- Clear separation of concerns

### 2. Multi-Environment Strategies

#### Workspace-Based

**Structure**:
```
terraform/
├── main.tf
├── variables.tf
├── backend.tf
├── outputs.tf
└── environments/
    ├── dev.tfvars
    ├── staging.tfvars
    └── prod.tfvars
```

**Usage**:
```bash
# Create workspaces
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Use workspace
terraform workspace select dev
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"
```

**Pros**:
- Single codebase
- Easy environment switching
- Built-in Terraform feature

**Cons**:
- Easy to accidentally deploy to wrong environment
- Shared backend configuration
- Limited environment-specific customization
- Not recommended for production by HashiCorp

**When to Use**:
- Development and testing environments
- Small infrastructure
- Rapid prototyping
- NOT recommended for production

#### Directory-Based

**Structure**:
```
terraform/
├── modules/
│   ├── networking/
│   ├── compute/
│   └── storage/
└── environments/
    ├── dev/
    │   ├── main.tf
    │   ├── backend.tf
    │   ├── terraform.tfvars
    │   └── versions.tf
    ├── staging/
    │   ├── main.tf
    │   ├── backend.tf
    │   ├── terraform.tfvars
    │   └── versions.tf
    └── prod/
        ├── main.tf
        ├── backend.tf
        ├── terraform.tfvars
        └── versions.tf
```

**Example** (environments/prod/main.tf):
```hcl
module "networking" {
  source = "../../modules/networking"

  environment      = "prod"
  vnet_cidr        = "10.0.0.0/16"
  enable_ddos      = true
  enable_firewall  = true
}

module "compute" {
  source = "../../modules/compute"

  environment = "prod"
  vm_size     = "Standard_D4s_v3"
  vm_count    = 5
  subnet_id   = module.networking.app_subnet_id
}
```

**Pros**:
- Complete environment isolation
- Different backends per environment
- Environment-specific configurations
- No risk of wrong environment deployment
- Recommended pattern

**Cons**:
- Code duplication
- Manual sync of changes across environments
- More directories to manage

**When to Use**:
- Production environments (recommended)
- Complete environment isolation needed
- Different state backends per environment
- Enterprise organizations

#### Branch-Based (GitOps)

**Structure**:
```
Git Branches:
├── main (production)
├── staging
└── develop (development)

Each branch contains:
terraform/
├── main.tf
├── variables.tf
├── terraform.tfvars
└── backend.tf
```

**Workflow**:
```bash
# Development
git checkout develop
terraform plan
terraform apply

# Promote to staging
git checkout staging
git merge develop
terraform plan
terraform apply

# Promote to production
git checkout main
git merge staging
terraform plan
terraform apply
```

**Pros**:
- Git-native approach
- Clear promotion path
- Easy rollback (git revert)
- Audit trail via git history

**Cons**:
- Merge conflicts
- Complex branch management
- Drift between branches
- Not suitable for all workflows

**When to Use**:
- GitOps workflows
- Strict promotion process
- Teams comfortable with git
- Automated CI/CD pipelines

### 3. Module Organization Patterns

#### Monorepo

**Structure**:
```
infrastructure/
├── modules/
│   ├── azure/
│   │   ├── networking/
│   │   ├── compute/
│   │   └── storage/
│   ├── aws/
│   │   ├── vpc/
│   │   ├── ec2/
│   │   └── s3/
│   └── common/
│       ├── naming/
│       └── tagging/
└── environments/
    ├── dev/
    ├── staging/
    └── prod/
```

**Pros**:
- All code in one repository
- Easy cross-module refactoring
- Shared CI/CD pipeline
- Single source of truth

**Cons**:
- Large repository
- Permissions management complex
- Slower git operations
- Versioning challenges

#### Multi-Repo

**Structure**:
```
Repositories:
├── terraform-modules-networking (separate repo)
├── terraform-modules-compute (separate repo)
├── terraform-modules-storage (separate repo)
└── terraform-infrastructure (uses modules)
```

**Usage**:
```hcl
module "networking" {
  source = "git::https://github.com/org/terraform-modules-networking.git//azure/vnet?ref=v1.2.0"

  environment = var.environment
  vnet_cidr   = var.vnet_cidr
}
```

**Pros**:
- Independent module versioning
- Clear ownership boundaries
- Smaller repositories
- Granular access control

**Cons**:
- Cross-repo changes difficult
- Version management overhead
- More repositories to maintain

### 4. Multi-Region Architectures

#### Active-Active Multi-Region

**Structure**:
```
terraform/
├── global/
│   ├── dns/
│   └── cdn/
└── regions/
    ├── us-east/
    │   ├── networking/
    │   ├── compute/
    │   └── data/
    └── eu-west/
        ├── networking/
        ├── compute/
        └── data/
```

**Example**:
```hcl
# regions/us-east/main.tf
module "regional_infrastructure" {
  source = "../../modules/regional-deployment"

  region      = "eastus"
  environment = var.environment

  # Region-specific configurations
  vm_count    = 10
  enable_zone_redundancy = true
}

# regions/eu-west/main.tf
module "regional_infrastructure" {
  source = "../../modules/regional-deployment"

  region      = "westeurope"
  environment = var.environment

  # Region-specific configurations
  vm_count    = 5
  enable_zone_redundancy = true
}
```

#### Hub-and-Spoke Multi-Region

**Structure**:
```
terraform/
├── hub/
│   ├── networking/ (central hub)
│   ├── security/
│   └── management/
└── spokes/
    ├── region-us/
    │   ├── spoke-network/
    │   └── workloads/
    └── region-eu/
        ├── spoke-network/
        └── workloads/
```

### 5. Enterprise Patterns

#### Landing Zone Architecture

**Structure**:
```
terraform/
├── management/
│   ├── subscription-vending/
│   ├── policy/
│   └── logging/
├── connectivity/
│   ├── hub-networking/
│   ├── firewall/
│   └── vpn/
└── workloads/
    ├── production/
    │   ├── subscription-1/
    │   └── subscription-2/
    ├── development/
    │   └── subscription-3/
    └── sandbox/
        └── subscription-4/
```

**Key Components**:
- Management subscription (governance, logging)
- Connectivity subscription (hub networking)
- Workload subscriptions (applications)
- Policy-driven compliance
- Centralized monitoring

#### Service Catalog Pattern

**Structure**:
```
terraform/
├── catalog/
│   ├── web-application/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── README.md
│   ├── api-service/
│   └── database-cluster/
└── deployments/
    ├── team-a/
    │   └── uses catalog/web-application
    └── team-b/
        └── uses catalog/api-service
```

**Example Catalog Module**:
```hcl
# catalog/web-application/main.tf
# Complete opinionated web application stack
module "networking" {
  source = "../../modules/networking"
  # ... opinionated defaults
}

module "load_balancer" {
  source = "../../modules/load-balancer"
  # ... opinionated defaults
}

module "app_service" {
  source = "../../modules/app-service"
  # ... opinionated defaults
}

# Minimal inputs required from consumers
variable "app_name" {
  description = "Application name"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}
```

## Dependency Management

### Remote State Data Sources

```hcl
# networking/outputs.tf
output "vnet_id" {
  value = azurerm_virtual_network.example.id
}

output "app_subnet_id" {
  value = azurerm_subnet.app.id
}

# compute/main.tf
data "terraform_remote_state" "networking" {
  backend = "azurerm"

  config = {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstate"
    container_name       = "tfstate"
    key                  = "networking.tfstate"
  }
}

resource "azurerm_virtual_machine" "example" {
  subnet_id = data.terraform_remote_state.networking.outputs.app_subnet_id
  # ...
}
```

### Explicit Dependencies

```hcl
resource "azurerm_resource" "example" {
  depends_on = [
    azurerm_other_resource.prerequisite
  ]
}
```

## Architecture Decision Record (ADR) Template

```markdown
# ADR-001: State Management Strategy

## Status
Accepted

## Context
We need to determine how to structure Terraform state for a multi-team, multi-environment infrastructure with 500+ resources across 3 Azure subscriptions.

## Decision
We will use a layered architecture with separate state files per layer and per environment:
- Foundation layer (networking, identity)
- Platform layer (AKS, databases)
- Application layer (applications)

Each layer in each environment will have its own state file.

## Consequences
### Positive
- Isolated blast radius
- Faster operations
- Clear team ownership
- Parallel development

### Negative
- More complex CI/CD
- Remote state dependencies
- More state files to manage

## Implementation
- Backend: Azure Storage
- State locking: Enabled via blob lease
- Naming: {layer}-{environment}.tfstate
```

## Architecture Review Checklist

### State Management
- [ ] State backend configured (remote, not local)
- [ ] State locking enabled
- [ ] State file organization appropriate for scale
- [ ] State file size manageable (< 100MB)
- [ ] Backup strategy defined
- [ ] State access restricted (RBAC/IAM)

### Module Design
- [ ] Modules are reusable
- [ ] Modules have clear interfaces (variables/outputs)
- [ ] Modules are versioned
- [ ] Modules are documented
- [ ] Modules follow single responsibility principle
- [ ] No provider configuration in modules

### Environment Strategy
- [ ] Environment isolation appropriate
- [ ] Promotion path defined
- [ ] Environment parity maintained
- [ ] Environment-specific variations documented

### Dependencies
- [ ] Dependency direction clear (no cycles)
- [ ] Remote state references minimized
- [ ] Explicit dependencies used where needed
- [ ] Dependency graph reviewed

### Scalability
- [ ] Can handle growth (10x resources)
- [ ] Plan/apply times acceptable (< 5 min for normal changes)
- [ ] Team scalability considered
- [ ] Region expansion planned

### Security
- [ ] Secrets not in code
- [ ] Least privilege IAM/RBAC
- [ ] Network isolation implemented
- [ ] Encryption at rest/transit
- [ ] Audit logging enabled

### CI/CD
- [ ] Automated validation
- [ ] Security scanning integrated
- [ ] Approval gates for production
- [ ] Rollback procedure defined
- [ ] Drift detection implemented

### Documentation
- [ ] Architecture documented (diagrams)
- [ ] Module usage documented
- [ ] Deployment procedures documented
- [ ] Troubleshooting guide exists
- [ ] ADRs maintained

## Anti-Patterns to Avoid

❌ **Mega State File**: Single state with 1000+ resources
❌ **Workspace for Production**: Using workspaces to separate prod/dev
❌ **No State Locking**: Concurrent modifications
❌ **Hardcoded Values**: No variables or parameterization
❌ **Provider in Modules**: Provider configuration in reusable modules
❌ **Circular Dependencies**: Resource A → B → C → A
❌ **No Version Pinning**: Latest provider versions in production
❌ **Manual Only**: No CI/CD automation
❌ **God Module**: Single module doing everything
❌ **Copy-Paste Infrastructure**: Duplicated code instead of modules

## Recommended Patterns

✅ **Layered State**: Separate states per layer (network, compute, data)
✅ **Directory per Environment**: Complete isolation
✅ **Module Composition**: Small, focused modules
✅ **Remote State for Dependencies**: Use remote state data sources
✅ **Version Everything**: Pin Terraform and provider versions
✅ **Automate**: CI/CD for all environments
✅ **Security First**: Scanning, least privilege, encryption
✅ **Document Everything**: ADRs, diagrams, runbooks

Activate the terraform-expert agent for comprehensive architecture guidance and review.
