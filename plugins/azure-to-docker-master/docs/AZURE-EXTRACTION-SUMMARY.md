# Azure Infrastructure Extraction - Complete Summary

## What You Have Now

A complete toolkit for extracting Azure infrastructure and creating Docker-based local development environments.

## File Overview

### Main Scripts

| File | Purpose | Platform |
|------|---------|----------|
| `azure-infrastructure-extractor.sh` | Main extraction script | Linux/macOS/Git Bash |
| `azure-infrastructure-extractor.ps1` | Main extraction script | Windows PowerShell |
| `dockerfile-generator.sh` | Auto-generate Dockerfiles | Linux/macOS/Git Bash |

### Documentation

| File | Contents |
|------|----------|
| `AZURE-CLI-COMMANDS-REFERENCE.md` | Complete Azure CLI command reference with examples |
| `AZURE-TO-DOCKER-COMPLETE-GUIDE.md` | Step-by-step migration guide |
| `AZURE-EXTRACTION-SUMMARY.md` | This file - quick reference |

## Quick Start Commands

### 1. Extract Everything
```bash
# Bash (Linux/macOS/Git Bash)
./azure-infrastructure-extractor.sh my-resource-group

# PowerShell (Windows)
.\azure-infrastructure-extractor.ps1 -ResourceGroupName my-resource-group
```

### 2. Navigate to Output
```bash
cd azure-export/my-resource-group_<timestamp>
```

### 3. Generate Docker Compose
```bash
./scripts/generate-docker-compose.sh
```

### 4. Generate Dockerfiles
```bash
# For each web app
for webapp in webapps/*; do
    ../dockerfile-generator.sh "$webapp" "$webapp/docker"
done
```

### 5. Start Local Environment
```bash
docker compose -f docker-compose-generated.yml up -d
```

## What Gets Extracted

### For Each Resource Type

#### Web Apps (App Services)
**Location**: `webapps/<app-name>/`

**Files Extracted**:
- `config.json` - Complete configuration
- `runtime.json` - Runtime stack (Node, Python, .NET, etc.)
- `appsettings.json` - All app settings
- `.env` - Ready-to-use environment variables
- `connection-strings.json` - All connection strings
- `startup.json` - Startup commands and health settings
- `container-settings.json` - If already containerized
- `identity.json` - Managed identity details
- `vnet.json` - Network integration

**Key Information**:
- Runtime version (Node 18, Python 3.11, .NET 8.0, etc.)
- All environment variables
- Connection strings
- Startup commands
- Port configurations
- Scaling settings

#### SQL Databases
**Location**: `databases/sql-<server-name>/<db-name>/`

**Files Extracted**:
- `server-config.json` - SQL Server configuration
- `config.json` - Database configuration
- `tier.json` - SKU and performance tier
- `connection-string.txt` - Azure connection string
- `docker-connection-string.txt` - Local connection string
- `export-data.sh` - Database export script
- `firewall-rules.json` - Server firewall rules

**Key Information**:
- Server FQDN
- Database name and collation
- Performance tier (Basic, Standard, Premium)
- Max size
- Connection details

#### PostgreSQL/MySQL Databases
**Location**: `databases/postgres-<server-name>/` or `databases/mysql-<server-name>/`

**Files Extracted**:
- `server-config.json` - Server configuration
- `server-parameters.json` - All server parameters
- `firewall-rules.json` - Firewall rules
- `connection-info.txt` - Connection details
- `export-data.sh` - Export script

**Key Information**:
- Server FQDN
- PostgreSQL/MySQL version
- SSL requirements
- Server parameters

#### Storage Accounts
**Location**: `storage/<account-name>/`

**Files Extracted**:
- `config.json` - Account configuration
- `keys.json` - Access keys ⚠️ SENSITIVE
- `connection-string.json` - Connection string ⚠️ SENSITIVE
- `containers.json` - All blob containers
- `queues.json` - All queues
- `tables.json` - All tables
- `shares.json` - All file shares
- `docker-config.txt` - Azurite configuration

**Key Information**:
- Account name and keys
- Storage tier (Standard, Premium)
- Replication type (LRS, GRS, etc.)
- Container names
- Queue names

#### Redis Cache
**Location**: `redis/<cache-name>/`

**Files Extracted**:
- `config.json` - Cache configuration
- `keys.json` - Access keys ⚠️ SENSITIVE
- `settings.json` - Redis configuration settings
- `connection-info.txt` - Connection details

**Key Information**:
- Redis version
- SKU (Basic, Standard, Premium)
- Hostname and ports
- SSL settings
- Redis configuration (maxmemory-policy, etc.)

#### Key Vault
**Location**: `keyvault/<vault-name>/`

**Files Extracted**:
- `config.json` - Vault configuration
- `access-policies.json` - Access policies
- `secret-names.json` - Secret names (NOT values)
- `key-names.json` - Key names
- `cert-names.json` - Certificate names
- `local-secrets-template.env` - Template for local secrets

**Key Information**:
- Vault URI
- Access policies
- Secret/key/certificate names
- Soft delete settings

#### Application Insights
**Location**: `appinsights/<app-name>/`

**Files Extracted**:
- `config.json` - Component configuration
- `instrumentation.json` - Instrumentation key and connection string
- `local-monitoring.txt` - Local alternatives

**Key Information**:
- Instrumentation key
- Connection string
- Application ID

## Azure CLI Command Quick Reference

### Web Apps
```bash
# Get all web apps
az webapp list --resource-group <rg> --output table

# Get web app config
az webapp show --name <name> --resource-group <rg>

# Get app settings
az webapp config appsettings list --name <name> --resource-group <rg>

# Get connection strings
az webapp config connection-string list --name <name> --resource-group <rg>

# Get runtime stack
az webapp show --name <name> --resource-group <rg> --query "siteConfig.linuxFxVersion"
```

### SQL Databases
```bash
# List servers
az sql server list --resource-group <rg> --output table

# List databases
az sql db list --server <server> --resource-group <rg> --output table

# Get database details
az sql db show --name <db> --server <server> --resource-group <rg>

# Export database
az sql db export \
    --name <db> \
    --server <server> \
    --resource-group <rg> \
    --admin-user <user> \
    --admin-password <pass> \
    --storage-key-type StorageAccessKey \
    --storage-key <key> \
    --storage-uri <uri>
```

### Storage
```bash
# List storage accounts
az storage account list --resource-group <rg> --output table

# Get connection string
az storage account show-connection-string --name <account> --resource-group <rg>

# List containers
az storage container list --account-name <account> --auth-mode login
```

### Redis
```bash
# List caches
az redis list --resource-group <rg> --output table

# Get cache details
az redis show --name <cache> --resource-group <rg>

# Get access keys
az redis list-keys --name <cache> --resource-group <rg>
```

### Key Vault
```bash
# List vaults
az keyvault list --resource-group <rg> --output table

# List secrets (names only)
az keyvault secret list --vault-name <vault> --query "[].name" -o table

# Get secret value
az keyvault secret show --vault-name <vault> --name <secret> --query value -o tsv
```

## Docker Image Mappings

### Databases
```yaml
# SQL Server
sqlserver:
  image: mcr.microsoft.com/mssql/server:2025-latest
  ports: ["1433:1433"]

# PostgreSQL
postgres:
  image: postgres:16.6-alpine
  ports: ["5432:5432"]

# MySQL
mysql:
  image: mysql:9.2
  ports: ["3306:3306"]

# MongoDB (for Cosmos DB MongoDB API)
mongodb:
  image: mongo:6
  ports: ["27017:27017"]
```

### Caching & Storage
```yaml
# Redis
redis:
  image: redis:7.4-alpine
  ports: ["6379:6379"]

# Azurite (Azure Storage)
azurite:
  image: mcr.microsoft.com/azure-storage/azurite
  ports: ["10000:10000", "10001:10001", "10002:10002"]
```

### Application Runtimes
```yaml
# Node.js
node-app:
  image: node:18-alpine

# Python
python-app:
  image: python:3.11-slim

# .NET
dotnet-app:
  image: mcr.microsoft.com/dotnet/aspnet:8.0

# PHP
php-app:
  image: php:8.2-apache

# Java
java-app:
  image: openjdk:17-jdk-slim
```

## Connection String Transformations

### SQL Server
**Azure**:
```
Server=tcp:myserver.database.windows.net,1433;Initial Catalog=mydb;User ID=admin;Password=***;Encrypt=True;TrustServerCertificate=False;
```

**Docker**:
```
Server=sqlserver;Database=mydb;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;
```

### PostgreSQL
**Azure**:
```
postgresql://admin@myserver:password@myserver.postgres.database.azure.com:5432/mydb?sslmode=require
```

**Docker**:
```
postgresql://postgres:localpassword@postgres:5432/mydb
```

### Redis
**Azure**:
```
mycache.redis.cache.windows.net:6380,password=***,ssl=True,abortConnect=False
```

**Docker**:
```
redis://:localpassword@redis:6379
```

### Storage (Azurite)
**Azure**:
```
DefaultEndpointsProtocol=https;AccountName=myaccount;AccountKey=***;EndpointSuffix=core.windows.net
```

**Docker**:
```
DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://azurite:10000/devstoreaccount1;
```

## Common Workflows

### Workflow 1: Complete Migration
```bash
# 1. Extract infrastructure
./azure-infrastructure-extractor.sh my-rg

# 2. Navigate to output
cd azure-export/my-rg_*/

# 3. Export databases
for server in databases/sql-*/; do
    for db in $server/*/; do
        cd "$db"
        # Edit export-data.sh with credentials
        ./export-data.sh
        cd -
    done
done

# 4. Extract secrets
./scripts/extract-keyvault-secrets.sh

# 5. Generate docker-compose
./scripts/generate-docker-compose.sh

# 6. Generate Dockerfiles
for webapp in webapps/*; do
    ../dockerfile-generator.sh "$webapp" "$webapp/docker"
done

# 7. Customize and start
docker compose -f docker-compose-generated.yml up -d
```

### Workflow 2: Single Web App
```bash
# 1. Extract
./azure-infrastructure-extractor.sh my-rg

# 2. Find your app
cd azure-export/my-rg_*/webapps/my-app

# 3. Generate Dockerfile
../../dockerfile-generator.sh . ./docker

# 4. Copy app code
cp -r /path/to/app/code ./docker/

# 5. Update .env
cp .env ./docker/.env
# Edit connection strings for local

# 6. Build and run
cd docker
./build.sh
./run.sh
```

### Workflow 3: Database Only
```bash
# 1. Extract
./azure-infrastructure-extractor.sh my-rg

# 2. Export database
cd azure-export/my-rg_*/databases/sql-myserver/mydb
# Edit export-data.sh
./export-data.sh

# 3. Start SQL Server container
docker run -d \
    --name local-sqlserver \
    -e 'ACCEPT_EULA=Y' \
    -e 'SA_PASSWORD=YourStrong@Passw0rd' \
    -p 1433:1433 \
    mcr.microsoft.com/mssql/server:2025-latest

# 4. Import
sqlpackage /Action:Import \
    /SourceFile:mydb.bacpac \
    /TargetServerName:localhost \
    /TargetDatabaseName:mydb \
    /TargetUser:sa \
    /TargetPassword:YourStrong@Passw0rd \
    /TargetTrustServerCertificate:True
```

## Security Checklist

### Before You Start
- [ ] Ensure you have appropriate Azure permissions (Reader minimum)
- [ ] Use dedicated service principal for automation
- [ ] Enable audit logging for extraction activities

### During Extraction
- [ ] Extract to encrypted storage
- [ ] Use secure network connection
- [ ] Log extraction activities

### After Extraction
- [ ] Immediately add `.env` and sensitive files to `.gitignore`
- [ ] Set restrictive permissions: `chmod 600 .env`
- [ ] Store extracted data securely
- [ ] Delete extracted keys/secrets when no longer needed
- [ ] Never commit these files:
  - `*.env` (except `.env.example`)
  - `**/keys.json`
  - `**/connection-string.json`
  - `**/secrets*.json`

### .gitignore Template
```
# Sensitive files
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
!schema.sql

# Docker
.dockerignore

# Logs
*.log
```

## Troubleshooting Quick Reference

| Issue | Solution |
|-------|----------|
| **"az: command not found"** | Install Azure CLI: `curl -sL https://aka.ms/InstallAzureCLI \| sudo bash` |
| **"Not logged in to Azure"** | Run `az login` |
| **"Resource group not found"** | Verify name and subscription: `az group exists --name <rg>` |
| **"Permission denied"** | Check RBAC roles: `az role assignment list --assignee $(az account show --query user.name -o tsv)` |
| **SQL connection refused** | Wait for health check, verify password complexity |
| **Cannot resolve service names** | Ensure all services on same Docker network |
| **Environment variables not loading** | Check `env_file` path relative to docker-compose.yml |
| **Azurite connection errors** | Use well-known Azurite connection string |

## Helper Scripts Output

### After Running azure-infrastructure-extractor.sh

**Directory Structure**:
```
azure-export/
└── my-rg_20251025_143022/
    ├── README.md                      # Generated documentation
    ├── SERVICE-MAPPING.md             # Azure → Docker mappings
    ├── docker-compose.yml             # Template
    ├── all-resources.json             # All resources
    ├── resource-summary.txt           # Human-readable summary
    ├── webapps/                       # Web App configs
    ├── databases/                     # Database configs
    ├── storage/                       # Storage configs
    ├── redis/                         # Redis configs
    ├── keyvault/                      # Key Vault configs
    ├── appinsights/                   # App Insights configs
    └── scripts/
        ├── extract-keyvault-secrets.sh
        └── generate-docker-compose.sh
```

### After Running generate-docker-compose.sh

**Generated File**: `docker-compose-generated.yml`
- Auto-detects services from extracted data
- Includes health checks
- Configures networks and volumes
- Ready to customize and use

### After Running dockerfile-generator.sh

**Generated Files**:
- `Dockerfile` - Production-ready, multi-stage
- `.dockerignore` - Optimized for runtime
- `docker-compose-service.yml` - Service definition
- `build.sh` - Build script
- `run.sh` - Run script

## Next Steps After Extraction

1. **Review Extracted Data**
   - Check `resource-summary.txt`
   - Verify all expected resources are present

2. **Export Database Data**
   - Run export scripts in `databases/*/
   - Import to local containers

3. **Set Up Secrets**
   - Run `./scripts/extract-keyvault-secrets.sh`
   - Review and secure `.env` files

4. **Generate Docker Artifacts**
   - Run `./scripts/generate-docker-compose.sh`
   - Generate Dockerfiles for each app

5. **Customize Configuration**
   - Update connection strings for local
   - Adjust port mappings
   - Configure volumes

6. **Build and Test**
   - Build Docker images
   - Start docker-compose stack
   - Verify connectivity
   - Test application

7. **Document Changes**
   - Note any customizations
   - Update README with specifics
   - Share with team

## Support & Resources

### Documentation Files
- **AZURE-CLI-COMMANDS-REFERENCE.md** - Complete command reference
- **AZURE-TO-DOCKER-COMPLETE-GUIDE.md** - Detailed migration guide
- **SERVICE-MAPPING.md** - Auto-generated in export directory

### Official Resources
- [Azure CLI Docs](https://docs.microsoft.com/cli/azure/)
- [Docker Docs](https://docs.docker.com/)
- [Azurite Docs](https://github.com/Azure/Azurite)

### Tools
- [Azure Data Studio](https://docs.microsoft.com/sql/azure-data-studio/)
- [SqlPackage](https://docs.microsoft.com/sql/tools/sqlpackage/)
- [Azure Storage Explorer](https://azure.microsoft.com/features/storage-explorer/)

---

## Summary

You now have everything needed to:
✅ Extract complete Azure infrastructure configurations
✅ Export database schemas and data
✅ Generate production-ready Dockerfiles
✅ Create docker-compose environments
✅ Migrate to local containerized development

**Start with**: `./azure-infrastructure-extractor.sh <your-resource-group>`

**Need help?** Refer to `AZURE-TO-DOCKER-COMPLETE-GUIDE.md`

---

**Last Updated**: 2025-10-25
