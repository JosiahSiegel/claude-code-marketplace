---
description: Generate production-ready Dockerfiles from Azure App Service configurations
---

# Generate Dockerfile Command

## Purpose
Automatically generate optimized, production-ready Dockerfiles based on Azure App Service runtime configurations.

## Process

1. **Detect Runtime from Azure Config**
   - Read app service configuration JSON
   - Identify runtime stack (Node.js, Python, .NET, PHP, Java, Ruby)
   - Extract version information

2. **Run Dockerfile Generator**
   - Use `dockerfile-generator.sh` script
   - Script location: `${CLAUDE_PLUGIN_ROOT}/scripts/`
   - Generates multi-stage Dockerfile

3. **Generated Components**
   - **Dockerfile**: Multi-stage build (development + production)
   - **.dockerignore**: Security-focused ignore patterns
   - **docker-compose entry**: Service definition for the app

4. **Supported Runtimes**
   - **Node.js**: 16, 18, 20, 22 LTS versions
   - **Python**: 3.9, 3.10, 3.11, 3.12
   - **.NET**: 6.0, 7.0, 8.0
   - **PHP**: 8.0, 8.1, 8.2, 8.3
   - **Java**: 11, 17, 21 (with Maven/Gradle)
   - **Ruby**: 3.0, 3.1, 3.2, 3.3

5. **Best Practices Included**
   - Multi-stage builds for smaller images
   - Non-root user execution
   - Health check endpoints
   - Layer caching optimization
   - Security scanning ready
   - Production dependencies only in final stage

## Usage Example

```bash
# Generate from Azure App Service config
cd ${CLAUDE_PLUGIN_ROOT}/scripts
./dockerfile-generator.sh NODE 18-lts webapp-name

# Or specify runtime directly
./dockerfile-generator.sh PYTHON 3.11 api-service
./dockerfile-generator.sh DOTNET 8.0 backend-api
./dockerfile-generator.sh PHP 8.3 legacy-app

# Output will be in specified directory
ls -la webapp-name/
# Dockerfile
# .dockerignore
# docker-compose.yml (service entry)
```

## Advanced Options

The script supports:
- Custom output directories
- Development vs production targets
- Port configuration
- Environment variable templates
- Health check customization

## Integration with Docker Security Review

After generating Dockerfiles:
1. Run docker-master security review
2. Scan for vulnerabilities with Trivy
3. Apply CIS Docker Benchmark recommendations
4. Review and optimize layer sizes

## Next Steps After Generation

1. **Review the Dockerfile**
   - Verify base image versions
   - Check exposed ports
   - Validate health check endpoints

2. **Customize as Needed**
   - Add application-specific dependencies
   - Configure environment variables
   - Adjust resource limits

3. **Build and Test**
   ```bash
   docker build -t webapp-name:latest .
   docker run -p 8080:8080 webapp-name:latest
   ```

4. **Integrate into docker-compose**
   - Copy service definition to main docker-compose.yml
   - Configure dependencies (databases, redis, etc.)
   - Set up networks and volumes
