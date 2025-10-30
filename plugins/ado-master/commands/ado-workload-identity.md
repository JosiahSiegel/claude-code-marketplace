---
description: Configure workload identity federation (OIDC) for passwordless Azure authentication in pipelines
---

## 🚨 CRITICAL GUIDELINES

### Windows File Path Requirements

**MANDATORY: Always Use Backslashes on Windows for File Paths**

When using Edit or Write tools on Windows, you MUST use backslashes (`\`) in file paths, NOT forward slashes (`/`).

**Examples:**
- ❌ WRONG: `C:/projects/file.yml`
- ✅ CORRECT: `C:\projects\file.yml`

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

# Configure Workload Identity Federation (OIDC)

## Purpose

Set up workload identity federation for Azure service connections, enabling passwordless authentication following Microsoft's 2025 security best practices. This replaces legacy service principals with short-lived tokens.

## Why Workload Identity Federation?

**2025 Best Practice:** OIDC authentication is Microsoft's recommended approach for Azure DevOps pipelines.

**Benefits:**
- **No secrets to manage** - Azure DevOps issues tokens automatically
- **Short-lived tokens** - Automatically refreshed, reducing attack surface
- **Zero-trust compliant** - Meets modern security requirements
- **No credential rotation** - Eliminates manual secret management
- **Reduced risk** - No long-lived credentials stored in Azure DevOps
- **Audit trail** - Better tracking of authentication events

**Comparison:**

| Feature | Workload Identity (OIDC) | Service Principal |
|---------|-------------------------|-------------------|
| Secrets stored | None | Yes (password/certificate) |
| Token lifetime | Minutes | Up to 2 years |
| Rotation required | No | Every 90 days recommended |
| Zero-trust | Yes | No |
| Microsoft recommended | ✅ 2025 standard | ❌ Legacy |

## Prerequisites

Before configuring workload identity:
1. Azure subscription with appropriate permissions
2. Azure DevOps organization (dev.azure.com)
3. Permissions to create service connections
4. Azure CLI or Azure Portal access

## Setup Process

### 1. Create Service Connection in Azure DevOps

**Using Azure DevOps UI:**

1. Navigate to **Project Settings** → **Service connections**
2. Click **New service connection**
3. Select **Azure Resource Manager**
4. Choose **Workload Identity federation (automatic)**
5. Configure:
   - **Subscription**: Select Azure subscription
   - **Resource Group**: (Optional) Limit scope
   - **Service connection name**: `azure-oidc-connection`
   - **Grant access to all pipelines**: Uncheck (security best practice)
6. Click **Save**

**Result:** Azure DevOps automatically:
- Creates an Entra ID application
- Configures federated credentials
- Establishes trust relationship
- No secrets created or stored

### 2. Manual Configuration (Advanced)

If automatic setup fails or custom configuration needed:

**Step 1: Create Entra ID Application**
```bash
# Login to Azure
az login

# Create application
az ad app create --display-name "ado-workload-identity"

# Get application ID
APP_ID=$(az ad app list --display-name "ado-workload-identity" --query "[0].appId" -o tsv)
echo "Application ID: $APP_ID"

# Create service principal
az ad sp create --id $APP_ID
```

**Step 2: Configure Federated Credential**
```bash
# Set variables
ORG_NAME="your-organization"
PROJECT_NAME="your-project"
SERVICE_CONNECTION_NAME="azure-oidc-connection"

# Create federated credential JSON
cat <<EOF > federated-credential.json
{
  "name": "ado-federated-credential",
  "issuer": "https://vstoken.dev.azure.com/<ORG-ID>",
  "subject": "sc://${ORG_NAME}/${PROJECT_NAME}/${SERVICE_CONNECTION_NAME}",
  "audiences": [
    "api://AzureADTokenExchange"
  ]
}
EOF

# Create federated credential
az ad app federated-credential create \
  --id $APP_ID \
  --parameters @federated-credential.json
```

**Step 3: Assign Azure Permissions**
```bash
# Get subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Assign Contributor role (adjust as needed)
az role assignment create \
  --assignee $APP_ID \
  --role Contributor \
  --scope /subscriptions/$SUBSCRIPTION_ID

# Or limit to resource group
az role assignment create \
  --assignee $APP_ID \
  --role Contributor \
  --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/my-resource-group
```

**Step 4: Create Service Connection**

In Azure DevOps UI:
1. Project Settings → Service connections → New → Azure Resource Manager
2. Choose **Workload Identity federation (manual)**
3. Enter:
   - Service Principal ID: `$APP_ID`
   - Subscription ID: `$SUBSCRIPTION_ID`
   - Subscription Name: Your subscription name
   - Tenant ID: Your Entra tenant ID
4. Verify and save

### 3. Using Workload Identity in Pipelines

**Basic Usage:**
```yaml
trigger:
  branches:
    include:
      - main

pool:
  vmImage: 'ubuntu-24.04'

steps:
  - task: AzureCLI@2
    displayName: 'Deploy with OIDC'
    inputs:
      azureSubscription: 'azure-oidc-connection'  # Workload identity service connection
      scriptType: 'bash'
      scriptLocation: 'inlineScript'
      inlineScript: |
        # Automatic OIDC authentication - no secrets!
        az account show
        az group list --query "[].name" -o table
```

**Deploy to Azure:**
```yaml
stages:
  - stage: Deploy
    jobs:
      - deployment: DeployWebApp
        environment: 'production'
        strategy:
          runOnce:
            deploy:
              steps:
                - task: AzureWebApp@1
                  displayName: 'Deploy to Azure Web App'
                  inputs:
                    azureSubscription: 'azure-oidc-connection'  # OIDC connection
                    appName: 'my-web-app'
                    package: '$(Pipeline.Workspace)/drop/*.zip'
```

**Infrastructure Deployment:**
```yaml
steps:
  - task: AzureCLI@2
    displayName: 'Deploy Bicep Template'
    inputs:
      azureSubscription: 'azure-oidc-connection'
      scriptType: 'bash'
      scriptLocation: 'inlineScript'
      inlineScript: |
        az deployment group create \
          --resource-group my-rg \
          --template-file infrastructure/main.bicep \
          --parameters environment=production
```

**Multiple Azure Tasks:**
```yaml
variables:
  azureServiceConnection: 'azure-oidc-connection'

steps:
  - task: AzureCLI@2
    displayName: 'Provision infrastructure'
    inputs:
      azureSubscription: $(azureServiceConnection)
      scriptType: 'bash'
      scriptLocation: 'inlineScript'
      inlineScript: |
        az group create --name my-rg --location eastus

  - task: AzureWebApp@1
    displayName: 'Deploy application'
    inputs:
      azureSubscription: $(azureServiceConnection)
      appName: 'my-app'
      package: '$(Build.ArtifactStagingDirectory)/*.zip'

  - task: AzureCLI@2
    displayName: 'Configure monitoring'
    inputs:
      azureSubscription: $(azureServiceConnection)
      scriptType: 'bash'
      scriptLocation: 'inlineScript'
      inlineScript: |
        az monitor app-insights component create \
          --app my-app-insights \
          --location eastus \
          --resource-group my-rg
```

## Service Connection Scope

**Limit access for security:**

```yaml
# Restrict service connection to specific pipelines
# In Azure DevOps UI:
# Project Settings → Service connections → Select connection → Security
# Grant access only to specific pipelines

# In YAML, reference only permitted connections
steps:
  - task: AzureCLI@2
    inputs:
      azureSubscription: 'production-oidc'  # Only accessible from approved pipelines
      scriptType: 'bash'
      scriptLocation: 'inlineScript'
      inlineScript: |
        az account show
```

## Least Privilege Configuration

**Assign minimal required permissions:**

```bash
# Instead of Contributor on entire subscription
az role assignment create \
  --assignee $APP_ID \
  --role "Web Plan Contributor" \
  --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/my-rg

# For read-only operations
az role assignment create \
  --assignee $APP_ID \
  --role "Reader" \
  --scope /subscriptions/$SUBSCRIPTION_ID
```

**Environment-specific connections:**
```yaml
parameters:
  - name: environment
    type: string
    values:
      - dev
      - staging
      - production

variables:
  ${{ if eq(parameters.environment, 'dev') }}:
    azureConnection: 'azure-oidc-dev'
  ${{ elseif eq(parameters.environment, 'staging') }}:
    azureConnection: 'azure-oidc-staging'
  ${{ else }}:
    azureConnection: 'azure-oidc-production'

steps:
  - task: AzureCLI@2
    inputs:
      azureSubscription: $(azureConnection)
      scriptType: 'bash'
      scriptLocation: 'inlineScript'
      inlineScript: |
        echo "Deploying to ${{ parameters.environment }}"
```

## Migration from Service Principal

**Step 1: Identify Service Principals**
```bash
# List existing service connections
az devops service-endpoint list --org https://dev.azure.com/your-org --project your-project
```

**Step 2: Create OIDC Equivalents**
For each service principal connection:
1. Create new workload identity connection (see setup above)
2. Assign same Azure permissions
3. Test in non-production pipeline

**Step 3: Update Pipelines**
```yaml
# Before (Service Principal)
- task: AzureCLI@2
  inputs:
    azureSubscription: 'azure-sp-connection'  # Service principal with secret
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      az account show

# After (Workload Identity)
- task: AzureCLI@2
  inputs:
    azureSubscription: 'azure-oidc-connection'  # Workload identity, no secrets
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      az account show
```

**Step 4: Parallel Testing**
```yaml
# Test both connections simultaneously
jobs:
  - job: TestServicePrincipal
    steps:
      - task: AzureCLI@2
        inputs:
          azureSubscription: 'azure-sp-connection'
          scriptType: 'bash'
          scriptLocation: 'inlineScript'
          inlineScript: az account show

  - job: TestWorkloadIdentity
    steps:
      - task: AzureCLI@2
        inputs:
          azureSubscription: 'azure-oidc-connection'
          scriptType: 'bash'
          scriptLocation: 'inlineScript'
          inlineScript: az account show
```

**Step 5: Complete Migration**
1. Update all pipelines to use OIDC connections
2. Verify functionality in production
3. Delete service principal connections
4. Remove service principal credentials from Azure

## Troubleshooting

### Common Issues

**Issue: "Failed to obtain the JWT"**
```yaml
# Verify issuer and subject in federated credential
# Must match Azure DevOps organization structure
# Issuer: https://vstoken.dev.azure.com/<ORG-ID>
# Subject: sc://organization/project/service-connection-name
```

**Issue: "Insufficient permissions"**
```bash
# Check role assignments
az role assignment list --assignee $APP_ID --all

# Add required permissions
az role assignment create \
  --assignee $APP_ID \
  --role "Required Role" \
  --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/my-rg
```

**Issue: "Service connection not authorized"**
```yaml
# Grant pipeline access in Azure DevOps UI
# Project Settings → Service connections → Select connection
# → Security → Grant access to specific pipelines
```

### Debugging

**Enable verbose logging:**
```yaml
steps:
  - task: AzureCLI@2
    env:
      SYSTEM_DEBUG: true
    inputs:
      azureSubscription: 'azure-oidc-connection'
      scriptType: 'bash'
      scriptLocation: 'inlineScript'
      inlineScript: |
        az account show --debug
```

**Verify federated credential:**
```bash
# List federated credentials
az ad app federated-credential list --id $APP_ID

# Check configuration
az ad app federated-credential show \
  --id $APP_ID \
  --federated-credential-id <CREDENTIAL-ID>
```

## Security Best Practices

**DO:**
- ✅ Use workload identity for all new pipelines
- ✅ Assign least privilege permissions
- ✅ Restrict service connection access to specific pipelines
- ✅ Use environment-specific connections
- ✅ Regularly audit permissions
- ✅ Enable Azure AD conditional access policies

**DON'T:**
- ❌ Grant Contributor to entire subscription
- ❌ Allow access to all pipelines
- ❌ Use service principals for new connections
- ❌ Share service connections across projects unnecessarily
- ❌ Grant Owner role to pipeline identities

## Monitoring and Auditing

**Track authentication events:**
```bash
# View Azure AD sign-in logs
az monitor activity-log list \
  --resource-group my-rg \
  --caller $APP_ID

# Export audit logs
az devops security permission show \
  --org https://dev.azure.com/your-org \
  --subject $APP_ID
```

**Alert on suspicious activity:**
```yaml
# Configure Azure Monitor alerts for:
# - Failed authentication attempts
# - Permission changes
# - Unusual resource access patterns
```

## Additional Resources

- [Workload Identity Federation Documentation](https://learn.microsoft.com/azure/devops/pipelines/library/connect-to-azure)
- [Azure AD Workload Identity](https://learn.microsoft.com/azure/active-directory/workload-identities/workload-identities-overview)
- [Service Connection Security](https://learn.microsoft.com/azure/devops/pipelines/library/service-endpoints)
- [Zero Trust Security Model](https://learn.microsoft.com/security/zero-trust/zero-trust-overview)

## Summary

Workload identity federation (OIDC) is the 2025 standard for Azure authentication in Azure DevOps pipelines. It eliminates secrets, reduces security risks, and simplifies credential management. Migrate existing service principal connections to workload identity for improved security and compliance.
