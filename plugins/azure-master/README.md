# Azure Master Plugin

Complete Azure ecosystem expertise system for Claude Code, covering all aspects of Microsoft Azure including CLI operations, infrastructure-as-code, resource management, migration strategies, and best practices.

## Overview

Azure Master is a comprehensive plugin that provides expert-level guidance across the entire Azure ecosystem. Whether you're deploying resources, migrating workloads, managing infrastructure with Terraform or Bicep, or implementing Azure best practices, this plugin delivers production-ready solutions following Microsoft's Well-Architected Framework.

## Features

### 🤖 Expert Agents

- **Azure CLI Expert**: Comprehensive az CLI command guidance, authentication, scripting, and automation
- **ARM & Bicep Expert**: Infrastructure-as-code with ARM templates and Bicep language
- **Terraform Azure Expert**: Azure provider expertise for Terraform deployments
- **Azure Migration Expert**: Cloud Adoption Framework implementation and migration strategies
- **Azure Resources Expert**: Deep knowledge of compute, networking, storage, databases, AI/ML services

### 📚 Comprehensive Skills

- **Azure Well-Architected Framework**: Complete coverage of the five pillars (Reliability, Security, Cost Optimization, Operational Excellence, Performance Efficiency)

### 🎯 Commands

- `/az-cli`: Get expert Azure CLI assistance
- `/azure-deploy`: Deploy infrastructure with ARM, Bicep, or Terraform

## Installation

### Via Marketplace (Recommended)

```bash
/plugin marketplace add JosiahSiegel/claude-code-marketplace
/plugin install azure-master@claude-code-marketplace
```

### Local Installation (Mac/Linux)

⚠️ **Windows users:** Use the marketplace installation method above.

```bash
# Clone or download the plugin
git clone https://github.com/JosiahSiegel/claude-code-marketplace.git

# Copy to plugins directory
cp -r claude-code-marketplace/plugins/azure-master ~/.local/share/claude/plugins/
```

## Usage

### Getting Started

Once installed, the Azure Master plugin automatically activates for Azure-related tasks. Simply describe what you want to accomplish:

**Examples:**

> "Deploy a web application to Azure App Service with Azure SQL Database"

> "Create an Azure Kubernetes cluster with autoscaling and monitoring"

> "Migrate my on-premises SQL Server database to Azure"

> "Set up a secure Azure virtual network with NSGs and Application Gateway"

> "Show me how to use az CLI to manage storage accounts"

### Slash Commands

**Azure CLI Assistance:**
```bash
/az-cli
# Provides expert guidance on az CLI commands, authentication, and best practices
```

**Infrastructure Deployment:**
```bash
/azure-deploy
# Assists with ARM, Bicep, or Terraform deployments
```

### Agents

The plugin includes specialized expert agents that activate automatically:

- **az-cli-expert**: For all Azure CLI operations
- **arm-bicep-expert**: For ARM templates and Bicep
- **azure-terraform-expert**: For Terraform Azure provider
- **azure-migration-expert**: For Cloud Adoption Framework and migrations
- **azure-resources-expert**: For Azure service configuration

## Capabilities

### Azure Services Covered

**Compute:**
- Virtual Machines
- VM Scale Sets
- Azure Kubernetes Service (AKS)
- App Service
- Azure Functions
- Logic Apps
- Container Instances

**Networking:**
- Virtual Networks (VNets)
- Network Security Groups (NSGs)
- Application Gateway
- Azure Firewall
- Load Balancer
- Traffic Manager
- Front Door
- VPN Gateway
- ExpressRoute

**Storage:**
- Blob Storage
- Azure Files
- Queue Storage
- Table Storage
- Data Lake Storage
- Managed Disks

**Databases:**
- Azure SQL Database
- Cosmos DB
- Azure Database for PostgreSQL
- Azure Database for MySQL
- Azure Database for MariaDB
- SQL Managed Instance

**AI & ML:**
- Azure OpenAI Service
- Cognitive Services
- Machine Learning
- Computer Vision
- Speech Services

**Monitoring & Security:**
- Azure Monitor
- Application Insights
- Log Analytics
- Microsoft Defender for Cloud
- Azure Sentinel
- Key Vault

**Developer Tools:**
- Azure DevOps
- GitHub Actions integration
- Azure CLI
- Azure PowerShell

### Infrastructure-as-Code

**ARM Templates:**
- Template structure and best practices
- Parameter files
- Linked templates
- Deployment validation
- What-if analysis

**Bicep:**
- Modern IaC syntax
- Modules and reusability
- Latest features (2025)
- Compilation to ARM
- Visual Studio Code integration

**Terraform:**
- AzureRM provider
- State management (Azure Storage backend)
- Module development
- Multi-environment deployments
- CI/CD integration
- Import existing resources

### Migration Strategies

**8 Rs Framework:**
1. Rehost (Lift-and-Shift)
2. Refactor (Lift-and-Optimize)
3. Rearchitect
4. Rebuild
5. Replace
6. Retire
7. Retain
8. Relocate

**Migration Tools:**
- Azure Migrate
- Database Migration Service (DMS)
- Azure Data Box
- Azure Site Recovery

**Cloud Adoption Framework:**
- Assessment phase
- Landing zone preparation
- Migration wave planning
- Post-migration optimization

## Best Practices

This plugin ensures all guidance follows:

- **Microsoft Well-Architected Framework**: Five pillars of architectural excellence
- **Cloud Adoption Framework**: Proven migration methodologies
- **Azure Security Benchmarks**: Security best practices
- **Cost Optimization**: Right-sizing, reservations, hybrid benefit
- **High Availability**: Availability zones, disaster recovery
- **Infrastructure-as-Code**: Version-controlled, tested, automated deployments

## Examples

### Example 1: Create a Highly Available Web Application

> "Create a production-ready web application on Azure with high availability, using App Service, Azure SQL Database, Application Gateway with WAF, and monitoring"

The plugin will provide:
- ARM/Bicep template with all resources
- Availability zone configuration
- Security best practices (Key Vault integration, managed identities)
- Monitoring setup (Application Insights, alerts)
- Cost optimization recommendations
- Deployment commands

### Example 2: Migrate On-Premises Database to Azure

> "Help me migrate my on-premises SQL Server 2019 database (500GB) to Azure SQL Database with minimal downtime"

The plugin will guide you through:
- Azure Migrate assessment
- Migration strategy selection (likely online migration)
- Azure Database Migration Service setup
- Data transfer methods
- Testing procedures
- Cutover planning
- Post-migration validation

### Example 3: Terraform Azure Landing Zone

> "Create a Terraform configuration for an Azure landing zone with hub-spoke network topology"

The plugin will provide:
- Terraform configuration using Azure CAF Enterprise Scale module
- Provider configuration with authentication
- Backend configuration for state management
- Network topology setup (hub VNet, spoke VNets, peering)
- Governance setup (policy, RBAC, tags)
- Deployment workflow

## Documentation

For more detailed information:

- **Azure Well-Architected Framework**: Access the skill for comprehensive pillar guidance
- **Agent Documentation**: Each agent file contains detailed instructions and examples
- **Command Reference**: Check command files for specific usage patterns

## Tips & Tricks

1. **Always Fetch Latest Docs**: The plugin fetches the latest Microsoft documentation to ensure current guidance
2. **Start with Assessment**: For migrations, always begin with Azure Migrate assessment
3. **Use What-If**: For ARM/Bicep, use what-if analysis before deploying
4. **Test in Dev First**: Always test deployments in non-production environments
5. **Leverage Agents**: Agents automatically activate based on context, providing specialized expertise
6. **Security First**: Plugin enforces security best practices (no hardcoded secrets, managed identities, Key Vault)
7. **Cost Awareness**: Recommendations include cost optimization strategies

## Requirements

- Claude Code (latest version)
- Azure subscription (for actual deployments)
- Azure CLI installed (for az CLI guidance)
- Terraform installed (for Terraform guidance)
- Git (for version control of IaC code)

## Platform Support

- ✅ Windows (Git Bash, PowerShell, WSL)
- ✅ macOS
- ✅ Linux

## Updates

This plugin is regularly updated to include:
- Latest Azure service features
- New Bicep language capabilities
- Updated Terraform provider versions
- Cloud Adoption Framework updates
- Well-Architected Framework changes

## Contributing

This plugin is part of the claude-code-marketplace. To contribute or report issues:

1. Visit: https://github.com/JosiahSiegel/claude-code-marketplace
2. Open an issue or pull request
3. Follow the contribution guidelines

## License

MIT License - See LICENSE file for details

## Author

Josiah Siegel

## Version

1.0.0

## Keywords

azure, cloud, microsoft, arm, bicep, terraform, az-cli, deployment, migration, infrastructure, iac, compute, networking, storage, database, well-architected, caf, governance, security

---

**🚀 Get started**: Install the plugin and ask Claude to help with any Azure task!
