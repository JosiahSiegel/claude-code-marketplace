#!/usr/bin/env bash
#
# Azure Infrastructure Extractor for Docker Compose Migration
#
# This script extracts all configuration details from Azure resources
# to generate a docker-compose.yml for local development.
#
# Usage: ./azure-infrastructure-extractor.sh <resource-group-name> [output-directory]
#

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
RESOURCE_GROUP="${1:-}"
OUTPUT_DIR="${2:-./azure-export}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
EXPORT_DIR="${OUTPUT_DIR}/${RESOURCE_GROUP}_${TIMESTAMP}"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Validate prerequisites
validate_prerequisites() {
    log_info "Validating prerequisites..."

    # Check Azure CLI
    if ! command -v az &> /dev/null; then
        log_error "Azure CLI is not installed. Install from: https://aka.ms/InstallAzureCLI"
        exit 1
    fi

    # Check authentication
    if ! az account show &> /dev/null; then
        log_error "Not logged in to Azure. Run: az login"
        exit 1
    fi

    # Check resource group
    if [[ -z "$RESOURCE_GROUP" ]]; then
        log_error "Usage: $0 <resource-group-name> [output-directory]"
        exit 1
    fi

    if ! az group exists --name "$RESOURCE_GROUP" | grep -q "true"; then
        log_error "Resource group '$RESOURCE_GROUP' does not exist"
        exit 1
    fi

    log_success "Prerequisites validated"
}

# Create directory structure
setup_directories() {
    log_info "Setting up directory structure..."

    mkdir -p "$EXPORT_DIR"/{webapps,databases,storage,redis,keyvault,appinsights,misc}
    mkdir -p "$EXPORT_DIR"/scripts/{init,seed}
    mkdir -p "$EXPORT_DIR"/docker/{dockerfiles,configs}

    log_success "Directory structure created at: $EXPORT_DIR"
}

# Extract all resources in resource group
extract_all_resources() {
    log_info "Extracting all resources from '$RESOURCE_GROUP'..."

    az resource list \
        --resource-group "$RESOURCE_GROUP" \
        --output json > "$EXPORT_DIR/all-resources.json"

    # Create summary
    az resource list \
        --resource-group "$RESOURCE_GROUP" \
        --query "[].{Name:name, Type:type, Location:location}" \
        --output table > "$EXPORT_DIR/resource-summary.txt"

    log_success "Resource list exported"
}

# Extract App Service Plans
extract_app_service_plans() {
    log_info "Extracting App Service Plans..."

    local plans
    plans=$(az appservice plan list \
        --resource-group "$RESOURCE_GROUP" \
        --query "[].name" \
        --output tsv)

    if [[ -z "$plans" ]]; then
        log_warning "No App Service Plans found"
        return
    fi

    while IFS= read -r plan; do
        log_info "  Extracting plan: $plan"

        az appservice plan show \
            --name "$plan" \
            --resource-group "$RESOURCE_GROUP" \
            --output json > "$EXPORT_DIR/misc/appservice-plan-${plan}.json"

        # Extract key details
        az appservice plan show \
            --name "$plan" \
            --resource-group "$RESOURCE_GROUP" \
            --query "{name:name, sku:sku.name, tier:sku.tier, location:location, numberOfWorkers:sku.capacity, kind:kind}" \
            --output json > "$EXPORT_DIR/misc/appservice-plan-${plan}-summary.json"

    done <<< "$plans"

    log_success "App Service Plans extracted"
}

# Extract Web Apps
extract_web_apps() {
    log_info "Extracting Web Apps..."

    local webapps
    webapps=$(az webapp list \
        --resource-group "$RESOURCE_GROUP" \
        --query "[].name" \
        --output tsv)

    if [[ -z "$webapps" ]]; then
        log_warning "No Web Apps found"
        return
    fi

    while IFS= read -r webapp; do
        log_info "  Extracting webapp: $webapp"

        local webapp_dir="$EXPORT_DIR/webapps/$webapp"
        mkdir -p "$webapp_dir"

        # Full configuration
        az webapp show \
            --name "$webapp" \
            --resource-group "$RESOURCE_GROUP" \
            --output json > "$webapp_dir/config.json"

        # Runtime stack
        az webapp show \
            --name "$webapp" \
            --resource-group "$RESOURCE_GROUP" \
            --query "{runtime:siteConfig.linuxFxVersion, nodeVersion:siteConfig.nodeVersion, pythonVersion:siteConfig.pythonVersion, phpVersion:siteConfig.phpVersion, netFrameworkVersion:siteConfig.netFrameworkVersion, javaVersion:siteConfig.javaVersion}" \
            --output json > "$webapp_dir/runtime.json"

        # App settings
        az webapp config appsettings list \
            --name "$webapp" \
            --resource-group "$RESOURCE_GROUP" \
            --output json > "$webapp_dir/appsettings.json"

        # Convert to .env format
        az webapp config appsettings list \
            --name "$webapp" \
            --resource-group "$RESOURCE_GROUP" \
            --query "[].{name:name, value:value}" \
            --output json | jq -r '.[] | "\(.name)=\(.value)"' > "$webapp_dir/.env"

        # Connection strings
        az webapp config connection-string list \
            --name "$webapp" \
            --resource-group "$RESOURCE_GROUP" \
            --output json > "$webapp_dir/connection-strings.json"

        # Startup command
        az webapp config show \
            --name "$webapp" \
            --resource-group "$RESOURCE_GROUP" \
            --query "{appCommandLine:appCommandLine, alwaysOn:alwaysOn, http20Enabled:http20Enabled, minTlsVersion:minTlsVersion}" \
            --output json > "$webapp_dir/startup.json"

        # Deployment source
        az webapp deployment source show \
            --name "$webapp" \
            --resource-group "$RESOURCE_GROUP" \
            --output json > "$webapp_dir/deployment-source.json" 2>/dev/null || echo "{}" > "$webapp_dir/deployment-source.json"

        # Container settings (if containerized)
        az webapp config container show \
            --name "$webapp" \
            --resource-group "$RESOURCE_GROUP" \
            --output json > "$webapp_dir/container-settings.json" 2>/dev/null || echo "{}" > "$webapp_dir/container-settings.json"

        # Scaling configuration
        az webapp config show \
            --name "$webapp" \
            --resource-group "$RESOURCE_GROUP" \
            --query "{numberOfWorkers:numberOfWorkers, autoHealEnabled:autoHealEnabled}" \
            --output json > "$webapp_dir/scaling.json"

        # VNet integration
        az webapp vnet-integration list \
            --name "$webapp" \
            --resource-group "$RESOURCE_GROUP" \
            --output json > "$webapp_dir/vnet.json" 2>/dev/null || echo "[]" > "$webapp_dir/vnet.json"

        # Managed identity
        az webapp identity show \
            --name "$webapp" \
            --resource-group "$RESOURCE_GROUP" \
            --output json > "$webapp_dir/identity.json" 2>/dev/null || echo "{}" > "$webapp_dir/identity.json"

    done <<< "$webapps"

    log_success "Web Apps extracted"
}

# Extract SQL Databases
extract_sql_databases() {
    log_info "Extracting SQL Databases..."

    local servers
    servers=$(az sql server list \
        --resource-group "$RESOURCE_GROUP" \
        --query "[].name" \
        --output tsv)

    if [[ -z "$servers" ]]; then
        log_warning "No SQL Servers found"
        return
    fi

    while IFS= read -r server; do
        log_info "  Extracting SQL Server: $server"

        local server_dir="$EXPORT_DIR/databases/sql-$server"
        mkdir -p "$server_dir"

        # Server configuration
        az sql server show \
            --name "$server" \
            --resource-group "$RESOURCE_GROUP" \
            --output json > "$server_dir/server-config.json"

        # Firewall rules
        az sql server firewall-rule list \
            --server "$server" \
            --resource-group "$RESOURCE_GROUP" \
            --output json > "$server_dir/firewall-rules.json"

        # Databases
        local databases
        databases=$(az sql db list \
            --server "$server" \
            --resource-group "$RESOURCE_GROUP" \
            --query "[?name!='master'].name" \
            --output tsv)

        while IFS= read -r db; do
            [[ -z "$db" ]] && continue

            log_info "    Extracting database: $db"

            local db_dir="$server_dir/$db"
            mkdir -p "$db_dir"

            # Database configuration
            az sql db show \
                --name "$db" \
                --server "$server" \
                --resource-group "$RESOURCE_GROUP" \
                --output json > "$db_dir/config.json"

            # Service tier and performance
            az sql db show \
                --name "$db" \
                --server "$server" \
                --resource-group "$RESOURCE_GROUP" \
                --query "{sku:sku.name, tier:sku.tier, capacity:sku.capacity, maxSizeBytes:maxSizeBytes, collation:collation}" \
                --output json > "$db_dir/tier.json"

            # Connection string template
            local fqdn
            fqdn=$(az sql server show --name "$server" --resource-group "$RESOURCE_GROUP" --query fullyQualifiedDomainName -o tsv)
            cat > "$db_dir/connection-string.txt" <<EOF
Server=tcp:${fqdn},1433;Initial Catalog=${db};Persist Security Info=False;User ID=<username>;Password=<password>;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;
EOF

            # Docker equivalent connection string
            cat > "$db_dir/docker-connection-string.txt" <<EOF
Server=sqlserver;Database=${db};User Id=sa;Password=<YourStrong@Passw0rd>;TrustServerCertificate=True;
EOF

            # Export schema and data script
            cat > "$db_dir/export-data.sh" <<EOF
#!/bin/bash
# Export database schema and data from Azure SQL Database
# Requires sqlpackage CLI tool: https://aka.ms/sqlpackage

# Export as BACPAC (schema + data)
sqlpackage /Action:Export \\
    /SourceServerName:${fqdn} \\
    /SourceDatabaseName:${db} \\
    /SourceUser:<username> \\
    /SourcePassword:<password> \\
    /SourceEncryptConnection:True \\
    /TargetFile:${db}.bacpac

# Or export schema only as DACPAC
# sqlpackage /Action:Extract \\
#     /SourceServerName:${fqdn} \\
#     /SourceDatabaseName:${db} \\
#     /SourceUser:<username> \\
#     /SourcePassword:<password> \\
#     /SourceEncryptConnection:True \\
#     /TargetFile:${db}.dacpac

# Alternative: Using Azure CLI to export to storage
# az sql db export \\
#     --name ${db} \\
#     --server ${server} \\
#     --resource-group ${RESOURCE_GROUP} \\
#     --admin-user <username> \\
#     --admin-password <password> \\
#     --storage-key-type StorageAccessKey \\
#     --storage-key <storage-key> \\
#     --storage-uri https://<storage-account>.blob.core.windows.net/backups/${db}.bacpac
EOF
            chmod +x "$db_dir/export-data.sh"

        done <<< "$databases"

    done <<< "$servers"

    log_success "SQL Databases extracted"
}

# Extract PostgreSQL Databases
extract_postgresql_databases() {
    log_info "Extracting PostgreSQL Databases..."

    local servers
    servers=$(az postgres server list \
        --resource-group "$RESOURCE_GROUP" \
        --query "[].name" \
        --output tsv 2>/dev/null || echo "")

    if [[ -z "$servers" ]]; then
        log_warning "No PostgreSQL Servers found"
        return
    fi

    while IFS= read -r server; do
        log_info "  Extracting PostgreSQL Server: $server"

        local server_dir="$EXPORT_DIR/databases/postgres-$server"
        mkdir -p "$server_dir"

        # Server configuration
        az postgres server show \
            --name "$server" \
            --resource-group "$RESOURCE_GROUP" \
            --output json > "$server_dir/server-config.json"

        # Firewall rules
        az postgres server firewall-rule list \
            --server-name "$server" \
            --resource-group "$RESOURCE_GROUP" \
            --output json > "$server_dir/firewall-rules.json"

        # Server configuration parameters
        az postgres server configuration list \
            --server-name "$server" \
            --resource-group "$RESOURCE_GROUP" \
            --output json > "$server_dir/server-parameters.json"

        # Connection info
        local fqdn
        fqdn=$(az postgres server show --name "$server" --resource-group "$RESOURCE_GROUP" --query fullyQualifiedDomainName -o tsv)

        cat > "$server_dir/connection-info.txt" <<EOF
Host: ${fqdn}
Port: 5432
SSL Mode: require

Connection String:
postgresql://<username>@${server}:<password>@${fqdn}:5432/<database>?sslmode=require

Docker Connection String:
postgresql://<username>:<password>@postgres:5432/<database>
EOF

        # Export script
        cat > "$server_dir/export-data.sh" <<EOF
#!/bin/bash
# Export PostgreSQL database
# Requires pg_dump utility

export PGPASSWORD='<password>'

# Export all databases
pg_dump -h ${fqdn} \\
    -U <username>@${server} \\
    -d <database> \\
    -F c \\
    -f database-backup.dump

# Or export as SQL script
# pg_dump -h ${fqdn} \\
#     -U <username>@${server} \\
#     -d <database> \\
#     --no-owner --no-acl \\
#     -f database-schema.sql
EOF
        chmod +x "$server_dir/export-data.sh"

    done <<< "$servers"

    log_success "PostgreSQL Databases extracted"
}

# Extract MySQL Databases
extract_mysql_databases() {
    log_info "Extracting MySQL Databases..."

    local servers
    servers=$(az mysql server list \
        --resource-group "$RESOURCE_GROUP" \
        --query "[].name" \
        --output tsv 2>/dev/null || echo "")

    if [[ -z "$servers" ]]; then
        log_warning "No MySQL Servers found"
        return
    fi

    while IFS= read -r server; do
        log_info "  Extracting MySQL Server: $server"

        local server_dir="$EXPORT_DIR/databases/mysql-$server"
        mkdir -p "$server_dir"

        # Server configuration
        az mysql server show \
            --name "$server" \
            --resource-group "$RESOURCE_GROUP" \
            --output json > "$server_dir/server-config.json"

        # Firewall rules
        az mysql server firewall-rule list \
            --server-name "$server" \
            --resource-group "$RESOURCE_GROUP" \
            --output json > "$server_dir/firewall-rules.json"

        # Server configuration parameters
        az mysql server configuration list \
            --server-name "$server" \
            --resource-group "$RESOURCE_GROUP" \
            --output json > "$server_dir/server-parameters.json"

        # Connection info
        local fqdn
        fqdn=$(az mysql server show --name "$server" --resource-group "$RESOURCE_GROUP" --query fullyQualifiedDomainName -o tsv)

        cat > "$server_dir/connection-info.txt" <<EOF
Host: ${fqdn}
Port: 3306
SSL Mode: required

Connection String:
mysql://<username>@${server}:<password>@${fqdn}:3306/<database>?ssl-mode=REQUIRED

Docker Connection String:
mysql://<username>:<password>@mysql:3306/<database>
EOF

        # Export script
        cat > "$server_dir/export-data.sh" <<EOF
#!/bin/bash
# Export MySQL database
# Requires mysqldump utility

mysqldump -h ${fqdn} \\
    -u <username>@${server} \\
    -p<password> \\
    --ssl-mode=REQUIRED \\
    --databases <database> \\
    --single-transaction \\
    --routines \\
    --triggers \\
    --events \\
    > database-backup.sql
EOF
        chmod +x "$server_dir/export-data.sh"

    done <<< "$servers"

    log_success "MySQL Databases extracted"
}

# Extract Cosmos DB
extract_cosmosdb() {
    log_info "Extracting Cosmos DB accounts..."

    local accounts
    accounts=$(az cosmosdb list \
        --resource-group "$RESOURCE_GROUP" \
        --query "[].name" \
        --output tsv 2>/dev/null || echo "")

    if [[ -z "$accounts" ]]; then
        log_warning "No Cosmos DB accounts found"
        return
    fi

    while IFS= read -r account; do
        log_info "  Extracting Cosmos DB: $account"

        local cosmos_dir="$EXPORT_DIR/databases/cosmos-$account"
        mkdir -p "$cosmos_dir"

        # Account configuration
        az cosmosdb show \
            --name "$account" \
            --resource-group "$RESOURCE_GROUP" \
            --output json > "$cosmos_dir/account-config.json"

        # Connection strings
        az cosmosdb keys list \
            --name "$account" \
            --resource-group "$RESOURCE_GROUP" \
            --type connection-strings \
            --output json > "$cosmos_dir/connection-strings.json"

        # List databases
        az cosmosdb sql database list \
            --account-name "$account" \
            --resource-group "$RESOURCE_GROUP" \
            --output json > "$cosmos_dir/databases.json" 2>/dev/null || echo "[]" > "$cosmos_dir/databases.json"

        # Export script
        cat > "$cosmos_dir/export-data.sh" <<EOF
#!/bin/bash
# Export Cosmos DB data
# Use Azure Data Migration Tool or custom script

# For MongoDB API:
# mongodump --uri="<connection-string>" --out=./cosmos-dump

# For SQL API:
# Use Azure Data Factory, Azure Synapse, or custom export using SDKs

echo "Cosmos DB export requires Azure Data Migration Tool or custom scripting"
echo "Connection strings available in connection-strings.json"
EOF
        chmod +x "$cosmos_dir/export-data.sh"

    done <<< "$accounts"

    log_success "Cosmos DB accounts extracted"
}

# Extract Storage Accounts
extract_storage_accounts() {
    log_info "Extracting Storage Accounts..."

    local accounts
    accounts=$(az storage account list \
        --resource-group "$RESOURCE_GROUP" \
        --query "[].name" \
        --output tsv)

    if [[ -z "$accounts" ]]; then
        log_warning "No Storage Accounts found"
        return
    fi

    while IFS= read -r account; do
        log_info "  Extracting storage account: $account"

        local storage_dir="$EXPORT_DIR/storage/$account"
        mkdir -p "$storage_dir"

        # Account configuration
        az storage account show \
            --name "$account" \
            --resource-group "$RESOURCE_GROUP" \
            --output json > "$storage_dir/config.json"

        # Access keys
        az storage account keys list \
            --account-name "$account" \
            --resource-group "$RESOURCE_GROUP" \
            --output json > "$storage_dir/keys.json"

        # Connection string
        az storage account show-connection-string \
            --name "$account" \
            --resource-group "$RESOURCE_GROUP" \
            --output json > "$storage_dir/connection-string.json"

        local conn_string
        conn_string=$(az storage account show-connection-string --name "$account" --resource-group "$RESOURCE_GROUP" --query connectionString -o tsv)

        # Blob containers
        az storage container list \
            --account-name "$account" \
            --auth-mode login \
            --output json > "$storage_dir/containers.json" 2>/dev/null || echo "[]" > "$storage_dir/containers.json"

        # Queues
        az storage queue list \
            --account-name "$account" \
            --auth-mode login \
            --output json > "$storage_dir/queues.json" 2>/dev/null || echo "[]" > "$storage_dir/queues.json"

        # Tables
        az storage table list \
            --account-name "$account" \
            --auth-mode login \
            --output json > "$storage_dir/tables.json" 2>/dev/null || echo "[]" > "$storage_dir/tables.json"

        # File shares
        az storage share list \
            --account-name "$account" \
            --auth-mode login \
            --output json > "$storage_dir/shares.json" 2>/dev/null || echo "[]" > "$storage_dir/shares.json"

        # Docker equivalent (Azurite)
        cat > "$storage_dir/docker-config.txt" <<EOF
Use Azurite for local Azure Storage emulation:
https://hub.docker.com/_/microsoft-azure-storage-azurite

Connection String for Azurite:
DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://127.0.0.1:10000/devstoreaccount1;QueueEndpoint=http://127.0.0.1:10001/devstoreaccount1;TableEndpoint=http://127.0.0.1:10002/devstoreaccount1;

Docker Compose:
  azurite:
    image: mcr.microsoft.com/azure-storage/azurite
    ports:
      - "10000:10000"  # Blob
      - "10001:10001"  # Queue
      - "10002:10002"  # Table
EOF

    done <<< "$accounts"

    log_success "Storage Accounts extracted"
}

# Extract Redis Cache
extract_redis_cache() {
    log_info "Extracting Redis Cache instances..."

    local caches
    caches=$(az redis list \
        --resource-group "$RESOURCE_GROUP" \
        --query "[].name" \
        --output tsv 2>/dev/null || echo "")

    if [[ -z "$caches" ]]; then
        log_warning "No Redis Cache instances found"
        return
    fi

    while IFS= read -r cache; do
        log_info "  Extracting Redis Cache: $cache"

        local redis_dir="$EXPORT_DIR/redis/$cache"
        mkdir -p "$redis_dir"

        # Cache configuration
        az redis show \
            --name "$cache" \
            --resource-group "$RESOURCE_GROUP" \
            --output json > "$redis_dir/config.json"

        # Access keys
        az redis list-keys \
            --name "$cache" \
            --resource-group "$RESOURCE_GROUP" \
            --output json > "$redis_dir/keys.json"

        # Configuration settings
        az redis show \
            --name "$cache" \
            --resource-group "$RESOURCE_GROUP" \
            --query "{sku:sku, redisVersion:redisVersion, enableNonSslPort:enableNonSslPort, minimumTlsVersion:minimumTlsVersion, redisConfiguration:redisConfiguration}" \
            --output json > "$redis_dir/settings.json"

        # Connection info
        local hostname
        hostname=$(az redis show --name "$cache" --resource-group "$RESOURCE_GROUP" --query hostName -o tsv)
        local port
        port=$(az redis show --name "$cache" --resource-group "$RESOURCE_GROUP" --query port -o tsv)
        local ssl_port
        ssl_port=$(az redis show --name "$cache" --resource-group "$RESOURCE_GROUP" --query sslPort -o tsv)

        cat > "$redis_dir/connection-info.txt" <<EOF
Hostname: ${hostname}
Port: ${port}
SSL Port: ${ssl_port}

Connection String:
${hostname}:${ssl_port},password=<primary-key>,ssl=True,abortConnect=False

Docker Connection String:
redis:6379,password=<local-password>

Docker Compose:
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    command: redis-server --requirepass <local-password>
EOF

    done <<< "$caches"

    log_success "Redis Cache instances extracted"
}

# Extract Key Vault
extract_key_vaults() {
    log_info "Extracting Key Vaults..."

    local vaults
    vaults=$(az keyvault list \
        --resource-group "$RESOURCE_GROUP" \
        --query "[].name" \
        --output tsv 2>/dev/null || echo "")

    if [[ -z "$vaults" ]]; then
        log_warning "No Key Vaults found"
        return
    fi

    while IFS= read -r vault; do
        log_info "  Extracting Key Vault: $vault"

        local vault_dir="$EXPORT_DIR/keyvault/$vault"
        mkdir -p "$vault_dir"

        # Vault configuration
        az keyvault show \
            --name "$vault" \
            --output json > "$vault_dir/config.json"

        # Access policies
        az keyvault show \
            --name "$vault" \
            --query "properties.accessPolicies" \
            --output json > "$vault_dir/access-policies.json"

        # List secret names (not values for security)
        az keyvault secret list \
            --vault-name "$vault" \
            --query "[].{name:name, enabled:attributes.enabled, expires:attributes.expires}" \
            --output json > "$vault_dir/secret-names.json" 2>/dev/null || echo "[]" > "$vault_dir/secret-names.json"

        # List key names
        az keyvault key list \
            --vault-name "$vault" \
            --query "[].{name:name, enabled:attributes.enabled, kty:key.kty}" \
            --output json > "$vault_dir/key-names.json" 2>/dev/null || echo "[]" > "$vault_dir/key-names.json"

        # List certificate names
        az keyvault certificate list \
            --vault-name "$vault" \
            --query "[].{name:name, enabled:attributes.enabled, expires:attributes.expires}" \
            --output json > "$vault_dir/cert-names.json" 2>/dev/null || echo "[]" > "$vault_dir/cert-names.json"

        # Create template for local secrets
        cat > "$vault_dir/local-secrets-template.env" <<EOF
# Template for local development secrets
# Replace with actual values from Azure Key Vault

# To export secrets from Key Vault:
# az keyvault secret show --vault-name $vault --name <secret-name> --query value -o tsv

EOF

        # Add each secret name to template
        local secrets
        secrets=$(az keyvault secret list --vault-name "$vault" --query "[].name" -o tsv 2>/dev/null || echo "")
        while IFS= read -r secret; do
            [[ -z "$secret" ]] && continue
            echo "${secret}=" >> "$vault_dir/local-secrets-template.env"
        done <<< "$secrets"

    done <<< "$vaults"

    log_success "Key Vaults extracted"
}

# Extract Application Insights
extract_app_insights() {
    log_info "Extracting Application Insights..."

    local insights
    insights=$(az monitor app-insights component show \
        --resource-group "$RESOURCE_GROUP" \
        --query "[].name" \
        --output tsv 2>/dev/null || echo "")

    if [[ -z "$insights" ]]; then
        log_warning "No Application Insights found"
        return
    fi

    while IFS= read -r insight; do
        log_info "  Extracting Application Insights: $insight"

        local insights_dir="$EXPORT_DIR/appinsights/$insight"
        mkdir -p "$insights_dir"

        # Component configuration
        az monitor app-insights component show \
            --app "$insight" \
            --resource-group "$RESOURCE_GROUP" \
            --output json > "$insights_dir/config.json"

        # Instrumentation key
        az monitor app-insights component show \
            --app "$insight" \
            --resource-group "$RESOURCE_GROUP" \
            --query "{instrumentationKey:instrumentationKey, connectionString:connectionString, appId:appId}" \
            --output json > "$insights_dir/instrumentation.json"

        cat > "$insights_dir/local-monitoring.txt" <<EOF
For local development, consider these alternatives:

1. Application Insights local emulator (if available)
2. Disable Application Insights in local environment
3. Use local logging/monitoring solutions:
   - ELK Stack (Elasticsearch, Logstash, Kibana)
   - Grafana + Prometheus
   - Seq for structured logging

Set APPLICATIONINSIGHTS_CONNECTION_STRING to empty or use local endpoint.
EOF

    done <<< "$insights"

    log_success "Application Insights extracted"
}

# Generate Docker Compose file
generate_docker_compose() {
    log_info "Generating docker-compose.yml template..."

    cat > "$EXPORT_DIR/docker-compose.yml" <<'EOF'
version: '3.8'

# Generated Docker Compose template for local development
# Based on Azure resource extraction
#
# IMPORTANT: This is a TEMPLATE. You must:
# 1. Review and customize for your specific needs
# 2. Add proper secrets/passwords (use .env file)
# 3. Configure volumes for data persistence
# 4. Adjust port mappings as needed
# 5. Add application services based on webapp configurations

services:
  # Example: SQL Server (if Azure SQL Database detected)
  # Uncomment and configure if you have SQL databases
  # sqlserver:
  #   image: mcr.microsoft.com/mssql/server:2022-latest
  #   environment:
  #     ACCEPT_EULA: "Y"
  #     SA_PASSWORD: "YourStrong@Passw0rd"
  #     MSSQL_PID: "Developer"
  #   ports:
  #     - "1433:1433"
  #   volumes:
  #     - sqldata:/var/opt/mssql
  #     - ./databases/sql-init:/docker-entrypoint-initdb.d
  #   networks:
  #     - app-network

  # Example: PostgreSQL (if Azure PostgreSQL detected)
  # postgres:
  #   image: postgres:15-alpine
  #   environment:
  #     POSTGRES_PASSWORD: localpassword
  #     POSTGRES_USER: postgres
  #     POSTGRES_DB: myapp
  #   ports:
  #     - "5432:5432"
  #   volumes:
  #     - pgdata:/var/lib/postgresql/data
  #     - ./databases/postgres-init:/docker-entrypoint-initdb.d
  #   networks:
  #     - app-network

  # Example: MySQL (if Azure MySQL detected)
  # mysql:
  #   image: mysql:8.0
  #   environment:
  #     MYSQL_ROOT_PASSWORD: rootpassword
  #     MYSQL_DATABASE: myapp
  #     MYSQL_USER: user
  #     MYSQL_PASSWORD: password
  #   ports:
  #     - "3306:3306"
  #   volumes:
  #     - mysqldata:/var/lib/mysql
  #     - ./databases/mysql-init:/docker-entrypoint-initdb.d
  #   networks:
  #     - app-network

  # Example: Redis (if Azure Redis Cache detected)
  # redis:
  #   image: redis:7-alpine
  #   command: redis-server --requirepass localpassword
  #   ports:
  #     - "6379:6379"
  #   volumes:
  #     - redisdata:/data
  #   networks:
  #     - app-network

  # Example: Azurite (Azure Storage emulator)
  # azurite:
  #   image: mcr.microsoft.com/azure-storage/azurite
  #   ports:
  #     - "10000:10000"  # Blob
  #     - "10001:10001"  # Queue
  #     - "10002:10002"  # Table
  #   volumes:
  #     - azuritedata:/data
  #   networks:
  #     - app-network

  # Example: MongoDB (if Cosmos DB with MongoDB API detected)
  # mongodb:
  #   image: mongo:6
  #   environment:
  #     MONGO_INITDB_ROOT_USERNAME: root
  #     MONGO_INITDB_ROOT_PASSWORD: password
  #   ports:
  #     - "27017:27017"
  #   volumes:
  #     - mongodata:/data/db
  #   networks:
  #     - app-network

  # Example: Web Application
  # webapp:
  #   build:
  #     context: ./app
  #     dockerfile: Dockerfile
  #   ports:
  #     - "8080:8080"
  #   environment:
  #     # Load from .env file or specify here
  #     - DATABASE_URL=postgresql://postgres:localpassword@postgres:5432/myapp
  #     - REDIS_URL=redis://:localpassword@redis:6379
  #     - STORAGE_CONNECTION_STRING=DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;...
  #   env_file:
  #     - ./webapps/your-webapp/.env
  #   depends_on:
  #     - postgres
  #     - redis
  #     - azurite
  #   networks:
  #     - app-network
  #   volumes:
  #     - ./app:/app

volumes:
  sqldata:
  pgdata:
  mysqldata:
  redisdata:
  azuritedata:
  mongodata:

networks:
  app-network:
    driver: bridge
EOF

    log_success "docker-compose.yml template generated"
}

# Generate service mapping guide
generate_service_mapping() {
    log_info "Generating service mapping guide..."

    cat > "$EXPORT_DIR/SERVICE-MAPPING.md" <<'EOF'
# Azure to Docker Service Mapping Guide

This guide helps you map Azure services to their Docker container equivalents for local development.

## Database Services

### Azure SQL Database → SQL Server Container
- **Docker Image**: `mcr.microsoft.com/mssql/server:2022-latest`
- **Connection String Change**:
  - Azure: `Server=tcp:yourserver.database.windows.net,1433;...`
  - Docker: `Server=sqlserver,1433;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;`
- **Data Migration**: Use BACPAC export/import or schema scripts
- **Configuration**: See `databases/sql-*/` directories

### Azure PostgreSQL → PostgreSQL Container
- **Docker Image**: `postgres:15-alpine`
- **Connection String Change**:
  - Azure: `Host=yourserver.postgres.database.azure.com;Port=5432;SSL Mode=Require;...`
  - Docker: `Host=postgres;Port=5432;Username=postgres;Password=localpassword;`
- **Data Migration**: Use pg_dump/pg_restore
- **Configuration**: See `databases/postgres-*/` directories

### Azure MySQL → MySQL Container
- **Docker Image**: `mysql:8.0`
- **Connection String Change**:
  - Azure: `Server=yourserver.mysql.database.azure.com;Port=3306;...`
  - Docker: `Server=mysql;Port=3306;Uid=root;Pwd=rootpassword;`
- **Data Migration**: Use mysqldump/mysql import
- **Configuration**: See `databases/mysql-*/` directories

### Cosmos DB (SQL API) → No Direct Equivalent
- **Options**:
  1. Use Cosmos DB Emulator (Windows only): `mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator`
  2. Use Azure Cosmos DB for local development (cloud-based)
  3. Mock with MongoDB for development
- **Configuration**: See `databases/cosmos-*/` directories

### Cosmos DB (MongoDB API) → MongoDB Container
- **Docker Image**: `mongo:6`
- **Connection String Change**:
  - Azure: `mongodb://yourcosmosdb.mongo.cosmos.azure.com:10255/...`
  - Docker: `mongodb://root:password@mongodb:27017/`
- **Configuration**: See `databases/cosmos-*/` directories

## Cache Services

### Azure Redis Cache → Redis Container
- **Docker Image**: `redis:7-alpine`
- **Connection String Change**:
  - Azure: `yourcache.redis.cache.windows.net:6380,password=...,ssl=True`
  - Docker: `redis:6379,password=localpassword`
- **Configuration**: See `redis/*/` directories
- **Command**: `redis-server --requirepass localpassword`

## Storage Services

### Azure Blob Storage → Azurite
- **Docker Image**: `mcr.microsoft.com/azure-storage/azurite`
- **Connection String**:
  - Azure: `DefaultEndpointsProtocol=https;AccountName=youraccount;AccountKey=...;EndpointSuffix=core.windows.net`
  - Azurite: `DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://127.0.0.1:10000/devstoreaccount1;`
- **Ports**: 10000 (Blob), 10001 (Queue), 10002 (Table)
- **Configuration**: See `storage/*/` directories

### Azure Files → Volume Mounts
- Use Docker volumes or bind mounts
- No special container needed

## Application Services

### Azure App Service (Web Apps) → Custom Container
- **Base Image**: Depends on runtime stack (see `webapps/*/runtime.json`)
  - Node.js: `node:18-alpine`
  - Python: `python:3.11-slim`
  - .NET: `mcr.microsoft.com/dotnet/aspnet:8.0`
  - Java: `openjdk:17-jdk-slim`
  - PHP: `php:8.2-apache`
- **Environment Variables**: See `webapps/*/.env`
- **Startup Commands**: See `webapps/*/startup.json`
- **Build**: Create Dockerfile based on runtime and startup configuration

### Azure Functions → Custom Container
- **Base Image**:
  - `mcr.microsoft.com/azure-functions/node:4-node18` (Node.js)
  - `mcr.microsoft.com/azure-functions/python:4-python3.11` (Python)
  - `mcr.microsoft.com/azure-functions/dotnet:4` (.NET)
- **Local Development**: Use Azure Functions Core Tools or Docker
- **Configuration**: Mount local.settings.json

## Monitoring & Logging

### Application Insights → Alternative Solutions
- **Options**:
  1. Disable for local development
  2. Use ELK Stack (Elasticsearch, Logstash, Kibana)
  3. Use Grafana + Prometheus
  4. Use Seq for structured logging
- **Configuration**: See `appinsights/*/` directories
- **Environment Variable**: Set `APPLICATIONINSIGHTS_CONNECTION_STRING` to empty

## Security Services

### Azure Key Vault → Environment Variables
- **Local Approach**: Use `.env` files (DO NOT COMMIT)
- **Template**: See `keyvault/*/local-secrets-template.env`
- **Best Practice**:
  1. Copy template to `.env`
  2. Fill in actual values from Azure Key Vault
  3. Add `.env` to `.gitignore`
  4. Use `docker-compose` env_file feature

### Managed Identities → Service Principal or API Keys
- **Azure**: Managed Identity provides automatic authentication
- **Local**: Use service principal credentials or API keys in environment variables
- **Configuration**: See `webapps/*/identity.json`

## Networking

### Virtual Network → Docker Network
- **Azure**: VNet with subnets, NSGs, private endpoints
- **Docker**: Custom bridge network
- **Configuration**:
  ```yaml
  networks:
    app-network:
      driver: bridge
  ```

### Application Gateway / Load Balancer → Nginx/Traefik
- **Docker Image**: `nginx:alpine` or `traefik:latest`
- **Use Case**: Reverse proxy, SSL termination, load balancing

## Migration Checklist

- [ ] Export database schemas and data
- [ ] Extract all environment variables and app settings
- [ ] Download or rebuild application code
- [ ] Create Dockerfiles for each application
- [ ] Map connection strings to local services
- [ ] Set up local secrets management (.env files)
- [ ] Configure volumes for data persistence
- [ ] Test all service connections
- [ ] Verify application functionality
- [ ] Document any differences from Azure environment

## Common Connection String Patterns

### Replace Azure-specific values:
- `*.database.windows.net` → `sqlserver`
- `*.postgres.database.azure.com` → `postgres`
- `*.mysql.database.azure.com` → `mysql`
- `*.redis.cache.windows.net` → `redis`
- `*.blob.core.windows.net` → `azurite` (or `localhost:10000`)
- `*.mongo.cosmos.azure.com` → `mongodb`

### Remove Azure-specific parameters:
- SSL/TLS requirements (use `TrustServerCertificate=True` for SQL Server)
- Azure-specific authentication (use username/password)
- Firewall rules (not needed locally)

## Next Steps

1. Review extracted configurations in respective directories
2. Choose appropriate Docker images for your stack
3. Create/update docker-compose.yml from the template
4. Create Dockerfiles for your applications
5. Set up .env files with local credentials
6. Export and import database data
7. Test the local environment
8. Document any custom configuration needed
EOF

    log_success "Service mapping guide generated"
}

# Generate README
generate_readme() {
    log_info "Generating README..."

    cat > "$EXPORT_DIR/README.md" <<EOF
# Azure Infrastructure Export

This directory contains extracted configuration from Azure Resource Group: **$RESOURCE_GROUP**

Export Date: $(date)
Export Tool: azure-infrastructure-extractor.sh

## Directory Structure

\`\`\`
.
├── README.md                          # This file
├── SERVICE-MAPPING.md                 # Azure → Docker mapping guide
├── docker-compose.yml                 # Docker Compose template
├── all-resources.json                 # Complete resource list
├── resource-summary.txt               # Human-readable resource summary
├── webapps/                          # Web App configurations
│   └── [webapp-name]/
│       ├── config.json               # Full webapp configuration
│       ├── runtime.json              # Runtime stack details
│       ├── appsettings.json          # Application settings
│       ├── .env                      # Environment variables (ready to use)
│       ├── connection-strings.json   # Connection strings
│       ├── startup.json              # Startup commands
│       ├── deployment-source.json    # Deployment configuration
│       ├── container-settings.json   # Container settings (if applicable)
│       ├── scaling.json              # Scaling configuration
│       ├── vnet.json                 # Virtual network integration
│       └── identity.json             # Managed identity details
├── databases/                        # Database configurations
│   ├── sql-[server-name]/           # Azure SQL Database
│   │   ├── server-config.json
│   │   ├── firewall-rules.json
│   │   └── [database-name]/
│   │       ├── config.json
│   │       ├── tier.json
│   │       ├── connection-string.txt
│   │       ├── docker-connection-string.txt
│   │       └── export-data.sh       # Database export script
│   ├── postgres-[server-name]/      # Azure PostgreSQL
│   ├── mysql-[server-name]/         # Azure MySQL
│   └── cosmos-[account-name]/       # Cosmos DB
├── storage/                          # Storage Account configurations
│   └── [account-name]/
│       ├── config.json
│       ├── keys.json                 # Access keys
│       ├── connection-string.json
│       ├── containers.json           # Blob containers
│       ├── queues.json               # Storage queues
│       ├── tables.json               # Storage tables
│       ├── shares.json               # File shares
│       └── docker-config.txt         # Azurite configuration
├── redis/                            # Redis Cache configurations
│   └── [cache-name]/
│       ├── config.json
│       ├── keys.json
│       ├── settings.json
│       └── connection-info.txt       # Connection details
├── keyvault/                         # Key Vault configurations
│   └── [vault-name]/
│       ├── config.json
│       ├── access-policies.json
│       ├── secret-names.json         # Secret names only
│       ├── key-names.json
│       ├── cert-names.json
│       └── local-secrets-template.env # Template for local secrets
├── appinsights/                      # Application Insights
│   └── [insight-name]/
│       ├── config.json
│       ├── instrumentation.json
│       └── local-monitoring.txt
└── misc/                             # Other resources
    └── appservice-plan-*.json

\`\`\`

## Quick Start

### 1. Review Extracted Data
\`\`\`bash
# View resource summary
cat resource-summary.txt

# Check web app configurations
ls -la webapps/

# Review database details
ls -la databases/
\`\`\`

### 2. Export Database Data

For each database, navigate to its directory and run the export script:

\`\`\`bash
# Azure SQL Database
cd databases/sql-[server-name]/[database-name]
./export-data.sh

# PostgreSQL
cd databases/postgres-[server-name]
./export-data.sh

# MySQL
cd databases/mysql-[server-name]
./export-data.sh
\`\`\`

**Note**: You'll need to fill in credentials in these scripts.

### 3. Set Up Local Secrets

\`\`\`bash
# For each Key Vault, create .env file
cd keyvault/[vault-name]
cp local-secrets-template.env .env

# Export secrets from Azure and populate .env
az keyvault secret show --vault-name [vault-name] --name [secret-name] --query value -o tsv

# For each Web App, review and customize .env
cd webapps/[webapp-name]
# Edit .env file with local connection strings
\`\`\`

### 4. Customize Docker Compose

\`\`\`bash
# Edit the template
nano docker-compose.yml

# Uncomment services you need
# Update connection strings
# Configure volumes and networks
\`\`\`

### 5. Create Dockerfiles for Applications

Based on runtime configurations in \`webapps/*/runtime.json\`, create Dockerfiles:

\`\`\`dockerfile
# Example for Node.js app
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
CMD ["npm", "start"]
\`\`\`

### 6. Start Local Environment

\`\`\`bash
# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
\`\`\`

## Important Notes

### Security
- **DO NOT** commit `.env` files or files containing secrets to version control
- All \`keys.json\` and \`connection-string.json\` files contain sensitive data
- Add these patterns to \`.gitignore\`:
  \`\`\`
  *.env
  **/keys.json
  **/connection-string.json
  **/*secrets*.env
  \`\`\`

### Database Migration
- Export scripts require appropriate CLI tools:
  - SQL Server: \`sqlpackage\` or Azure CLI
  - PostgreSQL: \`pg_dump\` / \`pg_restore\`
  - MySQL: \`mysqldump\` / \`mysql\`
  - Cosmos DB: Azure Data Migration Tool or custom scripts

### Configuration Differences
- Azure managed identities → Use service principals or API keys locally
- Azure VNet → Docker networks
- Azure Application Gateway → Nginx/Traefik
- SSL certificates → Self-signed or Let's Encrypt for local dev

## Service Mapping Reference

See \`SERVICE-MAPPING.md\` for detailed Azure → Docker service mappings.

## Common Issues & Solutions

### Issue: Cannot connect to database container
- Ensure container is running: \`docker-compose ps\`
- Check connection string uses container name (not localhost)
- Verify port mappings in docker-compose.yml

### Issue: App can't find environment variables
- Ensure \`.env\` file exists in correct location
- Check \`env_file\` is specified in docker-compose.yml
- Verify variable names match what app expects

### Issue: Storage connections failing
- For Azurite, use the well-known connection string
- Ensure Azurite container is running
- Check port mappings (10000, 10001, 10002)

### Issue: Redis authentication errors
- Verify password in docker-compose.yml command matches connection string
- Check Redis container logs: \`docker-compose logs redis\`

## Additional Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Azure CLI Reference](https://docs.microsoft.com/cli/azure/)
- [Azurite (Azure Storage Emulator)](https://github.com/Azure/Azurite)
- [SQL Server Docker](https://hub.docker.com/_/microsoft-mssql-server)
- [PostgreSQL Docker](https://hub.docker.com/_/postgres)
- [MySQL Docker](https://hub.docker.com/_/mysql)
- [Redis Docker](https://hub.docker.com/_/redis)

## Next Steps

1. ✅ Extract Azure configuration (completed)
2. ⬜ Export database data
3. ⬜ Create/obtain application source code
4. ⬜ Create Dockerfiles for applications
5. ⬜ Customize docker-compose.yml
6. ⬜ Set up local secrets (.env files)
7. ⬜ Test local environment
8. ⬜ Document any custom configurations

---

Generated by: azure-infrastructure-extractor.sh
Resource Group: $RESOURCE_GROUP
Date: $(date)
EOF

    log_success "README generated"
}

# Generate automation helper scripts
generate_helper_scripts() {
    log_info "Generating helper scripts..."

    # Script to extract all Key Vault secrets
    cat > "$EXPORT_DIR/scripts/extract-keyvault-secrets.sh" <<'EOF'
#!/bin/bash
# Extract all secrets from Azure Key Vaults
# WARNING: This will export sensitive data

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXPORT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Extracting Key Vault secrets..."
echo "WARNING: This will export sensitive data to .env files"
read -p "Continue? (yes/no): " confirm

if [[ "$confirm" != "yes" ]]; then
    echo "Aborted"
    exit 0
fi

for vault_dir in "$EXPORT_DIR"/keyvault/*; do
    [[ -d "$vault_dir" ]] || continue

    vault_name=$(basename "$vault_dir")
    echo "Processing vault: $vault_name"

    env_file="$vault_dir/.env"
    > "$env_file"  # Clear file

    # Read secret names from JSON
    secret_names=$(jq -r '.[].name' "$vault_dir/secret-names.json" 2>/dev/null || echo "")

    while IFS= read -r secret; do
        [[ -z "$secret" ]] && continue

        echo "  Fetching: $secret"
        value=$(az keyvault secret show --vault-name "$vault_name" --name "$secret" --query value -o tsv 2>/dev/null || echo "")

        if [[ -n "$value" ]]; then
            echo "${secret}=${value}" >> "$env_file"
        else
            echo "${secret}=" >> "$env_file"
        fi
    done <<< "$secret_names"

    echo "  Secrets saved to: $env_file"
done

echo "Done! Remember to keep .env files secure and add them to .gitignore"
EOF
    chmod +x "$EXPORT_DIR/scripts/extract-keyvault-secrets.sh"

    # Script to update docker-compose with detected services
    cat > "$EXPORT_DIR/scripts/generate-docker-compose.sh" <<'EOF'
#!/bin/bash
# Generate docker-compose.yml based on detected Azure resources

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXPORT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_FILE="$EXPORT_DIR/docker-compose-generated.yml"

echo "Generating docker-compose.yml from extracted Azure resources..."

cat > "$OUTPUT_FILE" <<'YAML_HEADER'
version: '3.8'

# Auto-generated Docker Compose configuration
# Based on Azure resource extraction

services:
YAML_HEADER

# Add SQL Server if SQL databases detected
if ls "$EXPORT_DIR"/databases/sql-* 1> /dev/null 2>&1; then
    cat >> "$OUTPUT_FILE" <<'YAML_SQL'

  sqlserver:
    image: mcr.microsoft.com/mssql/server:2022-latest
    container_name: local-sqlserver
    environment:
      ACCEPT_EULA: "Y"
      SA_PASSWORD: "YourStrong@Passw0rd123"
      MSSQL_PID: "Developer"
    ports:
      - "1433:1433"
    volumes:
      - sqldata:/var/opt/mssql
    networks:
      - app-network
    healthcheck:
      test: /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd123" -Q "SELECT 1" || exit 1
      interval: 10s
      timeout: 3s
      retries: 10
YAML_SQL
fi

# Add PostgreSQL if detected
if ls "$EXPORT_DIR"/databases/postgres-* 1> /dev/null 2>&1; then
    cat >> "$OUTPUT_FILE" <<'YAML_PG'

  postgres:
    image: postgres:15-alpine
    container_name: local-postgres
    environment:
      POSTGRES_PASSWORD: localpassword
      POSTGRES_USER: postgres
      POSTGRES_DB: postgres
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
    networks:
      - app-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
YAML_PG
fi

# Add MySQL if detected
if ls "$EXPORT_DIR"/databases/mysql-* 1> /dev/null 2>&1; then
    cat >> "$OUTPUT_FILE" <<'YAML_MYSQL'

  mysql:
    image: mysql:8.0
    container_name: local-mysql
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: myapp
      MYSQL_USER: user
      MYSQL_PASSWORD: password
    ports:
      - "3306:3306"
    volumes:
      - mysqldata:/var/lib/mysql
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-prootpassword"]
      interval: 10s
      timeout: 5s
      retries: 5
YAML_MYSQL
fi

# Add Redis if detected
if ls "$EXPORT_DIR"/redis/* 1> /dev/null 2>&1; then
    cat >> "$OUTPUT_FILE" <<'YAML_REDIS'

  redis:
    image: redis:7-alpine
    container_name: local-redis
    command: redis-server --requirepass localpassword
    ports:
      - "6379:6379"
    volumes:
      - redisdata:/data
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5
YAML_REDIS
fi

# Add Azurite if storage accounts detected
if ls "$EXPORT_DIR"/storage/* 1> /dev/null 2>&1; then
    cat >> "$OUTPUT_FILE" <<'YAML_AZURITE'

  azurite:
    image: mcr.microsoft.com/azure-storage/azurite
    container_name: local-azurite
    ports:
      - "10000:10000"  # Blob
      - "10001:10001"  # Queue
      - "10002:10002"  # Table
    volumes:
      - azuritedata:/data
    networks:
      - app-network
    command: azurite --blobHost 0.0.0.0 --queueHost 0.0.0.0 --tableHost 0.0.0.0
YAML_AZURITE
fi

# Add MongoDB if Cosmos DB detected
if ls "$EXPORT_DIR"/databases/cosmos-* 1> /dev/null 2>&1; then
    cat >> "$OUTPUT_FILE" <<'YAML_MONGO'

  mongodb:
    image: mongo:6
    container_name: local-mongodb
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: password
    ports:
      - "27017:27017"
    volumes:
      - mongodata:/data/db
    networks:
      - app-network
    healthcheck:
      test: echo 'db.runCommand("ping").ok' | mongosh localhost:27017/test --quiet
      interval: 10s
      timeout: 5s
      retries: 5
YAML_MONGO
fi

# Add volumes section
cat >> "$OUTPUT_FILE" <<'YAML_VOLUMES'

volumes:
YAML_VOLUMES

[[ -d "$EXPORT_DIR/databases/sql-"* ]] 2>/dev/null && echo "  sqldata:" >> "$OUTPUT_FILE"
[[ -d "$EXPORT_DIR/databases/postgres-"* ]] 2>/dev/null && echo "  pgdata:" >> "$OUTPUT_FILE"
[[ -d "$EXPORT_DIR/databases/mysql-"* ]] 2>/dev/null && echo "  mysqldata:" >> "$OUTPUT_FILE"
[[ -d "$EXPORT_DIR/redis/"* ]] 2>/dev/null && echo "  redisdata:" >> "$OUTPUT_FILE"
[[ -d "$EXPORT_DIR/storage/"* ]] 2>/dev/null && echo "  azuritedata:" >> "$OUTPUT_FILE"
[[ -d "$EXPORT_DIR/databases/cosmos-"* ]] 2>/dev/null && echo "  mongodata:" >> "$OUTPUT_FILE"

# Add networks section
cat >> "$OUTPUT_FILE" <<'YAML_NETWORKS'

networks:
  app-network:
    driver: bridge
YAML_NETWORKS

echo "Generated: $OUTPUT_FILE"
echo ""
echo "Next steps:"
echo "1. Review and customize $OUTPUT_FILE"
echo "2. Add your application services"
echo "3. Configure environment variables"
echo "4. Run: docker-compose -f docker-compose-generated.yml up -d"
EOF
    chmod +x "$EXPORT_DIR/scripts/generate-docker-compose.sh"

    log_success "Helper scripts generated"
}

# Main execution
main() {
    echo "========================================"
    echo "Azure Infrastructure Extractor"
    echo "Docker Compose Migration Tool"
    echo "========================================"
    echo ""

    validate_prerequisites
    setup_directories

    # Extract all resources
    extract_all_resources
    extract_app_service_plans
    extract_web_apps
    extract_sql_databases
    extract_postgresql_databases
    extract_mysql_databases
    extract_cosmosdb
    extract_storage_accounts
    extract_redis_cache
    extract_key_vaults
    extract_app_insights

    # Generate helper files
    generate_docker_compose
    generate_service_mapping
    generate_readme
    generate_helper_scripts

    echo ""
    echo "========================================"
    log_success "Extraction Complete!"
    echo "========================================"
    echo ""
    echo "Output directory: $EXPORT_DIR"
    echo ""
    echo "Next steps:"
    echo "1. Review README.md in the output directory"
    echo "2. Run helper scripts to generate docker-compose.yml:"
    echo "   cd $EXPORT_DIR"
    echo "   ./scripts/generate-docker-compose.sh"
    echo "3. Extract database data using provided scripts"
    echo "4. Set up local secrets (.env files)"
    echo "5. Create Dockerfiles for your applications"
    echo "6. Start your local environment with docker-compose"
    echo ""
    echo "Documentation:"
    echo "- README.md: Complete guide"
    echo "- SERVICE-MAPPING.md: Azure to Docker mappings"
    echo "- docker-compose.yml: Template configuration"
    echo ""
}

# Run main function
main
