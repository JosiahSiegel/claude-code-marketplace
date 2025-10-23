# Terraform Master Plugin

Complete Terraform expertise system for Claude Code. Provides comprehensive infrastructure-as-code guidance, version-aware code generation, multi-environment architecture, CI/CD integration, and industry best practices across Windows, Linux, and macOS.

## Features

### Comprehensive Provider Coverage
- **Azure**: AzureRM, AzAPI for all Azure resources
- **AWS**: Complete AWS service coverage
- **Google Cloud**: Full GCP resource support
- **Community Providers**: Kubernetes, Helm, Datadog, PagerDuty, GitHub, GitLab, and more

### Enterprise Capabilities
- Multi-environment architecture patterns
- Multi-region deployment strategies
- Large-scale state management
- Module development and organization
- Landing zone implementations
- Service catalog patterns

### Resource Import & State Management ⭐ NEW
- **Import Existing Resources**: Bring manual deployments under Terraform control
  - Traditional imports and import blocks (Terraform 1.5+)
  - Bulk import with Terraformer, aztfexport, custom scripts
  - Migration from ARM templates, CloudFormation, manual provisioning
- **State Operations**: Complete state management
  - Move, rename, and refactor resources
  - Split/merge states
  - Backup and recovery
  - State inspection and troubleshooting

### Version-Aware Operations
- Automatic version detection
- Breaking change awareness
- Upgrade path guidance
- Provider version management
- Migration assistance

### Platform Support
- **Windows**: PowerShell-native, path handling, credential management
- **Linux**: Package managers, permissions, environment configuration
- **macOS**: Homebrew integration, BSD utilities
- **CI/CD**: Azure DevOps, GitHub Actions, GitLab CI, Jenkins

### Security & Compliance
- Integrated security scanning (tfsec, Checkov, Terrascan)
- Best practice enforcement
- Secrets management patterns
- Network security guidance
- Encryption standards
- Compliance validation

## Installation

### From Claude Code Marketplace

```bash
# In Claude Code
/plugin install terraform-master@claude-code-marketplace
```

### Manual Installation

1. Clone this repository or download the `terraform-master` directory
2. Add marketplace to Claude Code settings:

```bash
# In Claude Code
/plugin marketplace add local file:///path/to/claude-code-marketplace
/plugin install terraform-master@local
```

## Components

### Slash Commands (15 Total)

#### `/terraform-master:tf-init`
Initialize Terraform projects with best practices and platform-specific guidance.

#### `/terraform-master:tf-plan`
Generate and review Terraform execution plans with comprehensive analysis.

#### `/terraform-master:tf-apply`
Apply Terraform changes safely with pre-apply checks and rollback strategies.

#### `/terraform-master:tf-validate`
Comprehensive validation including syntax, format, security, and compliance.

#### `/terraform-master:tf-format`
Format and lint Terraform code across all platforms.

#### `/terraform-master:tf-modules`
Manage local and remote Terraform modules with versioning best practices.

#### `/terraform-master:tf-providers`
Configure and manage providers across all cloud platforms.

#### `/terraform-master:tf-upgrade`
Safely upgrade Terraform and provider versions with migration guidance.

#### `/terraform-master:tf-debug`
Systematically debug Terraform issues across all platforms.

#### `/terraform-master:tf-security`
Security scanning, remediation, and best practices implementation.

#### `/terraform-master:tf-cicd`
Complete CI/CD pipeline generation and troubleshooting.

#### `/terraform-master:tf-architecture`
Architecture design and review for enterprise-scale Terraform.

#### `/terraform-master:tf-import` ⭐ NEW
Import existing cloud resources into Terraform management with traditional imports, import blocks (Terraform 1.5+), bulk import strategies, and migration from manual deployments.

#### `/terraform-master:tf-state` ⭐ NEW
Comprehensive state management including move, remove, inspect, backup, recovery, and state migration operations.

#### `/terraform-master:tf-cli` ⭐ NEW
Complete Terraform CLI reference with all commands, flags, options, and advanced usage patterns including -chdir, environment variables, and platform-specific examples.

### Terraform Expert Agent

The `terraform-expert` agent is automatically activated for Terraform-related tasks and provides:

- **Comprehensive Provider Knowledge**: Deep expertise in Azure, AWS, GCP, and community providers
- **Version Awareness**: Always considers Terraform and provider versions, warns about breaking changes
- **Platform Intelligence**: Provides Windows, Linux, and macOS-specific guidance
- **Security Focus**: Enforces security best practices and scanning
- **Documentation Research**: Fetches latest provider documentation when needed
- **Architecture Guidance**: Enterprise-scale architecture patterns and best practices

**Proactive Activation**: The agent automatically activates when you mention Terraform, HCL, infrastructure-as-code, or cloud resources.

### Terraform Tasks Skill

Autonomous skill for executing complex Terraform operations including infrastructure code generation, version management, debugging, security scanning, architecture review, CI/CD pipeline creation, module development, and resource migration.

## Usage Examples

### Example 1: Initialize a New Azure Project

```
User: Help me initialize a new Terraform project for Azure

Agent: I'll help you initialize a Terraform project for Azure with best practices.
First, let me ask a few questions:
- What Terraform version are you using?
- Which AzureRM provider version?
- Do you need remote state backend?

[Creates complete project structure with all necessary files]
```

### Example 2: Generate Secure Infrastructure

```
User: Create an Azure Storage Account with all security best practices

Agent: [Detects your Terraform/provider versions]
[Generates complete configuration with encryption, private endpoints, network rules]
[Runs security scan and confirms all checks pass]
```

### Example 3: Debug Issues

```
User: My terraform plan is failing with authentication error on Windows

Agent: [Identifies Windows platform and Azure CLI authentication issue]
[Provides PowerShell commands to diagnose and fix]
[Explains root cause and prevention]
```

### Example 4: CI/CD Pipeline

```
User: /terraform-master:tf-cicd

Agent: [Generates complete CI/CD pipeline for your platform]
[Includes security scanning, approval gates, drift detection]
[Provides OIDC setup instructions]
```

### Example 5: Architecture Review

```
User: /terraform-master:tf-architecture

Agent: [Analyzes your current structure]
[Identifies anti-patterns and proposes improvements]
[Provides migration plan and ADR documentation]
```

### Example 6: Import Existing Resources ⭐ NEW

```
User: /terraform-master:tf-import

Agent: I'll help you import existing infrastructure into Terraform.

First, let me understand your situation:
- Which cloud provider? (Azure/AWS/GCP)
- How many resources need to be imported?
- Do you have Terraform 1.5+ (for import blocks)?

User: Azure, about 20 resources in a resource group, Terraform 1.7

Agent: Perfect! For Terraform 1.5+, I recommend using import blocks.

Step 1: Let me help you inventory the resources:
[Provides Azure CLI commands to list all resources]

Step 2: Create import blocks:
[Generates import.tf with all 20 resources]

Step 3: Generate configuration:
terraform plan -generate-config-out=generated.tf

[Provides complete workflow with verification steps]
```

### Example 7: State Management ⭐ NEW

```
User: I need to rename a resource and move it to a module

Agent: I'll help you refactor your Terraform structure safely.

Current structure:
resource "azurerm_virtual_network" "vnet"

Target structure:
module "networking" {
  # contains azurerm_virtual_network.vnet
}

Steps:
1. Backup state first:
   terraform state pull > backup-$(date +%Y%m%d).json

2. Move resource to module:
   terraform state mv azurerm_virtual_network.vnet module.networking.azurerm_virtual_network.vnet

3. Verify (should show no changes):
   terraform plan

[Provides complete commands with safety checks]
```

## Best Practices

### Version Management
- Always pin Terraform and provider versions in production
- Use pessimistic version constraints (~>)
- Review changelogs before upgrading
- Test upgrades in non-production first

### State Management
- Use remote backend (Azure Storage, S3, GCS, Terraform Cloud)
- Enable state locking
- Enable versioning on backend storage
- Restrict access with RBAC/IAM

### Security
- Never commit secrets to code
- Use secret management services
- Run security scanning in CI/CD
- Enforce HTTPS/TLS everywhere
- Implement least privilege IAM/RBAC

### Code Quality
- Run terraform fmt before committing
- Use pre-commit hooks
- Implement CI/CD validation
- Document all modules

### CI/CD
- Separate plan and apply stages
- Require approval for production
- Save plans as artifacts
- Implement drift detection

## Version Compatibility

- **Terraform**: 0.12+ (1.x recommended)
- **Providers**: Azure 2.x/3.x/4.x, AWS 3.x/4.x/5.x, GCP 4.x/5.x
- **Platforms**: Windows, Linux, macOS
- **CI/CD**: Azure DevOps, GitHub Actions, GitLab CI, Jenkins

## Documentation Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [Terraform Registry](https://registry.terraform.io/)
- [Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [tfsec](https://github.com/aquasecurity/tfsec)
- [Checkov](https://www.checkov.io/)

## License

Part of the Claude Code Marketplace.

## Changelog

### Version 1.2.0

**New Features:**
- `/tf-cli` command for comprehensive CLI reference
  - Complete guide to all Terraform CLI flags and options
  - **-chdir** usage and best practices
  - Environment variables (TF_LOG, TF_PLUGIN_CACHE_DIR, etc.)
  - Exit codes and CI/CD patterns
  - Platform-specific usage (Windows PowerShell, Linux/macOS Bash)
  - Advanced flag combinations
  - Performance optimization flags
- Enhanced terraform-expert agent with CLI mastery section
  - All command flags documented
  - Platform-specific examples
  - CI/CD optimization patterns
  - Best practices for flag usage

### Version 1.1.0

**New Features:**
- `/tf-import` command for importing existing resources
  - Traditional import commands
  - Import blocks (Terraform 1.5+)
  - Bulk import strategies (Terraformer, aztfexport, custom scripts)
  - Migration from manual deployments
- `/tf-state` command for comprehensive state management
  - State inspection (list, show, pull)
  - Moving resources (rename, refactor, module migrations)
  - Removing resources from state
  - State backup and recovery
  - State migration scenarios
- Enhanced terraform-expert agent with import and state expertise

### Version 1.0.0

- 12 specialized slash commands
- terraform-expert agent with comprehensive provider knowledge
- terraform-tasks skill for autonomous operations
- Multi-provider support (Azure, AWS, GCP, community)
- Platform-specific guidance (Windows, Linux, macOS)
- CI/CD integration
- Security scanning integration
- Enterprise architecture patterns

---

**Made with Claude Code**
