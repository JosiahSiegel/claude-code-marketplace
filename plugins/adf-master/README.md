# adf-master

Complete Azure Data Factory expertise system for ALL platforms and deployment methods.

## Overview

The **adf-master** plugin provides comprehensive Azure Data Factory expertise, covering everything from pipeline design to CI/CD automation. It includes both modern npm-based deployment approaches and traditional methods, ensuring you can work with any ADF setup.

## Key Features

### 🚀 CI/CD Automation
- **Modern Automated CI/CD** using `@microsoft/azure-data-factory-utilities` v1.0.3+
- **Traditional Manual CI/CD** with Git integration and publish button
- **GitHub Actions workflows** with complete templates
- **Azure DevOps pipelines** (YAML and classic)
- **ARM template deployment** with PowerShell and Azure CLI
- **PrePostDeploymentScript.Ver2** for intelligent trigger management

### 🔧 Pipeline Development
- Pipeline design following Microsoft best practices
- Data transformation patterns (SCD, incremental load, metadata-driven)
- Performance optimization strategies
- Error handling and retry logic
- Monitoring and logging patterns

### 🐛 Troubleshooting & Debugging
- Systematic debugging approaches
- Common error patterns and solutions
- CI/CD deployment troubleshooting
- Performance analysis with Log Analytics queries
- Integration runtime issues

### 📊 Performance Optimization
- Copy activity optimization (DIUs, staging, partitioning)
- Data Flow performance tuning
- Cost reduction strategies
- Incremental load patterns
- Resource sizing guidance

## Installation

### Via Marketplace (Recommended)

```bash
# Add the marketplace
/plugin marketplace add JosiahSiegel/claude-code-marketplace

# Install the plugin
/plugin install adf-master@JosiahSiegel
```

### Verify Installation

```bash
# See available commands
/help

# See available agents
/agents
```

## Commands

### `/adf-master:adf-cicd-setup`
Interactive setup for Azure Data Factory CI/CD with GitHub Actions or Azure DevOps.

**What it does:**
- Assesses your current environment and requirements
- Generates complete CI/CD pipelines (build and deploy)
- Configures GitHub Actions workflows or Azure DevOps YAML pipelines
- Sets up PrePostDeploymentScript.Ver2 integration
- Guides you through secrets and variables configuration
- Provides testing and validation steps

**When to use:**
- Setting up CI/CD for the first time
- Migrating from traditional to modern CI/CD
- Adding new environments (test, production)
- Troubleshooting existing CI/CD pipelines

**Example usage:**
```
User: "Set up CI/CD for my Azure Data Factory using GitHub Actions"

Claude: I'll guide you through setting up modern automated CI/CD for Azure Data Factory using GitHub Actions...
[Provides complete workflow templates, secret configuration guide, and testing steps]
```

### `/adf-master:adf-pipeline-create`
Create Azure Data Factory pipelines following Microsoft best practices.

**What it does:**
- Designs pipeline architecture based on requirements
- Implements proper parameterization
- Adds error handling and retry logic
- Optimizes for performance
- Includes monitoring and logging
- Provides production-ready pipeline JSON

**When to use:**
- Creating new pipelines from scratch
- Implementing common patterns (incremental load, SCD, metadata-driven)
- Need guidance on pipeline design decisions
- Want production-ready code with best practices

**Example usage:**
```
User: "Create a pipeline to incrementally load sales data from SQL to Data Lake"

Claude: I'll create an incremental load pipeline with watermark tracking...
[Provides complete pipeline JSON with lookup activities, copy activity, and watermark update]
```

### `/adf-master:adf-pipeline-debug`
Debug Azure Data Factory pipeline failures with systematic analysis.

**What it does:**
- Analyzes error messages and patterns
- Uses ADF monitoring tools for investigation
- Provides step-by-step debugging approach
- Offers solutions for common failure scenarios
- Generates Log Analytics queries for analysis
- Implements custom logging patterns

**When to use:**
- Pipeline is failing and you need to diagnose why
- Works in debug mode but fails when triggered
- Intermittent failures
- Performance degradation issues
- Need to set up better monitoring

**Example usage:**
```
User: "My copy activity is failing with 'OperationTimedOut' error"

Claude: Let's troubleshoot this timeout issue systematically...
[Analyzes timeout causes, suggests increasing timeout, optimizing source query, and checking network connectivity]
```

### `/adf-master:adf-arm-template`
Generate, validate, and deploy Azure Data Factory ARM templates using npm utilities.

**What it does:**
- Validates ADF resources before deployment
- Generates ARM templates using npm or UI
- Creates environment-specific parameter files
- Deploys using PowerShell or Azure CLI
- Integrates PrePostDeploymentScript
- Provides what-if analysis

**When to use:**
- Generating ARM templates for deployment
- Validating resources before publishing
- Creating parameter files for multiple environments
- Deploying to test or production
- Troubleshooting template deployment issues

**Example usage:**
```
User: "Generate and deploy ARM templates to my test environment"

Claude: I'll help you generate and deploy ARM templates...
[Provides npm commands for generation, parameter file creation, and PowerShell deployment script]
```

### `/adf-master:adf-troubleshoot`
Troubleshoot common Azure Data Factory CI/CD and runtime issues.

**What it does:**
- Diagnoses CI/CD build and deployment failures
- Troubleshoots npm validation errors
- Resolves ARM deployment issues
- Debugs PrePostDeploymentScript errors
- Fixes authentication and permission problems
- Analyzes performance issues

**When to use:**
- CI/CD pipeline is failing
- ARM template deployment errors
- GitHub Actions or Azure DevOps issues
- PrePostDeploymentScript errors
- Authentication failures
- Need Log Analytics queries for investigation

**Example usage:**
```
User: "My Azure DevOps pipeline is failing with 'Template parameters are not valid'"

Claude: This error typically occurs when a trigger was deleted in dev but the parameter still exists...
[Provides detailed troubleshooting steps and solutions]
```

### `/adf-master:adf-optimize`
Optimize Azure Data Factory pipelines for performance, cost, and efficiency.

**What it does:**
- Analyzes current performance metrics
- Optimizes copy activities (DIUs, staging, partitioning)
- Tunes data flow performance
- Reduces costs with incremental loads
- Right-sizes compute resources
- Provides baseline comparisons and ROI calculations

**When to use:**
- Pipelines are slow or timing out
- High Azure costs
- Need to improve performance
- Want to implement incremental loads
- Optimizing for specific data volumes

**Example usage:**
```
User: "My data flow is taking hours to complete and costing too much"

Claude: Let's optimize your data flow performance and cost...
[Analyzes compute sizing, partitioning strategy, and provides cost reduction recommendations]
```

## Agents

### `adf-expert`
Complete Azure Data Factory expertise across all operations.

**Expertise:**
- Pipeline design and architecture
- Data transformation patterns
- Integration patterns (source-to-sink, real-time vs batch)
- Performance optimization
- Security and compliance
- All ADF components (linked services, datasets, activities, triggers, IRs)

**When activated:**
- Automatically when you work on ADF pipelines
- When you need design guidance
- For complex transformation logic
- When implementing best practices

**Example:**
```
User: "How do I implement a Type 2 Slowly Changing Dimension in ADF?"

adf-expert: I'll guide you through implementing SCD Type 2 using Data Flow...
[Provides complete data flow transformation logic with conditional splits and historical tracking]
```

### `adf-cicd-expert`
Complete Azure Data Factory CI/CD expertise.

**Expertise:**
- Modern automated CI/CD (@microsoft/azure-data-factory-utilities)
- Traditional manual CI/CD methods
- GitHub Actions workflows
- Azure DevOps pipelines
- ARM template deployment
- PrePostDeploymentScript
- Multi-environment strategies

**When activated:**
- Automatically when working on CI/CD setup
- For deployment automation
- When troubleshooting build/deploy failures
- For multi-environment configuration

**Example:**
```
User: "Set up automated deployment from GitHub to multiple environments"

adf-cicd-expert: I'll create a complete GitHub Actions workflow for multi-environment deployment...
[Provides build workflow, deployment workflow, environment configuration, and secret setup]
```

## Skills

### `adf-master` Skill
Comprehensive knowledge base with:
- Official documentation sources and URLs
- CI/CD deployment methods (modern and traditional)
- npm package configuration
- PrePostDeploymentScript Ver2 details
- GitHub Actions and Azure DevOps resources
- ARM template deployment commands
- Troubleshooting resources and error patterns
- Best practices and repository structure

**How it helps:**
The skill provides detailed reference information that agents and commands can access on-demand, ensuring all guidance is based on the latest official documentation and proven patterns.

## Use Cases

### Setting Up CI/CD for the First Time
```bash
# Use the interactive setup command
/adf-master:adf-cicd-setup
```
**Result:** Complete CI/CD pipelines generated for your platform (GitHub or Azure DevOps), with all configuration steps documented.

### Creating a New Pipeline
```bash
# Use the pipeline creation command
/adf-master:adf-pipeline-create
```
**Result:** Production-ready pipeline with parameterization, error handling, logging, and best practices.

### Debugging a Failed Pipeline
```bash
# Use the debugging command
/adf-master:adf-pipeline-debug
```
**Result:** Systematic diagnosis of the failure with specific solutions and monitoring recommendations.

### Optimizing Performance
```bash
# Use the optimization command
/adf-master:adf-optimize
```
**Result:** Performance improvements with measurable metrics and cost reduction strategies.

### Deploying to New Environment
```bash
# Use the ARM template command
/adf-master:adf-arm-template
```
**Result:** Generated templates, parameter files, and deployment scripts for your target environment.

## Best Practices

This plugin enforces Microsoft best practices:

1. **Parameterization** - Everything configurable should be parameterized
2. **Error Handling** - Comprehensive retry and logging
3. **Incremental Loads** - Avoid full refreshes
4. **Security** - Managed Identity and Key Vault for secrets
5. **Monitoring** - Log Analytics and alerts
6. **Testing** - Debug mode before production
7. **Git Configuration** - Only on development environment
8. **Modular Design** - Reusable child pipelines
9. **Modern CI/CD** - npm-based automated deployments
10. **Documentation** - Clear purpose and dependencies

## Documentation Sources

All guidance is based on:

- **Microsoft Learn:** https://learn.microsoft.com/en-us/azure/data-factory/
- **Context7 Library:** `/websites/learn_microsoft_en-us_azure_data-factory` (10,839 code snippets)
- **npm Package:** https://www.npmjs.com/package/@microsoft/azure-data-factory-utilities
- **PrePostDeploymentScript:** https://github.com/Azure/Azure-DataFactory/tree/main/SamplesV2/ContinuousIntegrationAndDelivery
- **Community Guides:** Medium, TechCommunity, blogs (2025 content)

## Requirements

### For CI/CD Setup:
- **Node.js:** Version 20.x or compatible
- **npm package:** `@microsoft/azure-data-factory-utilities` v1.0.3+
- **Azure CLI** or **PowerShell:** For ARM template deployment
- **GitHub** or **Azure DevOps:** For CI/CD pipelines
- **Azure permissions:** Contributor on Data Factory and Resource Group

### For General Use:
- Azure Data Factory resource (any tier)
- Access to Azure Portal or ADF Studio
- Appropriate RBAC permissions for your tasks

## Support

### Getting Help

If you encounter issues or have questions:

1. **Use the troubleshooting command:** `/adf-master:adf-troubleshoot`
2. **Check official documentation:** Microsoft Learn links in skill
3. **Community support:**
   - Microsoft Q&A: https://learn.microsoft.com/en-us/answers/tags/130/azure-data-factory
   - Stack Overflow: Tag `azure-data-factory`
4. **Azure Status:** https://status.azure.com (service outages)

### Filing Issues

For plugin-specific issues:
- Repository: https://github.com/JosiahSiegel/claude-code-marketplace
- Create an issue with:
  - Command or feature used
  - Expected vs actual behavior
  - Error messages (if any)
  - Your environment (Node.js version, platform, etc.)

## Version History

### 1.0.0 (January 2025)
- Initial release
- 6 comprehensive slash commands
- 2 specialized agents
- Complete skill with documentation sources
- Support for both modern and traditional CI/CD
- GitHub Actions and Azure DevOps templates
- ARM template deployment guidance
- Troubleshooting and optimization tools

## Contributing

Contributions welcome! Areas for enhancement:
- Additional pipeline patterns
- More CI/CD platform support (GitLab, Bitbucket)
- Advanced debugging techniques
- Performance benchmarks
- Cost optimization strategies

## License

MIT License - See LICENSE file for details.

## Author

**Josiah Siegel**
- Email: JosiahSiegel@users.noreply.github.com
- Marketplace: JosiahSiegel/claude-code-marketplace

## Acknowledgments

- Microsoft Azure Data Factory team for excellent documentation
- Community contributors to CI/CD patterns
- @microsoft/azure-data-factory-utilities package maintainers
- Azure Data Factory GitHub samples repository

---

**Ready to master Azure Data Factory? Install the plugin and start with:**

```bash
# Interactive CI/CD setup
/adf-master:adf-cicd-setup

# Or create your first optimized pipeline
/adf-master:adf-pipeline-create

# Or get help with any ADF task
# The agents activate automatically!
```

**Happy data engineering! 🚀**
