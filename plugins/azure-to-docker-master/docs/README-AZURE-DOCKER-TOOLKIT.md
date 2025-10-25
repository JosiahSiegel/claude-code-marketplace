# Azure to Docker Migration Toolkit

Complete toolkit for extracting Azure infrastructure configurations and creating local Docker development environments.

## 📋 What This Toolkit Does

This toolkit programmatically extracts **everything** needed to containerize existing Azure infrastructure:

- ✅ **Web Apps** - Runtime, settings, connection strings, startup commands
- ✅ **Databases** - SQL Server, PostgreSQL, MySQL, Cosmos DB schemas and data
- ✅ **Storage** - Containers, queues, tables, access keys
- ✅ **Caching** - Redis configuration and connection details
- ✅ **Secrets** - Key Vault secret names and values
- ✅ **Monitoring** - Application Insights configuration
- ✅ **Networking** - VNet, NSG, load balancer settings

**Output**: Production-ready Docker Compose environment for local development.

## 🚀 Quick Start

### Prerequisites
```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLI | sudo bash

# Install Docker
# https://docs.docker.com/get-docker/

# Install jq (JSON processor)
sudo apt-get install jq  # Ubuntu/Debian
brew install jq          # macOS
```

### 3-Step Migration

```bash
# 1. Extract Azure infrastructure
./azure-infrastructure-extractor.sh <resource-group-name>

# 2. Navigate to output
cd azure-export/<resource-group-name>_*/

# 3. Generate and start
./scripts/generate-docker-compose.sh
docker compose -f docker-compose-generated.yml up -d
```

## 📁 Toolkit Contents

### Main Scripts

| File | Description | Platform |
|------|-------------|----------|
| **azure-infrastructure-extractor.sh** | Complete infrastructure extraction | Bash |
| **azure-infrastructure-extractor.ps1** | Complete infrastructure extraction | PowerShell |
| **dockerfile-generator.sh** | Auto-generate Dockerfiles from runtime configs | Bash |

### Documentation

| File | Contents |
|------|----------|
| **AZURE-CLI-COMMANDS-REFERENCE.md** | Complete Azure CLI command reference (100+ commands) |
| **AZURE-TO-DOCKER-COMPLETE-GUIDE.md** | Detailed migration guide with troubleshooting |
| **AZURE-EXTRACTION-SUMMARY.md** | Quick reference and cheat sheet |
| **EXAMPLE-COMPLETE-WORKFLOW.md** | Real-world migration example |
| **README-AZURE-DOCKER-TOOLKIT.md** | This file |

## 📖 Documentation Guide

### For First-Time Users
1. Start with **AZURE-EXTRACTION-SUMMARY.md** (quick overview)
2. Run the extraction script
3. Follow **EXAMPLE-COMPLETE-WORKFLOW.md** (real-world example)
4. Refer to **AZURE-TO-DOCKER-COMPLETE-GUIDE.md** as needed

### For Reference
- **AZURE-CLI-COMMANDS-REFERENCE.md** - All Azure CLI commands
- **SERVICE-MAPPING.md** (auto-generated) - Azure → Docker mappings

### For Troubleshooting
- Check **AZURE-TO-DOCKER-COMPLETE-GUIDE.md** → Troubleshooting section
- Review logs in extracted output directory

## 🔧 Detailed Usage

### Extract Infrastructure

**Bash (Linux/macOS/Git Bash):**
```bash
chmod +x azure-infrastructure-extractor.sh
./azure-infrastructure-extractor.sh <resource-group> [output-dir]

# Example
./azure-infrastructure-extractor.sh production-rg ./my-export
```

**PowerShell (Windows):**
```powershell
.\azure-infrastructure-extractor.ps1 -ResourceGroupName <resource-group> [-OutputDirectory <path>]

# Example
.\azure-infrastructure-extractor.ps1 -ResourceGroupName production-rg -OutputDirectory C:\exports
```

### Output Structure

```
azure-export/<resource-group>_<timestamp>/
├── README.md                          # Generated guide
├── SERVICE-MAPPING.md                 # Azure → Docker mappings
├── docker-compose.yml                 # Template
├── all-resources.json                 # All resources (JSON)
├── resource-summary.txt               # Summary (table)
│
├── webapps/<app-name>/               # For each Web App
│   ├── config.json                   # Full configuration
│   ├── runtime.json                  # Runtime (Node, Python, etc.)
│   ├── appsettings.json              # App settings
│   ├── .env                          # Environment variables (ready!)
│   ├── connection-strings.json       # Connection strings
│   ├── startup.json                  # Startup commands
│   ├── container-settings.json       # If containerized
│   └── identity.json                 # Managed identity
│
├── databases/
│   ├── sql-<server>/                 # SQL Server
│   │   ├── server-config.json
│   │   ├── firewall-rules.json
│   │   └── <database>/
│   │       ├── config.json
│   │       ├── tier.json
│   │       ├── connection-string.txt
│   │       ├── docker-connection-string.txt
│   │       └── export-data.sh        # Export script
│   ├── postgres-<server>/            # PostgreSQL
│   ├── mysql-<server>/               # MySQL
│   └── cosmos-<account>/             # Cosmos DB
│
├── storage/<account>/                # Storage Accounts
│   ├── config.json
│   ├── keys.json                     # ⚠️ SENSITIVE
│   ├── connection-string.json        # ⚠️ SENSITIVE
│   ├── containers.json               # Blob containers
│   ├── queues.json                   # Queues
│   ├── tables.json                   # Tables
│   └── docker-config.txt             # Azurite setup
│
├── redis/<cache>/                    # Redis Cache
│   ├── config.json
│   ├── keys.json                     # ⚠️ SENSITIVE
│   └── connection-info.txt
│
├── keyvault/<vault>/                 # Key Vault
│   ├── config.json
│   ├── secret-names.json             # Names only
│   └── local-secrets-template.env    # Template
│
├── appinsights/<app>/                # Application Insights
│   ├── config.json
│   └── instrumentation.json
│
└── scripts/
    ├── extract-keyvault-secrets.sh   # Secret extraction
    └── generate-docker-compose.sh    # Compose generator
```

### Generate Dockerfiles

```bash
cd webapps/my-app
../../dockerfile-generator.sh . ./docker-output

# Output:
# - Dockerfile (production-ready, multi-stage)
# - .dockerignore
# - docker-compose-service.yml
# - build.sh
# - run.sh
```

Supports:
- **Node.js** (any version)
- **Python** (2.7, 3.x)
- **.NET** (Core, 5.0+, Framework)
- **PHP** (5.6, 7.x, 8.x)
- **Java** (8, 11, 17, 21)
- **Already containerized** apps

### Generate Docker Compose

```bash
cd azure-export/<resource-group>_*/
./scripts/generate-docker-compose.sh

# Generates: docker-compose-generated.yml
# Auto-detects:
#   - SQL Server (if SQL databases found)
#   - PostgreSQL (if PostgreSQL found)
#   - MySQL (if MySQL found)
#   - Redis (if Redis Cache found)
#   - Azurite (if Storage Accounts found)
#   - MongoDB (if Cosmos DB found)
```

## 🗂️ Service Mappings

| Azure Service | Docker Image | Port | Config File |
|--------------|--------------|------|-------------|
| Azure SQL Database | `mcr.microsoft.com/mssql/server:2022-latest` | 1433 | `databases/sql-*` |
| Azure PostgreSQL | `postgres:15-alpine` | 5432 | `databases/postgres-*` |
| Azure MySQL | `mysql:8.0` | 3306 | `databases/mysql-*` |
| Cosmos DB (SQL) | `mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator` | 8081 | `databases/cosmos-*` |
| Cosmos DB (MongoDB) | `mongo:6` | 27017 | `databases/cosmos-*` |
| Azure Redis Cache | `redis:7-alpine` | 6379 | `redis/*` |
| Azure Blob Storage | `mcr.microsoft.com/azure-storage/azurite` | 10000 | `storage/*` |
| App Service (Node) | `node:18-alpine` | 8080 | `webapps/*` |
| App Service (Python) | `python:3.11-slim` | 8000 | `webapps/*` |
| App Service (.NET) | `mcr.microsoft.com/dotnet/aspnet:8.0` | 8080 | `webapps/*` |

## 🔐 Security Best Practices

### CRITICAL: Protect Sensitive Data

**These files contain secrets:**
- `**/keys.json`
- `**/connection-string.json`
- `**/.env` (except `.env.example`)
- `**/secrets*.json`

**Immediately after extraction:**
```bash
# Add to .gitignore
cat >> .gitignore <<'EOF'
# Sensitive files - NEVER COMMIT
.env
*.env
!.env.example
**/*keys.json
**/*connection-string*.json
**/secrets*.json

# Database exports
*.bacpac
*.dump
*.sql
EOF

# Set restrictive permissions
find . -name "*.env" -exec chmod 600 {} \;
find . -name "*keys.json" -exec chmod 600 {} \;
```

### Authentication Best Practices

1. **Use Azure CLI with service principal** (not personal account)
2. **Minimum permissions**: Reader role on resource group
3. **Enable audit logging** for extraction activities
4. **Rotate credentials** after extraction
5. **Delete exported files** when no longer needed

## 📊 What Gets Extracted

### Web Apps
- ✅ Runtime stack (Node 18, Python 3.11, .NET 8.0, etc.)
- ✅ All app settings (environment variables)
- ✅ All connection strings
- ✅ Startup commands
- ✅ Scaling configuration
- ✅ VNet integration
- ✅ Managed identity details
- ✅ Container settings (if already containerized)

### Databases
- ✅ Server configuration (version, tier, location)
- ✅ Database schemas (via export scripts)
- ✅ Firewall rules
- ✅ Performance tier (Basic, Standard, Premium)
- ✅ Connection strings (Azure & local)
- ✅ Server parameters (PostgreSQL/MySQL)

### Storage
- ✅ Account type (Standard, Premium)
- ✅ Replication (LRS, GRS, RA-GRS)
- ✅ Container names
- ✅ Queue names
- ✅ Table names
- ✅ File share names
- ✅ Access keys

### Secrets (Key Vault)
- ✅ Secret names
- ✅ Secret values (via extraction script)
- ✅ Access policies
- ✅ Expiration dates

## 🛠️ Common Workflows

### 1. Complete Migration (Recommended)
```bash
# Extract
./azure-infrastructure-extractor.sh production-rg

# Navigate
cd azure-export/production-rg_*/

# Export databases
for db_dir in databases/*/*/; do
    cd "$db_dir"
    # Edit export-data.sh with credentials
    ./export-data.sh
    cd -
done

# Extract secrets
./scripts/extract-keyvault-secrets.sh

# Generate compose
./scripts/generate-docker-compose.sh

# Customize and start
docker compose -f docker-compose-generated.yml up -d
```

### 2. Single App Migration
```bash
# Extract
./azure-infrastructure-extractor.sh my-rg

# Generate Dockerfile
cd azure-export/my-rg_*/webapps/my-app
../../../dockerfile-generator.sh . ./docker

# Copy app code and start
cd docker
cp -r /path/to/code/* .
./build.sh && ./run.sh
```

### 3. Database Only
```bash
# Extract
./azure-infrastructure-extractor.sh my-rg

# Export database
cd azure-export/my-rg_*/databases/sql-server/mydb
./export-data.sh

# Start local SQL Server
docker run -d -p 1433:1433 \
    -e 'ACCEPT_EULA=Y' \
    -e 'SA_PASSWORD=YourStrong@Pass' \
    mcr.microsoft.com/mssql/server:2022-latest

# Import
sqlpackage /Action:Import /SourceFile:mydb.bacpac ...
```

## 🔍 Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| "az: command not found" | Install Azure CLI: `curl -sL https://aka.ms/InstallAzureCLI \| sudo bash` |
| "Not logged in" | Run `az login` |
| "Resource group not found" | Verify: `az group exists --name <rg>` |
| "Permission denied" | Check RBAC: `az role assignment list --assignee $(az account show --query user.name -o tsv)` |
| SQL connection refused | Wait for healthcheck, verify password complexity |
| Can't resolve service names | Ensure all services on same Docker network |
| Env vars not loading | Check `env_file` path in docker-compose.yml |

### Get Help

1. Check **AZURE-TO-DOCKER-COMPLETE-GUIDE.md** → Troubleshooting
2. Review logs: `docker compose logs -f`
3. Verify extraction: `cat resource-summary.txt`
4. Test connectivity: `docker compose ps`

## 📚 Learning Resources

### Tutorials
- Start: **AZURE-EXTRACTION-SUMMARY.md** (5 min read)
- Example: **EXAMPLE-COMPLETE-WORKFLOW.md** (30 min walkthrough)
- Deep Dive: **AZURE-TO-DOCKER-COMPLETE-GUIDE.md** (comprehensive)

### Reference
- **AZURE-CLI-COMMANDS-REFERENCE.md** - 100+ Azure CLI commands
- **SERVICE-MAPPING.md** (generated) - Azure → Docker mappings
- [Azure CLI Docs](https://docs.microsoft.com/cli/azure/)
- [Docker Docs](https://docs.docker.com/)

## 🎯 Real-World Example

See **EXAMPLE-COMPLETE-WORKFLOW.md** for a complete walkthrough:
- E-commerce application with 2 web apps
- SQL Server database with 110K rows
- Redis cache, storage account, Key Vault
- Complete migration in ~30 minutes

## ✅ Success Checklist

After extraction and setup:

- [ ] All resources extracted successfully
- [ ] Database exported and imported
- [ ] Secrets extracted securely
- [ ] Dockerfiles generated
- [ ] docker-compose.yml customized
- [ ] Connection strings updated for local
- [ ] Sensitive files in .gitignore
- [ ] All services start healthy
- [ ] Application functions correctly
- [ ] Team can reproduce setup

## 🤝 Contributing

Improvements welcome! Key areas:
- Additional Azure service support
- More runtime Dockerfile templates
- Enhanced automation
- Additional documentation

## 📝 License

This toolkit is provided as-is for Azure to Docker migrations.

## 🔗 Related Tools

- [Azure CLI](https://docs.microsoft.com/cli/azure/)
- [SqlPackage](https://docs.microsoft.com/sql/tools/sqlpackage/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Azurite](https://github.com/Azure/Azurite)
- [Azure Data Studio](https://docs.microsoft.com/sql/azure-data-studio/)

---

## Quick Links

- **Get Started**: Run `./azure-infrastructure-extractor.sh <resource-group>`
- **Example**: See `EXAMPLE-COMPLETE-WORKFLOW.md`
- **Reference**: Check `AZURE-CLI-COMMANDS-REFERENCE.md`
- **Help**: Read `AZURE-TO-DOCKER-COMPLETE-GUIDE.md`

**Questions?** Review the documentation files or check the troubleshooting sections.

---

**Last Updated**: 2025-10-25
**Version**: 1.0
