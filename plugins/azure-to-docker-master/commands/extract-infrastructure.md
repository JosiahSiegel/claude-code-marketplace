---
description: Extract Azure infrastructure and generate Docker Compose stack for local development
---

# Extract Azure Infrastructure to Docker Compose

## Purpose
Analyze existing Azure infrastructure and generate a complete Docker Compose stack with Azure service emulators for local development.

## Prerequisites

**Required tools:**
- Azure CLI (`az`) installed and configured
- Docker Desktop 4.38+ with Compose v2.40+
- Sufficient local resources (minimum 8GB RAM for full Azure stack)

**Azure access:**
- Authenticated with `az login`
- Appropriate RBAC permissions to read resources
- Access to target resource group

## Step 1: Authenticate with Azure

```bash
# Login to Azure
az login

# List available subscriptions
az account list --output table

# Set target subscription
az account set --subscription "subscription-name-or-id"

# Verify current subscription
az account show
```

## Step 2: Extract Azure Resources

### List Resources in Resource Group

```bash
# List all resources in resource group
az resource list \
  --resource-group <resource-group-name> \
  --output table

# Get detailed JSON output for analysis
az resource list \
  --resource-group <resource-group-name> \
  --output json > azure-resources.json
```

### Extract Specific Service Configurations

**App Services:**
```bash
# List App Services
az webapp list \
  --resource-group <resource-group-name> \
  --output json > app-services.json

# Get detailed configuration for each app
az webapp show \
  --name <app-name> \
  --resource-group <resource-group-name> \
  --output json > app-<app-name>.json

# Get application settings (environment variables)
az webapp config appsettings list \
  --name <app-name> \
  --resource-group <resource-group-name> \
  --output json > app-<app-name>-settings.json

# Get connection strings
az webapp config connection-string list \
  --name <app-name> \
  --resource-group <resource-group-name> \
  --output json > app-<app-name>-connections.json
```

**Azure SQL Databases:**
```bash
# List SQL servers
az sql server list \
  --resource-group <resource-group-name> \
  --output json > sql-servers.json

# List databases on server
az sql db list \
  --server <server-name> \
  --resource-group <resource-group-name> \
  --output json > sql-databases.json

# Get database details
az sql db show \
  --name <database-name> \
  --server <server-name> \
  --resource-group <resource-group-name> \
  --output json > sql-db-<database-name>.json
```

**PostgreSQL/MySQL:**
```bash
# PostgreSQL
az postgres flexible-server list \
  --resource-group <resource-group-name> \
  --output json > postgres-servers.json

az postgres flexible-server db list \
  --server-name <server-name> \
  --resource-group <resource-group-name> \
  --output json > postgres-databases.json

# MySQL
az mysql flexible-server list \
  --resource-group <resource-group-name> \
  --output json > mysql-servers.json
```

**Redis Cache:**
```bash
az redis list \
  --resource-group <resource-group-name> \
  --output json > redis-caches.json

az redis show \
  --name <redis-name> \
  --resource-group <resource-group-name> \
  --output json > redis-<redis-name>.json
```

**Storage Accounts:**
```bash
az storage account list \
  --resource-group <resource-group-name> \
  --output json > storage-accounts.json

az storage account show \
  --name <storage-account-name> \
  --resource-group <resource-group-name> \
  --output json > storage-<storage-account-name>.json
```

**Cosmos DB:**
```bash
az cosmosdb list \
  --resource-group <resource-group-name> \
  --output json > cosmosdb-accounts.json

az cosmosdb show \
  --name <cosmosdb-name> \
  --resource-group <resource-group-name> \
  --output json > cosmosdb-<cosmosdb-name>.json
```

**Service Bus:**
```bash
az servicebus namespace list \
  --resource-group <resource-group-name> \
  --output json > servicebus-namespaces.json

az servicebus queue list \
  --namespace-name <namespace-name> \
  --resource-group <resource-group-name> \
  --output json > servicebus-queues.json
```

## Step 3: Analyze Extracted Resources

Read all JSON files and identify:

1. **Service Types and Counts**
   - How many App Services?
   - Database types (SQL Server, PostgreSQL, MySQL)?
   - Cache services (Redis)?
   - Storage requirements (Blob, Queue, Table)?
   - NoSQL databases (Cosmos DB)?
   - Message queues (Service Bus)?

2. **Service Dependencies**
   - Which apps connect to which databases?
   - Connection strings and relationships
   - Network configurations
   - Authentication methods

3. **Configuration Requirements**
   - Environment variables from app settings
   - Connection strings
   - Feature flags
   - Secrets (need local equivalents)

4. **Resource Sizing**
   - Database SKUs → Docker resource limits
   - App Service plans → Container CPU/memory
   - Storage capacity → Volume sizing

## Step 4: Map Azure Services to Docker

Use this mapping table:

| Azure Service | Docker Image | Configuration Notes |
|---------------|--------------|---------------------|
| App Service (Windows) | Custom build | Extract runtime stack from config |
| App Service (Linux) | Custom build | Use specified container image |
| Azure SQL Database | `mcr.microsoft.com/mssql/server:2025-RC0` | Use Developer edition |
| PostgreSQL Flexible Server | `postgres:16-alpine` | Match version from Azure |
| MySQL Flexible Server | `mysql:8.4` | Match version from Azure |
| Redis Cache | `redis:7.4-alpine` | Configure persistence |
| Storage Account (Blob/Queue/Table) | `mcr.microsoft.com/azure-storage/azurite` | All storage types in one |
| Cosmos DB | `mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator` | NoSQL emulator |
| Service Bus | Custom or `rabbitmq:3.13-alpine` | Limited emulator support |
| Application Insights | `jaegertracing/all-in-one` | OpenTelemetry compatible |

## Step 5: Generate Docker Compose Structure

Create `docker-compose.yml` with this structure:

```yaml
# Modern Compose format (no version field for v2.40+)

services:
  # Frontend App Services
  # Backend App Services
  # Databases (SQL Server, PostgreSQL, MySQL)
  # Cache (Redis)
  # Storage (Azurite)
  # NoSQL (Cosmos DB)
  # Monitoring (Jaeger, Grafana)

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true
  monitoring:
    driver: bridge

volumes:
  # Named volumes for each database
  # Named volumes for storage emulators

secrets:
  # Database passwords
  # Connection strings
```

### Service Generation Rules

**For each App Service:**
```yaml
service-name:
  build:
    context: ./path-to-app
    dockerfile: Dockerfile
  ports:
    - "PORT:PORT"
  depends_on:
    database-service:
      condition: service_healthy
  environment:
    # Map from Azure app settings
  networks:
    - frontend
    - backend
  restart: unless-stopped
  user: "1000:1000"
  read_only: true
  tmpfs:
    - /tmp
  cap_drop:
    - ALL
  cap_add:
    - NET_BIND_SERVICE
  healthcheck:
    test: ["CMD", "curl", "-f", "http://localhost:PORT/health"]
    interval: 30s
    timeout: 3s
    retries: 3
    start_period: 40s
  deploy:
    resources:
      limits:
        cpus: 'X'
        memory: XG
```

**For Azure SQL Database:**
```yaml
sqlserver:
  image: mcr.microsoft.com/mssql/server:2025-RC0
  environment:
    - ACCEPT_EULA=Y
    - MSSQL_PID=Developer
    - MSSQL_SA_PASSWORD_FILE=/run/secrets/sa_password
  secrets:
    - sa_password
  ports:
    - "1433:1433"
  volumes:
    - sqlserver-data:/var/opt/mssql
  networks:
    - backend
  healthcheck:
    test: ["CMD-SHELL", "/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P $$MSSQL_SA_PASSWORD -Q 'SELECT 1' -C || exit 1"]
    interval: 10s
    timeout: 3s
    retries: 3
    start_period: 10s
  deploy:
    resources:
      limits:
        cpus: '2'
        memory: 4G
      reservations:
        cpus: '1'
        memory: 2G
  security_opt:
    - no-new-privileges:true
```

**For Storage Account:**
```yaml
azurite:
  image: mcr.microsoft.com/azure-storage/azurite:latest
  command: azurite --blobHost 0.0.0.0 --queueHost 0.0.0.0 --tableHost 0.0.0.0 --loose
  ports:
    - "10000:10000"  # Blob
    - "10001:10001"  # Queue
    - "10002:10002"  # Table
  volumes:
    - azurite-data:/data
  networks:
    - backend
  healthcheck:
    test: ["CMD", "nc", "-z", "localhost", "10000"]
    interval: 30s
    timeout: 3s
    retries: 3
  restart: unless-stopped
```

**For Redis Cache:**
```yaml
redis:
  image: redis:7.4-alpine
  command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
  ports:
    - "6379:6379"
  volumes:
    - redis-data:/data
  networks:
    - backend
  healthcheck:
    test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
    interval: 10s
    timeout: 3s
    retries: 3
  security_opt:
    - no-new-privileges:true
```

**For Cosmos DB:**
```yaml
cosmosdb:
  image: mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator:latest
  environment:
    - AZURE_COSMOS_EMULATOR_PARTITION_COUNT=10
    - AZURE_COSMOS_EMULATOR_ENABLE_DATA_PERSISTENCE=true
  ports:
    - "8081:8081"
    - "10251-10254:10251-10254"
  volumes:
    - cosmos-data:/data/db
  networks:
    - backend
  deploy:
    resources:
      limits:
        cpus: '2'
        memory: 4G
```

## Step 6: Generate Environment Files

Create `.env.template`:

```bash
# SQL Server
MSSQL_SA_PASSWORD=YourStrong!Passw0rd

# PostgreSQL (if used)
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres123
POSTGRES_DB=myapp

# MySQL (if used)
MYSQL_ROOT_PASSWORD=mysql123
MYSQL_DATABASE=myapp

# Redis
REDIS_PASSWORD=redis123

# Application Settings
# (Map from Azure app settings JSON)
ASPNETCORE_ENVIRONMENT=Development
NODE_ENV=development

# Azure Storage Emulator (Standard Development Connection String)
AZURITE_CONNECTION_STRING=DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://azurite:10000/devstoreaccount1;QueueEndpoint=http://azurite:10001/devstoreaccount1;TableEndpoint=http://azurite:10002/devstoreaccount1;

# Cosmos DB Emulator
COSMOS_EMULATOR_ENDPOINT=https://cosmosdb:8081
COSMOS_EMULATOR_KEY=C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw==

# Feature Flags
ENABLE_MONITORING=true
```

## Step 7: Create Supporting Files

**Makefile:**
```makefile
.PHONY: up down logs health restart clean

up:
	@docker compose up -d
	@echo "✓ Services started. Access at:"
	@echo "  - Frontend: http://localhost:3000"
	@echo "  - Backend: http://localhost:8080"
	@echo "  - Azurite: http://localhost:10000"
	@echo "  - Cosmos DB: https://localhost:8081/_explorer/index.html"

down:
	@docker compose down

logs:
	@docker compose logs -f

health:
	@docker compose ps

restart:
	@docker compose restart

clean:
	@docker compose down -v
	@echo "✓ Cleaned all volumes"

init:
	@cp .env.template .env
	@echo "✓ Created .env file. Please update passwords!"
```

**README.md:**
Include:
- Architecture diagram of services
- Service mapping (Azure → Docker)
- Port mappings
- Connection strings for local development
- How to start/stop
- Health check verification
- Troubleshooting guide

**docker-compose.override.yml (for development):**
```yaml
services:
  frontend:
    volumes:
      - ./frontend/src:/app/src:cached
    environment:
      - HOT_RELOAD=true

  backend:
    volumes:
      - ./backend/src:/app/src:cached
    ports:
      - "9229:9229"  # Node.js debugger
```

## Step 8: Validation

Before finalizing, validate:

1. **Syntax validation:**
   ```bash
   docker compose config
   ```

2. **Service startup order:**
   - Databases start first
   - Health checks complete before dependent services start
   - Apps start after all dependencies are healthy

3. **Network isolation:**
   - Databases only on backend network
   - Frontend services can't directly access databases
   - Proper communication paths

4. **Resource limits:**
   - Total CPU allocation < host CPUs
   - Total memory allocation < host memory
   - Leave headroom for host OS

5. **Security checks:**
   - No hardcoded secrets in docker-compose.yml
   - All services run as non-root where possible
   - Read-only filesystems enabled
   - Capabilities dropped

## Output Deliverables

Provide the following files:

1. `docker-compose.yml` - Main compose file
2. `docker-compose.override.yml` - Development overrides
3. `.env.template` - Environment variable template
4. `Makefile` - Common operations
5. `README.md` - Setup and usage documentation
6. `.dockerignore` - Files to exclude from builds
7. `secrets/` directory structure (gitignored)

## Common Azure Patterns

### Pattern 1: Simple Web + Database
- 1 App Service → web container
- 1 Azure SQL → SQL Server 2025 container
- 1 Storage Account → Azurite

### Pattern 2: Three-Tier Application
- Frontend App Service → React/Angular container
- Backend App Service → API container
- Azure SQL → SQL Server 2025 container
- Redis Cache → Redis container
- Storage Account → Azurite

### Pattern 3: Microservices
- Multiple App Services → Multiple containers
- Azure SQL + Cosmos DB → SQL Server + Cosmos emulator
- Service Bus → RabbitMQ
- Application Insights → Jaeger
- API Management → Nginx gateway

### Pattern 4: Full Azure Stack
- Multiple App Services (frontend/backend/admin)
- Azure SQL + PostgreSQL + MySQL
- Redis Cache
- Storage Account → Azurite
- Cosmos DB → Cosmos emulator
- Service Bus → Custom emulator
- Application Insights → Jaeger + Grafana

## Tips and Best Practices

1. **Start Simple:** Extract minimal viable stack first, add services incrementally
2. **Health Checks:** Ensure every service has working health checks
3. **Dependencies:** Use `depends_on` with `condition: service_healthy`
4. **Secrets Management:** Never commit .env files, provide .env.template
5. **Resource Limits:** Set realistic limits based on local development machine
6. **Network Design:** Isolate backend services from direct external access
7. **Documentation:** Document Azure→Docker mapping for team reference
8. **Version Control:** Exclude .env, secrets/, and volumes/ from git

## Troubleshooting

**Services fail to start:**
- Check Docker Desktop resource allocation
- Verify no port conflicts with other local services
- Review logs: `docker compose logs <service-name>`

**Database connection issues:**
- Verify connection strings use service names (not localhost)
- Check network configuration
- Ensure health checks pass before apps start

**Performance issues:**
- Increase Docker Desktop memory allocation
- Reduce number of services running simultaneously
- Use volume caching for macOS (`:cached`)

**Azurite connection failures:**
- Use standard development account key
- Ensure ports 10000-10002 are available
- Verify `--loose` flag for compatibility

## Next Steps

After generating Docker Compose stack:
1. Test with `docker compose up`
2. Verify health checks: `docker compose ps`
3. Export databases using `/export-database` command
4. Generate Dockerfiles using `/generate-dockerfile` command
5. Document any Azure-specific features not replicated locally
