# Azure-to-Docker Master Plugin

Complete toolkit for extracting Azure infrastructure and creating local Docker development environments.

## Overview

This plugin provides comprehensive automation for migrating Azure infrastructure to local Docker Compose stacks. Perfect for developers who want to:

- **Eliminate Azure costs** for local development
- **Work offline** without Azure connectivity
- **Faster iteration** with local containers
- **Consistent environments** across the team
- **Production parity** with Docker equivalents

## Features

### 🔍 Programmatic Azure Extraction
- Automatically scan and extract entire Azure resource groups
- Extract configurations from all major Azure services
- Generate organized directory structures with all configs
- Export databases with ready-to-use scripts
- Transform connection strings for Docker compatibility

### 🐳 Docker Generation
- Auto-generate production-ready Dockerfiles for all runtimes
- Create complete docker-compose.yml with all services
- Map Azure services to Docker container equivalents
- Configure networking, volumes, and dependencies
- Include health checks and resource limits

### 📚 Comprehensive Documentation
- 8,500+ lines of guides and references
- 450+ Azure CLI command examples
- Complete migration workflows
- Troubleshooting guides
- Security best practices

### 🛠️ Powerful Scripts
- **azure-infrastructure-extractor.sh** (900+ lines) - Full extraction automation for Linux/macOS/Git Bash
- **azure-infrastructure-extractor.ps1** (600+ lines) - Windows PowerShell version
- **dockerfile-generator.sh** (500+ lines) - Multi-runtime Dockerfile generator

## Installation

### Via Marketplace (Recommended)

```bash
/plugin marketplace add JosiahSiegel/claude-code-marketplace
/plugin install azure-to-docker-master@claude-code-marketplace
```

### Verify Installation

```bash
/help | grep "azure"
# Should show azure-to-docker commands

/agents | grep -i azure
# Should show Azure extraction agents
```

## Quick Start

### Extract Azure Infrastructure

```bash
# Linux/macOS/Git Bash
/extract-infrastructure

# Claude will guide you through:
# 1. Azure CLI authentication check
# 2. Resource group selection
# 3. Running extraction script
# 4. Reviewing generated configs
```

### Generate Dockerfiles

```bash
/generate-dockerfile

# Claude will:
# 1. Detect runtimes from Azure configs
# 2. Generate optimized Dockerfiles
# 3. Create .dockerignore files
# 4. Add docker-compose entries
```

### Export Databases

```bash
/export-database

# Claude helps with:
# 1. Choosing export method (BACPAC, pg_dump, mysqldump)
# 2. Running export commands
# 3. Setting up local containers
# 4. Importing data
```

## Commands

### `/extract-infrastructure`
Extract complete Azure resource group to Docker-ready configs.

**What it does:**
- Scans all resources in the resource group
- Extracts configurations (App Services, Databases, Storage, etc.)
- Generates .env files with transformed connection strings
- Creates database export scripts
- Produces docker-compose.yml

**Output:**
```
azure-export/RESOURCE_GROUP_*/
├── resource-group-info.json
├── app-services/
│   ├── webapp1-config.json
│   ├── webapp1-appsettings.json
│   └── webapp1.env
├── databases/
│   ├── sqldb1-details.json
│   └── export-sqldb1.sh
├── dockerfiles/
│   ├── webapp1-Dockerfile
│   └── webapp1-compose.yml
└── docker-compose-generated.yml
```

### `/generate-dockerfile`
Create production-ready Dockerfiles from Azure App Service configurations.

**Supported Runtimes:**
- Node.js (16, 18, 20, 22 LTS)
- Python (3.9, 3.10, 3.11, 3.12)
- .NET (6.0, 7.0, 8.0)
- PHP (8.0, 8.1, 8.2, 8.3)
- Java (11, 17, 21)
- Ruby (3.0, 3.1, 3.2, 3.3)

**Features:**
- Multi-stage builds
- Security best practices
- Non-root users
- Health checks
- Layer optimization

### `/export-database`
Export Azure databases for local Docker containers.

**Supported Databases:**
- Azure SQL Database → SQL Server container
- Azure Database for PostgreSQL → PostgreSQL container
- Azure Database for MySQL → MySQL container

**Export Methods:**
- BACPAC (Azure SQL)
- pg_dump (PostgreSQL)
- mysqldump (MySQL)
- Portal export
- SqlPackage CLI

## Agents

### Azure Extraction Expert
Specialist in extracting Azure configurations and converting to Docker formats.

**When activated:**
- Azure infrastructure questions
- Resource extraction tasks
- Configuration transformation needs
- Connection string conversions

**Capabilities:**
- Complete Azure CLI mastery
- All Azure service knowledge
- Docker mapping expertise
- Security-first approach

### Docker Compose Generator
Expert in creating production-ready docker-compose.yml files.

**When activated:**
- Multi-service orchestration
- Service dependency management
- Network and volume configuration
- Docker Compose optimization

**Capabilities:**
- Best practice enforcement
- Security configuration
- Health check setup
- Resource management

## Documentation

Located in `docs/` directory:

### Quick References
- **AZURE-TO-DOCKER-QUICKSTART.md** (9KB) - Start here! 10-minute quick start
- **AZURE-EXTRACTION-SUMMARY.md** (16KB) - Cheat sheet for common tasks
- **README-AZURE-DOCKER-TOOLKIT.md** (14KB) - Toolkit overview

### Complete Guides
- **AZURE-TO-DOCKER-COMPLETE-GUIDE.md** (23KB) - Full migration guide (60 pages)
- **azure-to-docker-compose-guide.md** (45KB) - Detailed docker-compose guide
- **AZURE-CLI-COMMANDS-REFERENCE.md** (27KB) - 450+ CLI commands

### Examples
- **EXAMPLE-COMPLETE-WORKFLOW.md** (22KB) - Real e-commerce migration in 30 minutes

### Navigation
- **AZURE-TO-DOCKER-INDEX.md** (16KB) - Complete navigation guide

## Usage Examples

### Example 1: Simple Web App + Database

```bash
# 1. Extract from Azure
/extract-infrastructure
# Specify resource group: my-web-app-rg

# 2. Navigate to output
cd azure-export/my-web-app-rg_*/

# 3. Review and start
docker compose up -d

# 4. Access your app
http://localhost:8080
```

### Example 2: Microservices Architecture

```bash
# Extract full microservices stack
/extract-infrastructure
# Specify resource group: microservices-prod

# Generated docker-compose.yml includes:
# - 5 API services
# - SQL Server
# - PostgreSQL
# - Redis
# - Azure Storage (Azurite)
# - Monitoring (Jaeger + Grafana)

# Start all services
docker compose up -d

# Check health
docker compose ps
```

### Example 3: Database-Only Migration

```bash
# Export specific database
/export-database
# Select: Azure SQL Database
# Method: BACPAC

# Import to local container
docker run -d --name sqlserver \
  -e "ACCEPT_EULA=Y" \
  -e "SA_PASSWORD=YourPassword" \
  -p 1433:1433 \
  mcr.microsoft.com/mssql/server:2022-latest

# Import BACPAC (command provided by agent)
```

## Azure Service Mappings

| Azure Service | Docker Equivalent | Port |
|--------------|-------------------|------|
| Azure SQL Database | SQL Server 2022 | 1433 |
| App Service | Custom container | 8080 |
| Azure Redis | Redis 7 | 6379 |
| Azure Storage | Azurite | 10000-02 |
| PostgreSQL | PostgreSQL 15 | 5432 |
| MySQL | MySQL 8.0 | 3306 |
| Cosmos DB | Cosmos Emulator | 8081 |
| Service Bus | Service Bus Emulator | 5672 |
| App Insights | Jaeger + OTEL | 16686 |

## Platform Compatibility

- ✅ **Linux**: Full support (all features)
- ✅ **macOS**: Full support (all features)
- ✅ **Windows**: Full support
  - PowerShell script for extraction
  - Bash script works in Git Bash
  - Docker Desktop required

## Prerequisites

### Required
- **Azure CLI** (`az`) - Latest version
- **Docker** - Version 20.10+
- **Docker Compose** - v2.0+
- **Git** - For Git Bash on Windows

### Optional (for specific features)
- **jq** - JSON parsing in scripts
- **SqlPackage** - Advanced SQL operations
- **pg_dump/pg_restore** - PostgreSQL operations
- **mysqldump** - MySQL operations

### Installation

```bash
# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Docker (Linux)
curl -fsSL https://get.docker.com | sh

# jq
sudo apt-get install jq     # Debian/Ubuntu
brew install jq             # macOS
```

## Security Best Practices

### Secrets Management
- ✅ Use .env files for local secrets
- ✅ Add .env to .gitignore
- ✅ Never commit passwords
- ✅ Use Docker secrets in compose files
- ✅ Encrypt sensitive exports

### Network Security
- ✅ Use internal networks in docker-compose
- ✅ Only expose necessary ports
- ✅ Configure TLS where possible
- ✅ Use non-root users in containers
- ✅ Apply security options (no-new-privileges)

### Database Security
- ✅ Strong passwords for local databases
- ✅ Restrict database user permissions
- ✅ Encrypt backups containing sensitive data
- ✅ Clean up exports from Azure Storage
- ✅ Use Azure Key Vault for production secrets

## Integration with Other Plugins

### docker-master
After generating Dockerfiles:
```bash
# Review with docker-master
/docker-security

# Claude will:
# - Check CIS Docker Benchmark compliance
# - Identify security issues
# - Suggest optimizations
# - Validate best practices
```

### azure-master
For Azure-specific questions:
```bash
# Ask azure-master for details
# Agent automatically activates for Azure questions
```

### bash-master
For script improvements:
```bash
# Review extraction scripts
# Agent helps with ShellCheck compliance
```

## Troubleshooting

### Extraction Script Fails

**Check Azure CLI auth:**
```bash
az account show
```

**Verify resource group:**
```bash
az group show --name RESOURCE_GROUP
```

**Permissions:**
```bash
az role assignment list --scope /subscriptions/SUB_ID/resourceGroups/RG_NAME
```

### Docker Compose Errors

**Services won't start:**
```bash
# Check logs
docker compose logs SERVICE_NAME

# Verify health
docker compose ps
```

**Port conflicts:**
```bash
# Change ports in .env
DB_PORT=1434  # Instead of 1433
```

### Database Import Fails

**SQL Server memory:**
```yaml
sqlserver:
  deploy:
    resources:
      limits:
        memory: 4G  # Increase if needed
```

**Connection timeouts:**
```bash
# Wait for healthy status
docker compose ps
# Wait until health shows "healthy"
```

## Performance Tips

### Faster Extraction
- Run during off-peak hours for large resource groups
- Use parallel database exports (custom scripts)
- Compress exports before download

### Faster Containers
- Use BuildKit for Docker builds
- Configure layer caching
- Use .dockerignore properly
- Optimize base images (alpine variants)

### Resource Management
```yaml
# Set appropriate limits
services:
  webapp:
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 1G
```

## Cost Savings

**Typical Savings:**
- 10 developers × $500/month Azure dev environments = **$5,000/month**
- Local Docker: **$0/month**
- **Annual savings: $60,000**

**Additional Benefits:**
- Faster iteration (no Azure latency)
- Work offline
- No Azure quota limits
- Test destructive operations safely

## Contributing

Found a bug or have a suggestion?

1. File an issue in the marketplace repo
2. Suggest improvements to extraction scripts
3. Share your Azure service mappings
4. Contribute Docker Compose patterns

## License

MIT License - See LICENSE file for details

## Support

- 📖 **Documentation**: See `docs/` directory
- 🤖 **Ask Claude**: Use the commands and agents
- 💬 **Community**: Claude Code community Discord
- 🐛 **Issues**: GitHub issues in marketplace repo

## Version History

### 1.0.0 (2025-10-25)
- Initial release
- Azure infrastructure extraction scripts
- Dockerfile generation
- Docker Compose automation
- Comprehensive documentation
- Azure extraction expert agent
- Docker Compose generator agent
- 10 detailed documentation files
- Support for all major Azure services

## Credits

Created with ❤️ by Josiah Siegel

Powered by:
- Claude Code plugin system
- Azure CLI
- Docker & Docker Compose
- Community feedback and testing
