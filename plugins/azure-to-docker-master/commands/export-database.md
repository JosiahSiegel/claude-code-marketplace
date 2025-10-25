---
description: Export Azure SQL/PostgreSQL/MySQL databases for local Docker containers
---

# Export Azure Database Command

## Purpose
Export Azure databases (SQL, PostgreSQL, MySQL) in formats compatible with local Docker containers.

## Process

### Azure SQL Database Export

1. **BACPAC Export (Recommended)**
   ```bash
   # Use Azure CLI
   az sql db export \
     --name DATABASE_NAME \
     --server SERVER_NAME \
     --resource-group RESOURCE_GROUP \
     --admin-user sqladmin \
     --admin-password 'PASSWORD' \
     --storage-key-type StorageAccessKey \
     --storage-key 'STORAGE_KEY' \
     --storage-uri 'https://STORAGE.blob.core.windows.net/backups/db.bacpac'
   ```

2. **Portal Export**
   - Navigate to Azure SQL Database in portal
   - Click "Export" button
   - Select storage account and container
   - Provide admin credentials
   - Wait for export completion
   - Download BACPAC file

3. **SqlPackage Export**
   ```bash
   sqlpackage /Action:Export \
     /SourceServerName:SERVER.database.windows.net \
     /SourceDatabaseName:DATABASE \
     /SourceUser:USERNAME \
     /SourcePassword:PASSWORD \
     /TargetFile:database.bacpac
   ```

### Import to Local SQL Server Container

```bash
# Start SQL Server container
docker run -d \
  --name local-sqlserver \
  -e "ACCEPT_EULA=Y" \
  -e "SA_PASSWORD=YourStrong@Password" \
  -p 1433:1433 \
  -v $(pwd)/backups:/backups \
  mcr.microsoft.com/mssql/server:2022-latest

# Import BACPAC
docker exec -it local-sqlserver \
  /opt/mssql-tools/bin/sqlpackage \
  /Action:Import \
  /SourceFile:/backups/database.bacpac \
  /TargetServerName:localhost \
  /TargetDatabaseName:DATABASE \
  /TargetUser:sa \
  /TargetPassword:YourStrong@Password
```

### PostgreSQL Export

```bash
# Dump from Azure PostgreSQL
pg_dump \
  --host=SERVER.postgres.database.azure.com \
  --port=5432 \
  --username=USERNAME@SERVER \
  --dbname=DATABASE \
  --format=custom \
  --file=database.dump

# OR plain SQL
pg_dump \
  --host=SERVER.postgres.database.azure.com \
  --username=USERNAME@SERVER \
  --dbname=DATABASE \
  > database.sql
```

### Import to Local PostgreSQL Container

```bash
# Start PostgreSQL container
docker run -d \
  --name local-postgres \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_DB=DATABASE \
  -p 5432:5432 \
  -v $(pwd)/backups:/backups \
  postgres:15-alpine

# Import dump
docker exec -it local-postgres \
  pg_restore \
  --username=postgres \
  --dbname=DATABASE \
  /backups/database.dump

# OR import SQL
docker exec -i local-postgres \
  psql -U postgres -d DATABASE < database.sql
```

### MySQL Export

```bash
# Dump from Azure MySQL
mysqldump \
  --host=SERVER.mysql.database.azure.com \
  --port=3306 \
  --user=USERNAME@SERVER \
  --password \
  --databases DATABASE \
  > database.sql
```

### Import to Local MySQL Container

```bash
# Start MySQL container
docker run -d \
  --name local-mysql \
  -e MYSQL_ROOT_PASSWORD=password \
  -e MYSQL_DATABASE=DATABASE \
  -p 3306:3306 \
  -v $(pwd)/backups:/backups \
  mysql:8.0

# Import SQL
docker exec -i local-mysql \
  mysql -u root -ppassword DATABASE < database.sql
```

## Automated Export Scripts

The extraction tool generates ready-to-use export scripts:

```bash
# After running extract-infrastructure
cd azure-export/RESOURCE_GROUP_*/database/

# Run generated export script
./export-DATABASE.sh
```

## Data Subset for Development

For large databases, consider exporting subsets:

**SQL Server:**
```sql
-- Export specific tables or filtered data
SELECT * INTO SmallTable FROM LargeTable WHERE Date > '2024-01-01'
```

**PostgreSQL:**
```bash
pg_dump \
  --table=users \
  --table=orders \
  --host=SERVER.postgres.database.azure.com \
  --username=USERNAME@SERVER \
  DATABASE > subset.sql
```

## Security Considerations

- **Never commit passwords to git** - Use .env files
- **Encrypt backups** containing sensitive data
- **Use temporary storage** accounts for exports
- **Clean up exports** from Azure Storage after download
- **Restrict network access** to databases during export
- **Use managed identities** where possible

## Troubleshooting

**Export fails with timeout:**
- Large databases may need longer timeout settings
- Consider exporting during off-peak hours
- Use service tier with higher DTU/vCore

**BACPAC import fails:**
- Check SQL Server version compatibility
- Verify sufficient memory in container
- Review import logs for specific errors

**Connection refused:**
- Verify firewall rules allow your IP
- Check if database server is online
- Validate credentials and connection string

## Performance Tips

- **Compress exports** to reduce download time
- **Parallel export** for tables (custom scripts)
- **Direct restore** to container volume for faster import
- **Use fast storage** for container volumes (not bind mounts)
