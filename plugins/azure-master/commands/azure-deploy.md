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


# Azure Deploy Command

Deploy Azure resources using ARM templates, Bicep, or Terraform with best practices.

## Agent Activation
<skill>azure-expert</skill>

## Your Task

You are helping the user deploy Azure infrastructure using Infrastructure as Code (IaC) following 2025 best practices.

### 1. DETERMINE DEPLOYMENT METHOD

Ask the user or auto-detect:
- **Bicep** (recommended for Azure-native, 2025 features)
- **ARM Templates** (mature, JSON-based)
- **Terraform** (multi-cloud)
- **Deployment Stacks** (lifecycle management, GA 2025)

### 2. RESEARCH LATEST FEATURES

```bash
WebSearch: "Azure Bicep latest features 2025"
WebSearch: "Azure Deployment Stacks best practices 2025"
WebSearch: "Azure [service] Bicep examples 2025"
```

### 3. CREATE PRODUCTION-READY TEMPLATES

**Bicep 2025 Template (v0.37+)**

```bicep
// main.bicep
targetScope = 'resourceGroup'

@description('Environment name')
@allowed([
  'dev'
  'staging'
  'production'
])
param environment string = 'dev'

@description('Location for all resources')
param location string = resourceGroup().location

@description('External configuration URI')
param configUri string

// Use externalInput() - GA in v0.37+
var config = externalInput('json', configUri)

// Resource naming with consistent pattern
var namingPrefix = 'myapp-${environment}'

// AKS Automatic cluster (2025 GA)
resource aksCluster 'Microsoft.ContainerService/managedClusters@2025-01-01' = {
  name: '${namingPrefix}-aks'
  location: location
  sku: {
    name: 'Automatic'
    tier: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: '1.34'
    dnsPrefix: '${namingPrefix}-aks'
    enableRBAC: true
    aadProfile: {
      managed: true
      enableAzureRBAC: true
      tenantID: subscription().tenantId
    }
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'cilium'
      serviceCidr: '10.0.0.0/16'
      dnsServiceIP: '10.0.0.10'
      loadBalancerSku: 'Standard'
    }
    autoScalerProfile: {
      'balance-similar-node-groups': 'true'
      expander: 'least-waste'
      'scale-down-delay-after-add': '10m'
      'scale-down-unneeded-time': '10m'
    }
    autoUpgradeProfile: {
      upgradeChannel: 'stable'
      nodeOSUpgradeChannel: 'NodeImage'
    }
    securityProfile: {
      defender: {
        securityMonitoring: {
          enabled: true
        }
      }
      workloadIdentity: {
        enabled: true
      }
    }
    oidcIssuerProfile: {
      enabled: true
    }
  }
}

// Container App Environment with GPU support
resource containerAppEnv 'Microsoft.App/managedEnvironments@2025-02-01' = {
  name: '${namingPrefix}-containerenv'
  location: location
  properties: {
    daprAIInstrumentationKey: appInsights.properties.InstrumentationKey
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
    zoneRedundant: environment == 'production' ? true : false
  }
}

// Container App with GPU
resource containerApp 'Microsoft.App/containerApps@2025-02-01' = {
  name: '${namingPrefix}-app'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    environmentId: containerAppEnv.id
    configuration: {
      dapr: {
        enabled: true
        appId: '${namingPrefix}-app'
        appPort: 8080
        appProtocol: 'http'
      }
      ingress: {
        external: true
        targetPort: 8080
        transport: 'auto'
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
    }
    template: {
      containers: [
        {
          name: 'main'
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
          resources: {
            cpu: json('2')
            memory: '4Gi'
            gpu: environment == 'production' ? {
              type: 'nvidia-a100'
              count: 1
            } : null
          }
        }
      ]
      scale: {
        minReplicas: environment == 'production' ? 1 : 0
        maxReplicas: 10
        rules: [
          {
            name: 'http-scaling'
            http: {
              metadata: {
                concurrentRequests: '10'
              }
            }
          }
        ]
      }
    }
  }
}

// Azure OpenAI with GPT-5
resource openAI 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: '${namingPrefix}-openai'
  location: location
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    customSubDomainName: '${namingPrefix}-openai'
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

resource gpt5Deployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: openAI
  name: 'gpt-5'
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-5'
      version: 'latest'
    }
    scaleSettings: {
      scaleType: 'Standard'
      capacity: 100
    }
  }
}

// Log Analytics for monitoring
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${namingPrefix}-logs'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: environment == 'production' ? 90 : 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

// Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${namingPrefix}-appinsights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    IngestionMode: 'LogAnalytics'
  }
}

// Key Vault with RBAC and purge protection
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: '${namingPrefix}-kv'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enablePurgeProtection: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

// Outputs
output aksClusterName string = aksCluster.name
output aksClusterId string = aksCluster.id
output containerAppUrl string = containerApp.properties.configuration.ingress.fqdn
output openAIEndpoint string = openAI.properties.endpoint
output keyVaultUri string = keyVault.properties.vaultUri
```

### 4. DEPLOY WITH DEPLOYMENT STACKS (2025 GA)

**Deployment Stack at Subscription Scope**

```bash
# Create deployment stack
az stack sub create \
  --name MyProductionStack \
  --location eastus \
  --template-file main.bicep \
  --parameters environment=production configUri=https://config.blob.core.windows.net/config.json \
  --deny-settings-mode DenyWriteAndDelete \
  --deny-settings-excluded-principals <devops-principal-id> \
  --action-on-unmanage detachAll \
  --description "Production infrastructure managed by deployment stack" \
  --tags Environment=Production ManagedBy=DeploymentStack

# What-if analysis before deployment
az stack sub what-if \
  --name MyProductionStack \
  --location eastus \
  --template-file main.bicep \
  --parameters environment=production

# Update stack
az stack sub update \
  --name MyProductionStack \
  --template-file main.bicep \
  --parameters @parameters.json \
  --action-on-unmanage deleteAll

# Export stack template
az stack sub export \
  --name MyProductionStack \
  --output-file exported-stack.json

# List stacks
az stack sub list --output table

# Show stack details
az stack sub show \
  --name MyProductionStack \
  --output json
```

**Deployment Stack at Resource Group Scope**

```bash
# Create resource group
az group create \
  --name MyRG \
  --location eastus \
  --tags Environment=Production

# Create stack
az stack group create \
  --name MyAppStack \
  --resource-group MyRG \
  --template-file main.bicep \
  --deny-settings-mode DenyDelete \
  --action-on-unmanage deleteAll \
  --yes
```

### 5. TRADITIONAL BICEP DEPLOYMENT

**Git Bash on Windows - IMPORTANT:**

If running in Git Bash, disable path conversion first:

```bash
# Set at start of script
export MSYS_NO_PATHCONV=1

# Or detect and configure automatically
if [[ -n "$MSYSTEM" ]]; then
    export MSYS_NO_PATHCONV=1
    echo "Git Bash detected - path conversion disabled"
fi
```

**Standard Deployment:**

```bash
# Validate template
az deployment group validate \
  --resource-group MyRG \
  --template-file main.bicep \
  --parameters @parameters.json

# What-if analysis
az deployment group what-if \
  --resource-group MyRG \
  --template-file main.bicep \
  --parameters @parameters.json

# Deploy
az deployment group create \
  --name MyDeployment-$(date +%Y%m%d-%H%M%S) \
  --resource-group MyRG \
  --template-file main.bicep \
  --parameters @parameters.json \
  --mode Incremental

# Check deployment status
az deployment group list \
  --resource-group MyRG \
  --output table

# Show deployment details
az deployment group show \
  --resource-group MyRG \
  --name MyDeployment-20250127-143000 \
  --output json
```

**Windows Path Handling:**

```bash
# If template path has spaces or needs Windows format
templatePath="C:\Projects\Azure\main.bicep"

# In Git Bash, quote properly
az deployment group create \
  --resource-group MyRG \
  --template-file "$templatePath"

# Or use cygpath to convert
templatePath=$(cygpath -w "./main.bicep")
az deployment group create \
  --resource-group MyRG \
  --template-file "$templatePath"
```

### 6. BICEP BUILD AND DECOMPILE

```bash
# Build Bicep to ARM template
az bicep build \
  --file main.bicep \
  --outfile main.json

# Decompile ARM to Bicep
az bicep decompile \
  --file template.json \
  --outfile converted.bicep

# Upgrade Bicep CLI
az bicep upgrade

# Check Bicep version
az bicep version
```

### 7. POST-DEPLOYMENT VALIDATION

```bash
# List deployed resources
az resource list \
  --resource-group MyRG \
  --output table

# Get AKS credentials
az aks get-credentials \
  --resource-group MyRG \
  --name myapp-production-aks

# Test Kubernetes connection
kubectl get nodes
kubectl get namespaces

# Get Container App URL
az containerapp show \
  --name myapp-production-app \
  --resource-group MyRG \
  --query "properties.configuration.ingress.fqdn" \
  --output tsv

# Test endpoint
curl https://$(az containerapp show -n myapp-production-app -g MyRG --query "properties.configuration.ingress.fqdn" -o tsv)

# Check OpenAI endpoint
az cognitiveservices account show \
  --name myapp-production-openai \
  --resource-group MyRG \
  --query "properties.endpoint" \
  --output tsv
```

### 8. MONITORING AND ALERTS

```bash
# Enable diagnostic settings
az monitor diagnostic-settings create \
  --name aks-diagnostics \
  --resource $(az aks show -g MyRG -n myapp-production-aks --query id -o tsv) \
  --workspace $(az monitor log-analytics workspace show -g MyRG -n myapp-production-logs --query id -o tsv) \
  --logs '[{"category":"kube-apiserver","enabled":true},{"category":"kube-controller-manager","enabled":true}]' \
  --metrics '[{"category":"AllMetrics","enabled":true}]'

# Create action group
az monitor action-group create \
  --name MyActionGroup \
  --resource-group MyRG \
  --short-name MyActions \
  --email-receiver name=DevOps email=devops@example.com

# Create alert rule
az monitor metrics alert create \
  --name high-cpu-alert \
  --resource-group MyRG \
  --scopes $(az aks show -g MyRG -n myapp-production-aks --query id -o tsv) \
  --condition "avg Percentage CPU > 80" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --action MyActionGroup
```

### 9. CLEANUP AND TEARDOWN

```bash
# Delete deployment stack (removes all managed resources)
az stack sub delete \
  --name MyProductionStack \
  --action-on-unmanage deleteAll \
  --yes

# Or delete resource group
az group delete \
  --name MyRG \
  --yes \
  --no-wait
```

## Deployment Stack Benefits (GA 2025)

✓ **Unified Management**: Manage resources as a single unit
✓ **Deny Settings**: Prevent unauthorized modifications
✓ **Cleanup**: Automatic removal of orphaned resources
✓ **Lifecycle Management**: Update, export, delete operations
✓ **Scope Flexibility**: Resource group, subscription, management group
✓ **Replaces Blueprints**: Modern alternative (Blueprints deprecated July 2026)

## Best Practices

✓ Use Deployment Stacks for production infrastructure
✓ Always run what-if analysis before deployment
✓ Use parameter files for environment-specific values
✓ Tag all resources for cost tracking and management
✓ Enable diagnostic settings and monitoring
✓ Implement RBAC with least privilege
✓ Use managed identities instead of service principals
✓ Store secrets in Key Vault, never in templates
✓ Enable zone redundancy for production workloads
✓ Implement CI/CD pipelines for automated deployment

Deploy Azure infrastructure with confidence using 2025 best practices!
