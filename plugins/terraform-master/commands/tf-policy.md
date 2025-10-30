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


# Terraform Policy as Code

Implement policy-as-code governance for Terraform using Sentinel, Open Policy Agent (OPA), and custom validation frameworks for enterprise compliance and security enforcement.

## Your Task

You are helping implement policy-as-code governance for Terraform infrastructure. Provide policy implementation, compliance validation, and governance frameworks.

## Policy Frameworks Overview

### 1. HashiCorp Sentinel (HCP Terraform)

**Overview:**
- Native policy framework for HCP Terraform and Terraform Enterprise
- Policy enforcement at plan, apply, and run stages
- Hard mandatory, soft mandatory, and advisory enforcement levels
- NIST SP 800-53 Rev 5 policies available (350+ policies)

**When to Use:**
- HCP Terraform or Terraform Enterprise environments
- Government compliance (NIST, FedRAMP)
- Centralized policy management
- Cost control and budget enforcement
- Multi-team governance

**Enforcement Levels:**
- **Hard Mandatory**: Must pass, no override
- **Soft Mandatory**: Must pass or override with reason
- **Advisory**: Warning only, always passes

### 2. Open Policy Agent (OPA)

**Overview:**
- General-purpose policy engine (CNCF project)
- Rego policy language
- Can be used with Terraform CLI (open source)
- Integration via conftest tool
- Flexible and extensible

**When to Use:**
- Open source Terraform (not HCP/Enterprise)
- Multi-tool policy enforcement (Kubernetes, Docker, etc.)
- Custom policy requirements
- CI/CD pipeline integration
- Budget-conscious organizations

### 3. Checkov Policies

**Overview:**
- Python-based policy framework
- 750+ built-in policies
- Supports custom Python checks
- CIS, GDPR, PCI-DSS, HIPAA compliance

**When to Use:**
- Quick policy enforcement without infrastructure
- CI/CD integration
- Pre-commit validation
- Development-time feedback

## Sentinel Implementation

### Sentinel Policy Structure

```hcl
# policy/enforce-tagging.sentinel

import "tfplan/v2" as tfplan

# Mandatory tags
mandatory_tags = ["Environment", "Owner", "CostCenter", "Project"]

# Get all resources
all_resources = filter tfplan.resource_changes as _, rc {
  rc.mode is "managed" and
  rc.change.actions contains "create"
}

# Check for mandatory tags
resources_without_tags = filter all_resources as address, rc {
  any mandatory_tags as tag {
    rc.change.after.tags not contains tag
  }
}

# Main rule
main = rule {
  length(resources_without_tags) is 0
}
```

### Sentinel Policy Set

```hcl
# sentinel.hcl

policy "enforce-tagging" {
  source            = "./enforce-tagging.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "restrict-regions" {
  source            = "./restrict-regions.sentinel"
  enforcement_level = "soft-mandatory"
}

policy "cost-estimation" {
  source            = "./cost-estimation.sentinel"
  enforcement_level = "advisory"
}
```

### Common Sentinel Policies

**Restrict AWS Regions:**
```hcl
# policy/restrict-regions.sentinel

import "tfplan/v2" as tfplan

# Allowed regions
allowed_regions = ["us-east-1", "us-west-2", "eu-west-1"]

# Get all AWS resources
aws_resources = filter tfplan.resource_changes as _, rc {
  rc.mode is "managed" and
  rc.provider_name is "registry.terraform.io/hashicorp/aws"
}

# Check region
violations = filter aws_resources as address, rc {
  rc.change.after.region not in allowed_regions
}

main = rule {
  length(violations) is 0
}
```

**Enforce Encryption:**
```hcl
# policy/enforce-encryption.sentinel

import "tfplan/v2" as tfplan

# Get S3 buckets
s3_buckets = filter tfplan.resource_changes as _, rc {
  rc.mode is "managed" and
  rc.type is "aws_s3_bucket" and
  rc.change.actions contains "create"
}

# Check encryption
unencrypted_buckets = filter s3_buckets as address, rc {
  rc.change.after.server_side_encryption_configuration is empty
}

main = rule {
  length(unencrypted_buckets) is 0
}
```

**Cost Control:**
```hcl
# policy/cost-limit.sentinel

import "tfplan/v2" as tfplan
import "decimal"

# Maximum monthly cost
max_monthly_cost = 10000.00

# Get cost estimate
estimated_cost = decimal.new(tfplan.cost_estimate.total_monthly_cost)
max_cost = decimal.new(max_monthly_cost)

main = rule {
  estimated_cost.less_than_or_equal_to(max_cost)
}
```

### NIST SP 800-53 Rev 5 Policies

**Available via HashiCorp:**
- 350+ pre-written Sentinel policies
- Covers all NIST controls
- FedRAMP compliance ready
- Government and enterprise use

**Example Controls:**
- AC-2: Account Management
- AC-3: Access Enforcement
- AU-2: Audit Events
- CM-2: Baseline Configuration
- SC-7: Boundary Protection
- SC-13: Cryptographic Protection

**Implementation:**
```bash
# Clone NIST policies
git clone https://github.com/hashicorp/terraform-sentinel-policies

# Configure in HCP Terraform
# Policies > New Policy Set > VCS connection
# Point to repository with sentinel.hcl
```

## Open Policy Agent (OPA) Implementation

### OPA Policy Structure

```rego
# policy/tagging.rego

package terraform.tagging

import input as tfplan

# Mandatory tags
mandatory_tags := ["Environment", "Owner", "CostCenter"]

# Get all resources
resources[r] {
  some path
  walk(tfplan.resource_changes[_], [path, r])
  r.change.actions[_] == "create"
}

# Check tags
deny[msg] {
  resource := resources[_]
  required_tag := mandatory_tags[_]
  not resource.change.after.tags[required_tag]
  msg := sprintf("%s is missing required tag: %s", [resource.address, required_tag])
}
```

### Using OPA with Conftest

**Installation:**
```bash
# Windows (Chocolatey)
choco install conftest

# macOS (Homebrew)
brew install conftest

# Linux
wget https://github.com/open-policy-agent/conftest/releases/download/v0.48.0/conftest_0.48.0_Linux_x86_64.tar.gz
tar xzf conftest_0.48.0_Linux_x86_64.tar.gz
sudo mv conftest /usr/local/bin/
```

**Usage:**
```bash
# Generate JSON plan
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json

# Run policy check
conftest test tfplan.json

# Specific policy directory
conftest test tfplan.json -p policy/

# Multiple policies
conftest test tfplan.json -p policy/security -p policy/compliance

# Fail on warnings
conftest test tfplan.json --fail-on-warn

# Output formats
conftest test tfplan.json -o json
conftest test tfplan.json -o junit
```

### OPA Policy Examples

**Restrict Instance Types:**
```rego
# policy/instance-types.rego

package terraform.compute

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_instance"
  not allowed_instance_types[resource.change.after.instance_type]
  msg := sprintf("%s uses disallowed instance type: %s", [resource.address, resource.change.after.instance_type])
}

allowed_instance_types := {
  "t3.micro",
  "t3.small",
  "t3.medium"
}
```

**Require Private Endpoints:**
```rego
# policy/private-endpoints.rego

package terraform.networking

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "azurerm_storage_account"
  resource.change.after.public_network_access_enabled == true
  msg := sprintf("%s has public network access enabled", [resource.address])
}
```

## Custom Validation Framework

### Terraform Variables Validation

**Built-in Validation:**
```hcl
# variables.tf

variable "environment" {
  type        = string
  description = "Environment name"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "vm_size" {
  type        = string
  description = "VM size"

  validation {
    condition     = can(regex("^(Standard_B|Standard_D).*", var.vm_size))
    error_message = "VM size must be B or D series."
  }
}

variable "cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks"

  validation {
    condition = alltrue([
      for cidr in var.cidr_blocks : can(cidrhost(cidr, 0))
    ])
    error_message = "All CIDR blocks must be valid."
  }
}
```

### Pre-Commit Hooks

**.pre-commit-config.yaml:**
```yaml
# .pre-commit-config.yaml

repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.83.5
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
      - id: terraform_tflint
      - id: terraform_trivy
        args:
          - --args=--severity=CRITICAL,HIGH

  - repo: local
    hooks:
      - id: opa-test
        name: OPA Policy Test
        entry: conftest test
        language: system
        files: \.tf$
        pass_filenames: false
        args:
          - tfplan.json
```

## CI/CD Policy Integration

### GitHub Actions

```yaml
name: Terraform Policy Validation

on:
  pull_request:
    paths:
      - '**.tf'

jobs:
  policy-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.14.0

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        run: |
          terraform plan -out=tfplan
          terraform show -json tfplan > tfplan.json

      - name: Setup OPA
        uses: open-policy-agent/setup-opa@v2
        with:
          version: latest

      - name: Setup Conftest
        run: |
          wget https://github.com/open-policy-agent/conftest/releases/download/v0.48.0/conftest_0.48.0_Linux_x86_64.tar.gz
          tar xzf conftest_0.48.0_Linux_x86_64.tar.gz
          sudo mv conftest /usr/local/bin/

      - name: Run Policy Tests
        run: conftest test tfplan.json -p policy/

      - name: Checkov Policy Scan
        uses: bridgecrewio/checkov-action@v12
        with:
          file: tfplan.json
          framework: terraform_plan
          output_format: sarif
          soft_fail: false
```

### Azure DevOps

```yaml
# azure-pipelines.yml

trigger:
  branches:
    include:
      - main
  paths:
    include:
      - '**/*.tf'

pool:
  vmImage: 'ubuntu-latest'

steps:
  - task: TerraformInstaller@1
    inputs:
      terraformVersion: '1.14.0'

  - script: |
      terraform init
      terraform plan -out=tfplan
      terraform show -json tfplan > tfplan.json
    displayName: 'Terraform Plan'

  - script: |
      wget https://github.com/open-policy-agent/conftest/releases/download/v0.48.0/conftest_0.48.0_Linux_x86_64.tar.gz
      tar xzf conftest_0.48.0_Linux_x86_64.tar.gz
      sudo mv conftest /usr/local/bin/
    displayName: 'Install Conftest'

  - script: |
      conftest test tfplan.json -p policy/ -o junit > policy-results.xml
    displayName: 'Run Policy Tests'

  - task: PublishTestResults@2
    inputs:
      testResultsFormat: 'JUnit'
      testResultsFiles: 'policy-results.xml'
      failTaskOnFailedTests: true
```

## Private Registry Module Governance

### Module Curation Best Practices

**Registry Configuration:**
```hcl
# terraform.tf

terraform {
  required_version = ">= 1.5.0"

  # Private registry
  cloud {
    organization = "my-org"
    workspaces {
      name = "infrastructure"
    }
  }
}

# Use curated modules
module "networking" {
  source  = "app.terraform.io/my-org/networking/azure"
  version = "~> 2.0"
}
```

**Module Publishing Policy:**
1. **Approval Process**: All modules require review before publishing
2. **Versioning**: Semantic versioning enforced
3. **Testing**: Modules must pass tests before publication
4. **Documentation**: Required inputs/outputs documentation
5. **Security Scan**: Trivy/Checkov validation required
6. **Deprecation Policy**: 90-day notice for breaking changes

### No-Code Module Configuration

**HCP Terraform No-Code Modules:**
- Simplified UI for non-technical users
- Pre-configured defaults from curated modules
- Workspace creation without writing Terraform
- Variable validation in UI
- Self-service infrastructure provisioning

**Creating No-Code Ready Module:**
```hcl
# modules/no-code-ready-vm/variables.tf

variable "vm_name" {
  type        = string
  description = "Virtual machine name (alphanumeric only, 3-15 characters)"

  validation {
    condition     = can(regex("^[a-z0-9]{3,15}$", var.vm_name))
    error_message = "VM name must be 3-15 lowercase alphanumeric characters."
  }
}

variable "environment" {
  type        = string
  description = "Environment (dev, staging, or prod)"
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Must be dev, staging, or prod."
  }
}

variable "size" {
  type        = string
  description = "VM size"
  default     = "Standard_B2s"

  validation {
    condition     = contains(["Standard_B2s", "Standard_D2s_v5", "Standard_E2s_v5"], var.size)
    error_message = "Size must be B2s, D2s_v5, or E2s_v5."
  }
}
```

**Module Metadata:**
```hcl
# modules/no-code-ready-vm/.terraform-docs.yml

formatter: markdown table

sections:
  show:
    - header
    - inputs
    - outputs

output:
  file: README.md
  mode: inject

sort:
  enabled: true
```

## Policy Testing

### Testing Sentinel Policies

```hcl
# test/enforce-tagging/mock-tfplan-pass.sentinel

# Mock data for passing test
resource_changes = {
  "aws_instance.web": {
    "type": "aws_instance",
    "change": {
      "actions": ["create"],
      "after": {
        "tags": {
          "Environment": "dev",
          "Owner": "team@example.com",
          "CostCenter": "engineering",
          "Project": "web-app"
        }
      }
    }
  }
}
```

**Run Sentinel Tests:**
```bash
# Install Sentinel CLI
# Download from https://releases.hashicorp.com/sentinel/

# Run tests
sentinel test enforce-tagging.sentinel

# Verbose output
sentinel test -verbose enforce-tagging.sentinel
```

### Testing OPA Policies

```bash
# Test with OPA
opa test policy/ -v

# Test specific package
opa test policy/tagging.rego -v

# Generate coverage
opa test policy/ --coverage
```

## Best Practices

### Policy Development
1. **Start with advisory**: Test policies as advisory before enforcing
2. **Clear error messages**: Help users understand violations
3. **Document exceptions**: Explain why exceptions exist
4. **Version control**: Treat policies like code
5. **Test thoroughly**: Use mock data for policy testing

### Policy Management
1. **Centralized storage**: VCS for all policies
2. **Review process**: Policies should be peer-reviewed
3. **Change management**: Document policy changes
4. **Communication**: Notify teams of new policies
5. **Gradual rollout**: Phase in enforcement

### Governance
1. **Policy hierarchy**: Organization > workspace > run
2. **Enforcement levels**: Use appropriate levels
3. **Override process**: Define approval workflow
4. **Audit logging**: Track policy overrides
5. **Regular review**: Policies should be reviewed quarterly

## Common Policy Patterns

### Security Policies
- Encryption at rest and in transit
- Public access restrictions
- Secret management validation
- Network security rules
- IAM/RBAC best practices

### Compliance Policies
- NIST SP 800-53 Rev 5 (government)
- CIS Benchmarks
- PCI-DSS (payment card)
- HIPAA (healthcare)
- GDPR (data privacy)

### Cost Control Policies
- Resource size restrictions
- Region limitations
- Budget thresholds
- Cost estimation requirements
- Resource tagging for billing

### Operational Policies
- Mandatory tagging
- Naming conventions
- High availability requirements
- Backup configuration
- Monitoring and alerting

## Troubleshooting

### Sentinel Issues
```bash
# Debug mode
sentinel apply -trace enforce-tagging.sentinel

# Test with mock data
sentinel apply -config test/enforce-tagging/mock-tfplan-pass.sentinel enforce-tagging.sentinel
```

### OPA Issues
```bash
# Test policy syntax
opa check policy/

# Debug policy
opa eval -d policy/ -i tfplan.json "data.terraform.tagging.deny"

# Run with tracing
conftest test tfplan.json --trace
```

### Policy Bypass
- Check enforcement levels
- Review override permissions
- Verify policy set application
- Check workspace configuration

## Platform-Specific Considerations

### Windows
```powershell
# Install Conftest
choco install conftest

# Run policies
conftest test tfplan.json -p .\policy\
```

### Linux/macOS
```bash
# Install Conftest
brew install conftest

# Run policies
conftest test tfplan.json -p ./policy/
```

## Resources

- [Sentinel Documentation](https://docs.hashicorp.com/sentinel)
- [NIST SP 800-53 Rev 5 Policies](https://github.com/hashicorp/terraform-sentinel-policies)
- [Open Policy Agent](https://www.openpolicyagent.org/)
- [Conftest](https://www.conftest.dev/)
- [HCP Terraform Governance](https://developer.hashicorp.com/terraform/cloud-docs/policy-enforcement)
- [No-Code Provisioning](https://developer.hashicorp.com/terraform/cloud-docs/no-code-provisioning)
