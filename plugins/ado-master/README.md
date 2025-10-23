# ADO Master Plugin

Master Azure DevOps pipelines with expert knowledge of YAML pipelines, CI/CD best practices, security, CLI operations, and industry standards.

## Overview

The ADO Master plugin equips Claude Code with comprehensive Azure DevOps expertise, enabling you to create, optimize, secure, and debug Azure Pipelines following current Microsoft best practices.

## Features

### Commands

- **`/ado-pipeline-create`** - Create new YAML pipelines following current best practices and industry standards
- **`/ado-pipeline-optimize`** - Optimize pipelines for performance, cost, and efficiency
- **`/ado-pipeline-security`** - Secure pipelines following security best practices and compliance standards
- **`/ado-pipeline-debug`** - Debug pipeline failures and troubleshoot common issues
- **`/ado-tasks`** - Help with common Azure DevOps pipeline tasks and their usage
- **`/ado-cli`** - Manage Azure DevOps using Azure DevOps CLI
- **`/ado-repo`** - Manage repositories, branches, and Git operations

### Agent

- **ADO Expert Agent** - Comprehensive Azure DevOps expert with knowledge of:
  - Azure Pipelines YAML schema and best practices
  - CI/CD patterns and deployment strategies
  - Task-specific expertise (all Azure Pipelines tasks)
  - Security and compliance implementation
  - Performance optimization techniques
  - Systematic troubleshooting
  - Azure DevOps CLI automation

### Skills

- **ado-pipeline-best-practices** - Best practices for Azure Pipelines structure, triggers, variables, and more

## Installation

### Via Marketplace

```bash
/plugin marketplace add JosiahSiegel/claude-code-marketplace
/plugin install ado-master@JosiahSiegel
```

## Usage

### Creating New Pipelines

```bash
/ado-pipeline-create
```

Claude will:
1. Check latest Azure Pipelines YAML schema
2. Gather your requirements (language, platform, deployment)
3. Create complete pipeline with best practices
4. Apply security and performance optimizations
5. Provide setup instructions

### Optimizing Existing Pipelines

```bash
/ado-pipeline-optimize
```

Claude will:
1. Analyze current pipeline performance
2. Identify bottlenecks and inefficiencies
3. Implement caching and parallelization
4. Reduce costs and execution time
5. Provide before/after metrics

### Securing Pipelines

```bash
/ado-pipeline-security
```

Claude will:
1. Audit pipeline security
2. Implement secrets management (Azure Key Vault)
3. Add code scanning (SAST, dependency scanning)
4. Configure approval gates and policies
5. Apply compliance standards

### Debugging Failures

```bash
/ado-pipeline-debug
```

Claude will:
1. Analyze logs and failure patterns
2. Identify root cause
3. Provide step-by-step fix
4. Add prevention measures
5. Show verification commands

### Working with Tasks

```bash
/ado-tasks
```

Claude will help you use specific Azure Pipelines tasks with:
- Latest task versions
- Complete working examples
- Best practices for each task
- Error handling recommendations

### CLI Operations

```bash
/ado-cli
```

Claude will provide Azure DevOps CLI commands for:
- Pipeline management
- Repository operations
- Variable and variable group management
- Automation scripts

### Expert Consultation

```bash
/agent ado-expert
```

The ADO Expert agent can help with:
- Complex multi-stage pipelines
- Template design and reusability
- Deployment strategy selection
- Azure service integration
- Troubleshooting complex issues
- CLI automation scripts

## Key Principles

This plugin ensures Claude always:

1. **Checks Latest Documentation** - Fetches current Azure Pipelines docs before recommendations
2. **Follows Microsoft Best Practices** - Implements official recommended patterns
3. **Security-First** - Prioritizes security in all pipeline designs
4. **Comprehensive Examples** - Provides complete, working YAML
5. **Current Task Versions** - Uses latest stable task versions
6. **Explains Rationale** - Teaches why, not just what

## Best Practices Applied

### Pipeline Structure
- Multi-stage YAML for complex workflows
- Templates for reusability
- Runtime parameters for flexibility
- Proper stage dependencies
- Conditional execution

### Security
- Azure Key Vault integration
- No hardcoded secrets
- Code scanning (SAST, dependency, container)
- Branch policies and protection
- Approval gates for production
- Service connections with least privilege

### Performance
- Dependency caching (npm, NuGet, Maven, pip)
- Job parallelization
- Shallow git clone
- Appropriate agent selection
- Artifact cleanup

### Quality
- Automated testing integration
- Code coverage requirements
- Quality gates (SonarQube)
- Test result publishing
- Build validation for PRs

## Technology Support

### Languages & Frameworks
- .NET / .NET Core
- Node.js / JavaScript / TypeScript
- Python
- Java (Maven, Gradle)
- Go
- Ruby
- PHP

### Platforms
- Azure services (Web Apps, Functions, Container Registry, Kubernetes)
- Docker and containers
- Kubernetes and Helm
- On-premises deployments
- Multi-cloud scenarios

### Tools & Integrations
- Docker and container registries
- Kubernetes and AKS
- Azure services
- SonarQube / SonarCloud
- Security scanning tools
- Test frameworks

## Common Workflows

### Full CI/CD Pipeline

```bash
# 1. Create optimized pipeline
/ado-pipeline-create

# 2. Add security scanning
/ado-pipeline-security

# 3. Optimize for performance
/ado-pipeline-optimize

# Result: Production-ready, secure, optimized pipeline
```

### Debug and Fix

```bash
# Pipeline failing?
/ado-pipeline-debug

# Claude will:
# - Analyze logs
# - Identify issue
# - Provide fix
# - Prevent recurrence
```

### CLI Automation

```bash
/ado-cli

# Get commands for:
# - Bulk operations
# - Automation scripts
# - Monitoring and reporting
```

## Example Scenarios

### Scenario: New Node.js Application

User: "I need a CI/CD pipeline for my Node.js app deployed to Azure Web App"

```bash
/ado-pipeline-create
```

Result:
- Complete YAML pipeline
- npm caching
- Test execution
- Build optimization
- Azure Web App deployment
- Environment-specific stages

### Scenario: Slow Docker Builds

User: "My Docker builds take 30 minutes. Can we optimize?"

```bash
/ado-pipeline-optimize
```

Result:
- Docker layer caching implemented
- Build time reduced to 5 minutes
- Cost savings calculated
- Multi-stage build optimization

### Scenario: Security Audit Required

User: "We need to pass security audit. Help secure our pipelines."

```bash
/ado-pipeline-security
```

Result:
- Key Vault integration
- Code scanning added
- Container vulnerability scanning
- Approval gates configured
- Compliance documentation

## Requirements

- Azure DevOps organization
- Access to create/edit pipelines
- Appropriate permissions for target environments
- Azure subscription (for Azure deployments)

## Recommended Tools

This plugin references:
- **Azure DevOps CLI** - Command-line management
- **Azure CLI** - Azure resource management
- **SonarQube/SonarCloud** - Code quality
- **Trivy/Aqua** - Container scanning
- **OWASP Dependency Check** - Dependency scanning

## Learning Resources

The plugin provides guidance on:
- Microsoft Learn Azure Pipelines docs
- YAML schema reference
- Task documentation
- Best practices guides
- Security recommendations

## Contributing

This plugin stays current with Azure DevOps monthly updates. Feedback and improvements welcome!

## License

MIT

## Support

For issues or questions:
- Use commands for specific guidance
- Consult `/agent ado-expert` for complex scenarios
- Check Microsoft Learn documentation
- Review Azure DevOps release notes

---

**Master Azure DevOps pipelines with confidence.** This plugin ensures you follow current Microsoft best practices, maintain security, optimize performance, and build production-ready CI/CD pipelines.
