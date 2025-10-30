---
description: Export Azure SQL/PostgreSQL/MySQL databases for local Docker containers
---

## 🚨 CRITICAL GUIDELINES

### Windows File Path Requirements

**MANDATORY: Always Use Backslashes on Windows for File Paths**

When using Edit or Write tools on Windows, you MUST use backslashes (`\`) in file paths, NOT forward slashes (`/`).

**Examples:**
- ❌ WRONG: `D:/repos/project/file.tsx`
- ✅ CORRECT: `D:\repos\project\file.tsx`

This applies to:
- Edit tool file_path parameter
- Write tool file_path parameter
- All file operations on Windows systems


### Documentation Guidelines

**NEVER create new documentation files unless explicitly requested by the user.**

- **Priority**: Update existing README.md files rather than creating new documentation
- **Repository cleanliness**: Keep repository root clean - only README.md unless user requests otherwise
- **Style**: Documentation should be concise, direct, and professional - avoid AI-generated tone
- **User preference**: Only create additional .md files when user specifically asks for documentation


---

# Export Azure Databases to Docker

## Purpose
Export databases from Azure (SQL Database, PostgreSQL, MySQL) and import them into local Docker containers for development.

## Prerequisites

**Required tools:**
- Azure CLI (`az`) installed and authenticated
- Docker Desktop 4.40+ with Compose v2.42+
- Database-specific CLI tools:
  - SQL Server: `sqlcmd` (mssql-tools18)
  - PostgreSQL: `psql`, `pg_dump`
  - MySQL: `mysql`, `mysqldump`

**Azure access:**
- Read permissions on databases
- Network access (firewall rules configured)
- Valid credentials

## Step 1: Configure Azure Firewall Rules

**Add your IP to Azure SQL firewall:**
```bash
# Get your public IP
MY_IP=$(curl -s ifconfig.me)

# Add firewall rule (SQL Server)
az sql server firewall-rule create \
  --resource-group <resource-group> \
  --server <server-name> \
  --name AllowMyIP \
  --start-ip-address $MY_IP \
  --end-ip-address $MY_IP

# PostgreSQL
az postgres flexible-server firewall-rule create \
  --resource-group <resource-group> \
  --name <server-name> \
  --rule-name AllowMyIP \
  --start-ip-address $MY_IP \
  --end-ip-address $MY_IP

# MySQL
az mysql flexible-server firewall-rule create \
  --resource-group <resource-group> \
  --name <server-name> \
  --rule-name AllowMyIP \
  --start-ip-address $MY_IP
```

## Step 2: Get Connection Information

**Azure SQL Database:**
```bash
# Get connection string
az sql db show-connection-string \
  --client sqlcmd \
  --name <database-name> \
  --server <server-name>

# Output format:
# sqlcmd -S <server-name>.database.windows.net -d <database-name> -U <username> -P <password> -N -l 30
```

**PostgreSQL:**
```bash
# Get server details
az postgres flexible-server show \
  --resource-group <resource-group> \
  --name <server-name> \
  --query "{fqdn:fullyQualifiedDomainName, version:version}" \
  --output table

# Connection string format:
# postgresql://<username>:<password>@<server-name>.postgres.database.azure.com:5432/<database-name>?sslmode=require
```

**MySQL:**
```bash
# Get server details
az mysql flexible-server show \
  --resource-group <resource-group> \
  --name <server-name> \
  --query "{fqdn:fullyQualifiedDomainName, version:version}" \
  --output table

# Connection string format:
# mysql://<username>:<password>@<server-name>.mysql.database.azure.com:3306/<database-name>?ssl-mode=REQUIRED
```

## Step 3: Export Database

### Azure SQL Database

**Option 1: Using Azure CLI (BACPAC):**
```bash
# Export to Azure Storage
az sql db export \
  --resource-group <resource-group> \
  --server <server-name> \
  --name <database-name> \
  --admin-user <username> \
  --admin-password <password> \
  --storage-key-type StorageAccessKey \
  --storage-key <storage-key> \
  --storage-uri https://<storage-account>.blob.core.windows.net/<container>/<database-name>.bacpac

# Download BACPAC file
az storage blob download \
  --account-name <storage-account> \
  --container-name <container> \
  --name <database-name>.bacpac \
  --file ./<database-name>.bacpac
```

**Option 2: Using sqlcmd (SQL script):**
```bash
# Install mssql-tools18 if needed
# Windows: winget install Microsoft.SqlCmd
# Linux: https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools

# Generate schema + data script
sqlcmd -S <server-name>.database.windows.net \
  -d <database-name> \
  -U <username> \
  -P <password> \
  -C \
  -Q "SELECT * FROM INFORMATION_SCHEMA.TABLES" \
  -o schema-info.txt

# For full export, use SQL Server Management Studio or Azure Data Studio
# Export wizard: Tasks → Generate Scripts → Script entire database
```

**Option 3: Using SqlPackage (recommended for large databases):**
```bash
# Install SqlPackage: https://learn.microsoft.com/en-us/sql/tools/sqlpackage/sqlpackage-download

# Export as BACPAC
sqlpackage /Action:Export \
  /SourceServerName:<server-name>.database.windows.net \
  /SourceDatabaseName:<database-name> \
  /SourceUser:<username> \
  /SourcePassword:<password> \
  /SourceTrustServerCertificate:True \
  /TargetFile:./<database-name>.bacpac

# Or export as DACPAC (schema only)
sqlpackage /Action:Extract \
  /SourceServerName:<server-name>.database.windows.net \
  /SourceDatabaseName:<database-name> \
  /SourceUser:<username> \
  /SourcePassword:<password> \
  /SourceTrustServerCertificate:True \
  /TargetFile:./<database-name>.dacpac
```

### PostgreSQL

**Using pg_dump:**
```bash
# Export entire database (schema + data)
pg_dump -h <server-name>.postgres.database.azure.com \
  -U <username> \
  -d <database-name> \
  -F c \
  -f <database-name>.dump

# Or as SQL script
pg_dump -h <server-name>.postgres.database.azure.com \
  -U <username> \
  -d <database-name> \
  --clean \
  --if-exists \
  -f <database-name>.sql

# Schema only
pg_dump -h <server-name>.postgres.database.azure.com \
  -U <username> \
  -d <database-name> \
  --schema-only \
  -f <database-name>-schema.sql

# Data only
pg_dump -h <server-name>.postgres.database.azure.com \
  -U <username> \
  -d <database-name> \
  --data-only \
  -f <database-name>-data.sql
```

### MySQL

**Using mysqldump:**
```bash
# Export entire database
mysqldump -h <server-name>.mysql.database.azure.com \
  -u <username> \
  -p<password> \
  --ssl-mode=REQUIRED \
  --databases <database-name> \
  --single-transaction \
  --routines \
  --triggers \
  > <database-name>.sql

# Schema only
mysqldump -h <server-name>.mysql.database.azure.com \
  -u <username> \
  -p<password> \
  --ssl-mode=REQUIRED \
  --no-data \
  --databases <database-name> \
  > <database-name>-schema.sql

# Data only
mysqldump -h <server-name>.mysql.database.azure.com \
  -u <username> \
  -p<password> \
  --ssl-mode=REQUIRED \
  --no-create-info \
  --databases <database-name> \
  > <database-name>-data.sql
```

## Step 4: Prepare Local Docker Containers

Ensure Docker Compose is configured with database services.

**SQL Server container:**
```yaml
services:
  sqlserver:
    image: mcr.microsoft.com/mssql/server:2025-latest
    environment:
      - ACCEPT_EULA=Y
      - MSSQL_PID=Developer
      - MSSQL_SA_PASSWORD=YourStrong!Passw0rd
    ports:
      - "1433:1433"
    volumes:
      - sqlserver-data:/var/opt/mssql
      - ./init:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD-SHELL", "/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P $$MSSQL_SA_PASSWORD -Q 'SELECT 1' -C || exit 1"]
      interval: 10s
      timeout: 3s
      retries: 3
```

**PostgreSQL container:**
```yaml
services:
  postgres:
    image: postgres:16-alpine
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres123
      - POSTGRES_DB=myapp
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./init:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 3s
      retries: 3
```

**MySQL container:**
```yaml
services:
  mysql:
    image: mysql:8.4
    environment:
      - MYSQL_ROOT_PASSWORD=mysql123
      - MYSQL_DATABASE=myapp
    ports:
      - "3306:3306"
    volumes:
      - mysql-data:/var/lib/mysql
      - ./init:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-p$$MYSQL_ROOT_PASSWORD"]
      interval: 10s
      timeout: 3s
      retries: 3
```

## Step 5: Start Docker Containers

```bash
# Start database containers
docker compose up -d sqlserver postgres mysql

# Wait for health checks to pass
docker compose ps

# Check logs
docker compose logs sqlserver
```

## Step 6: Import Data into Docker Containers

### SQL Server

**Using sqlcmd:**
```bash
# Import SQL script
sqlcmd -S localhost,1433 \
  -U sa \
  -P YourStrong!Passw0rd \
  -C \
  -i <database-name>.sql

# Or execute via docker exec
docker compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost \
  -U sa \
  -P YourStrong!Passw0rd \
  -C \
  -i /tmp/<database-name>.sql
```

**Using SqlPackage (BACPAC):**
```bash
# Import BACPAC
sqlpackage /Action:Import \
  /SourceFile:./<database-name>.bacpac \
  /TargetServerName:localhost \
  /TargetDatabaseName:<database-name> \
  /TargetUser:sa \
  /TargetPassword:YourStrong!Passw0rd \
  /TargetTrustServerCertificate:True

# Or via docker exec
docker cp <database-name>.bacpac sqlserver:/tmp/
docker compose exec sqlserver /opt/sqlpackage/sqlpackage \
  /Action:Import \
  /SourceFile:/tmp/<database-name>.bacpac \
  /TargetServerName:localhost \
  /TargetDatabaseName:<database-name> \
  /TargetUser:sa \
  /TargetPassword:YourStrong!Passw0rd \
  /TargetTrustServerCertificate:True
```

### PostgreSQL

**Using psql:**
```bash
# Import SQL script
psql -h localhost \
  -U postgres \
  -d myapp \
  -f <database-name>.sql

# Or with custom-format dump
pg_restore -h localhost \
  -U postgres \
  -d myapp \
  -v \
  <database-name>.dump

# Via docker exec
docker cp <database-name>.sql postgres:/tmp/
docker compose exec postgres psql \
  -U postgres \
  -d myapp \
  -f /tmp/<database-name>.sql
```

### MySQL

**Using mysql:**
```bash
# Import SQL script
mysql -h localhost \
  -u root \
  -pmysql123 \
  < <database-name>.sql

# Via docker exec
docker cp <database-name>.sql mysql:/tmp/
docker compose exec mysql mysql \
  -u root \
  -pmysql123 \
  < /tmp/<database-name>.sql
```

## Step 7: Verify Import

**SQL Server:**
```bash
sqlcmd -S localhost,1433 -U sa -P YourStrong!Passw0rd -C -Q "SELECT name FROM sys.databases"
sqlcmd -S localhost,1433 -U sa -P YourStrong!Passw0rd -C -Q "USE <database-name>; SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES"
```

**PostgreSQL:**
```bash
docker compose exec postgres psql -U postgres -d myapp -c "\dt"
docker compose exec postgres psql -U postgres -d myapp -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public'"
```

**MySQL:**
```bash
docker compose exec mysql mysql -u root -pmysql123 -e "SHOW DATABASES"
docker compose exec mysql mysql -u root -pmysql123 myapp -e "SHOW TABLES"
```

## Step 8: Automate with Init Scripts

Place SQL files in `./init/` directory for automatic import on container startup.

**SQL Server init script (init/01-create-database.sql):**
```sql
-- Wait for SQL Server to be ready
WAITFOR DELAY '00:00:10';
GO

-- Create database if not exists
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'MyApp')
BEGIN
    CREATE DATABASE MyApp;
END
GO

USE MyApp;
GO

-- Your schema and data here
CREATE TABLE Users (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) NOT NULL
);
GO
```

**PostgreSQL init script (init/01-init.sql):**
```sql
-- Runs automatically on first container start
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL
);

INSERT INTO users (username, email) VALUES
    ('admin', 'admin@example.com'),
    ('user', 'user@example.com');
```

**MySQL init script (init/01-init.sql):**
```sql
-- Runs automatically on first container start
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL
);

INSERT INTO users (username, email) VALUES
    ('admin', 'admin@example.com'),
    ('user', 'user@example.com');
```

## Step 9: Handle Large Databases

For databases > 10GB:

1. **Use compression:**
   ```bash
   pg_dump -h <server> -U <user> -d <db> -F c -Z 9 -f <db>.dump.gz
   ```

2. **Export schema separately:**
   ```bash
   pg_dump -h <server> -U <user> -d <db> --schema-only -f schema.sql
   ```

3. **Export data in chunks:**
   ```bash
   pg_dump -h <server> -U <user> -d <db> -t table1 --data-only -f table1.sql
   pg_dump -h <server> -U <user> -d <db> -t table2 --data-only -f table2.sql
   ```

4. **Use parallel export (PostgreSQL):**
   ```bash
   pg_dump -h <server> -U <user> -d <db> -F d -j 4 -f ./dump_directory
   ```

5. **Consider subset of data for development:**
   ```sql
   -- Export last 6 months only
   pg_dump -h <server> -U <user> -d <db> \
     -t table1 \
     --where="created_at > NOW() - INTERVAL '6 months'" \
     -f subset.sql
   ```

## Step 10: Clean Up Azure Resources

Remove firewall rules after export:

```bash
# SQL Server
az sql server firewall-rule delete \
  --resource-group <resource-group> \
  --server <server-name> \
  --name AllowMyIP

# PostgreSQL
az postgres flexible-server firewall-rule delete \
  --resource-group <resource-group> \
  --name <server-name> \
  --rule-name AllowMyIP

# MySQL
az mysql flexible-server firewall-rule delete \
  --resource-group <resource-group> \
  --name <server-name> \
  --rule-name AllowMyIP
```

## Common Issues and Solutions

**Connection timeout:**
- Verify firewall rules include your IP
- Check network connectivity to Azure
- Ensure NSG rules allow database traffic

**Authentication failed:**
- Verify username format (PostgreSQL/MySQL require `user@server-name`)
- Check password for special characters (escape in shell)
- Ensure Azure AD authentication is not required

**BACPAC import fails:**
- Check SQL Server version compatibility
- Ensure sufficient disk space in Docker volume
- Review error messages for missing dependencies

**Large file transfer fails:**
- Use compression
- Split into multiple files
- Consider Azure Data Factory for large datasets

**Schema compatibility issues:**
- Azure SQL → SQL Server 2025: Generally compatible
- Check for Azure-specific features (elastic pools, etc.)
- Test import in non-production environment first

## Best Practices

1. **Use separate init scripts for schema and data**
2. **Version control schema scripts**
3. **Exclude sensitive data from exports**
4. **Test import process before full migration**
5. **Document any manual adjustments needed**
6. **Use environment variables for credentials**
7. **Automate with CI/CD pipelines**
8. **Keep export files secure (gitignore)**
9. **Regularly refresh local data from Azure**
10. **Consider using sample data for local development**

## Automation Script Example

Create `scripts/export-and-import.sh`:

```bash
#!/bin/bash
set -euo pipefail

# Configuration
AZURE_SERVER="myserver.database.windows.net"
AZURE_DB="myapp"
AZURE_USER="admin"
AZURE_PASS="${AZURE_SQL_PASSWORD}"

echo "Exporting from Azure..."
pg_dump -h "$AZURE_SERVER" -U "$AZURE_USER" -d "$AZURE_DB" -F c -f ./dump.sql

echo "Starting Docker container..."
docker compose up -d postgres
sleep 10

echo "Importing to Docker..."
docker cp ./dump.sql postgres:/tmp/
docker compose exec -T postgres pg_restore -U postgres -d myapp -v /tmp/dump.sql

echo "Verifying import..."
docker compose exec -T postgres psql -U postgres -d myapp -c "\dt"

echo "Done! Database ready for local development."
```

## Output Deliverables

Provide:
1. Database export files (.sql, .bacpac, .dump)
2. Import scripts for Docker containers
3. Init directory structure for auto-loading
4. Verification queries
5. Documentation of any schema changes needed
6. Connection string examples for local development

## Next Steps

After importing databases:
1. Update application connection strings
2. Test application against local databases
3. Verify all tables and data imported correctly
4. Document any Azure-specific features not available locally
5. Set up regular refresh process from Azure
