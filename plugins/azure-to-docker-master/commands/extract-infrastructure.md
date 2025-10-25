---
description: Extract Azure infrastructure and generate Docker Compose stack for local development
---

# Extract Azure Infrastructure Command

## Purpose
Programmatically extract all details from an Azure resource group and generate a complete Docker Compose stack for local development.

## Process

1. **Validate Prerequisites**
   - Check Azure CLI is installed (`az --version`)
   - Verify user is logged in (`az account show`)
   - Confirm resource group exists

2. **Run Extraction Script**
   - Use the `azure-infrastructure-extractor.sh` script (Linux/macOS/Git Bash)
   - OR use `azure-infrastructure-extractor.ps1` (Windows PowerShell)
   - Script location: `${CLAUDE_PLUGIN_ROOT}/scripts/`

3. **What Gets Extracted**
   - Web Apps: runtime, app settings, connection strings, environment variables
   - SQL Databases: connection details, export scripts
   - PostgreSQL/MySQL: server configurations, parameters
   - Storage Accounts: containers, queues, tables, access keys
   - Redis Cache: configuration, connection strings
   - Key Vault: secret names and values
   - Application Insights: instrumentation keys
   - Cosmos DB: databases, connection strings

4. **Generated Output**
   - Organized directory structure in `azure-export/RESOURCE_GROUP_*/`
   - JSON configuration files for each resource
   - `.env` files with connection strings mapped for Docker
   - Export scripts for databases
   - Production-ready Dockerfiles
   - Complete docker-compose.yml

5. **Next Steps**
   - Review the generated `docker-compose.yml`
   - Export databases using provided scripts
   - Run `docker compose up -d` to start local stack
   - Update connection strings in `.env` if needed

## Usage Example

```bash
# Linux/macOS/Git Bash
cd ${CLAUDE_PLUGIN_ROOT}/scripts
./azure-infrastructure-extractor.sh MyResourceGroup

# Windows PowerShell
cd $env:CLAUDE_PLUGIN_ROOT\scripts
.\azure-infrastructure-extractor.ps1 MyResourceGroup

# Navigate to output
cd azure-export/MyResourceGroup_*/

# Review and start
docker compose up -d
```

## Security Notes

- Secrets are extracted from Key Vault but should be stored in `.env` files (add to .gitignore)
- Connection strings are transformed from Azure format to Docker format
- Database passwords are included in export scripts - keep secure
- Review all extracted configurations before committing to version control

## Troubleshooting

If extraction fails:
- Verify Azure CLI authentication: `az account show`
- Check resource group exists: `az group show --name RESOURCE_GROUP`
- Ensure you have Reader permissions on the resource group
- Check script has execute permissions: `chmod +x azure-infrastructure-extractor.sh`
- Run with debug: `bash -x azure-infrastructure-extractor.sh RESOURCE_GROUP`
