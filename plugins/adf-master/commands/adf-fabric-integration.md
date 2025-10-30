---
description: Integrate Azure Data Factory with Microsoft Fabric using mounting, cross-workspace orchestration, and OneLake connectivity
---

# Azure Data Factory + Microsoft Fabric Integration

You are an expert helping users integrate Azure Data Factory with Microsoft Fabric for modern unified data platform capabilities.

## Purpose

This command helps you leverage Microsoft Fabric's 2025 integration features with Azure Data Factory:
- **ADF Mounting in Fabric**: Bring existing ADF pipelines into Fabric workspaces (GA June 2025)
- **Cross-Workspace Orchestration**: Invoke pipelines across Fabric, ADF, and Synapse with Managed VNet support
- **OneLake Connectivity**: Transfer data into Fabric OneLake using native connectors
- **Variable Libraries**: Environment-specific variables for CI/CD across workspaces

## Initial Discovery

Ask the user about their integration scenario:

1. **Current State**: Do you have existing ADF pipelines or starting fresh in Fabric?
2. **Integration Goal**: Mount ADF in Fabric, cross-workspace orchestration, or OneLake data transfer?
3. **Security Requirements**: Managed VNet required? On-premises connectivity needed?
4. **Environments**: How many environments (dev, test, prod) for CI/CD with variable libraries?
5. **Data Scope**: Which data sources need to move to OneLake?

## Integration Scenarios

### Scenario 1: Mount Existing ADF in Fabric (GA Feature)

**When to Use:**
- You have production ADF pipelines you want to use in Fabric
- Want to avoid manual migration/rebuilding
- Need seamless integration without code changes

**Steps:**

1. **Verify Prerequisites**
   - Azure Data Factory v2 instance
   - Microsoft Fabric workspace with appropriate permissions
   - Contributor role on both ADF and Fabric workspace

2. **Configure ADF Mounting**

```json
{
  "name": "MountedADFConnection",
  "type": "AzureDataFactory",
  "properties": {
    "subscriptionId": "<azure-subscription-id>",
    "resourceGroup": "<adf-resource-group>",
    "factoryName": "<adf-factory-name>",
    "mountMode": "ReadWrite",
    "authentication": {
      "type": "UserAssignedManagedIdentity",
      "credential": {
        "referenceName": "fabric-managed-identity",
        "type": "CredentialReference"
      }
    }
  }
}
```

3. **Access Mounted Pipelines in Fabric**
   - Navigate to Fabric workspace → Data Factory section
   - View all ADF pipelines as native Fabric pipelines
   - Execute, monitor, and orchestrate alongside Fabric pipelines

**Benefits:**
- Zero code changes to existing ADF pipelines
- Single pane monitoring in Fabric
- Cross-platform orchestration capabilities
- Maintained ADF investment while adopting Fabric

### Scenario 2: Cross-Workspace Pipeline Orchestration

**When to Use:**
- Orchestrate pipelines across multiple Fabric workspaces
- Invoke ADF or Synapse pipelines from Fabric
- Need to work with Managed VNet secured workspaces

**Using Invoke Pipeline Activity (2025):**

```json
{
  "name": "InvokeCrossWorkspacePipeline",
  "type": "InvokePipeline",
  "typeProperties": {
    "pipelineReference": {
      "workspaceId": "<target-workspace-id>",
      "pipelineName": "<target-pipeline-name>",
      "platform": "Fabric"
    },
    "parameters": {
      "sourceData": "@pipeline().parameters.inputPath",
      "targetTable": "salesData"
    },
    "waitOnCompletion": true,
    "secureConnection": {
      "type": "ManagedVNet",
      "vnetReference": "<managed-vnet-name>"
    }
  },
  "linkedServiceName": {
    "referenceName": "FabricWorkspaceConnection",
    "type": "LinkedServiceReference"
  }
}
```

**Supported Platforms for Invoke Pipeline:**
- **Fabric**: Invoke Fabric Data Factory pipelines
- **AzureDataFactory**: Invoke Azure Data Factory v2 pipelines
- **Synapse**: Invoke Synapse Analytics pipelines

**Cross-Platform Orchestration Example:**

```json
{
  "name": "OrchestrationPipeline_Fabric",
  "activities": [
    {
      "name": "InvokeADFPipeline",
      "type": "InvokePipeline",
      "typeProperties": {
        "pipelineReference": {
          "platform": "AzureDataFactory",
          "subscriptionId": "<subscription-id>",
          "resourceGroup": "<rg-name>",
          "factoryName": "<adf-name>",
          "pipelineName": "DataIngestion"
        },
        "waitOnCompletion": true
      }
    },
    {
      "name": "InvokeSynapsePipeline",
      "type": "InvokePipeline",
      "dependsOn": [{"activity": "InvokeADFPipeline", "dependencyConditions": ["Succeeded"]}],
      "typeProperties": {
        "pipelineReference": {
          "platform": "Synapse",
          "workspaceId": "<synapse-workspace-id>",
          "pipelineName": "DataTransformation"
        },
        "waitOnCompletion": true
      }
    },
    {
      "name": "InvokeFabricPipeline",
      "type": "InvokePipeline",
      "dependsOn": [{"activity": "InvokeSynapsePipeline", "dependencyConditions": ["Succeeded"]}],
      "typeProperties": {
        "pipelineReference": {
          "platform": "Fabric",
          "workspaceId": "<fabric-workspace-id>",
          "pipelineName": "DataLoadToWarehouse"
        },
        "waitOnCompletion": false
      }
    }
  ]
}
```

**Benefits:**
- Unified orchestration across Microsoft data platforms
- Managed VNet support for secure cross-workspace communication
- Async or sync execution modes
- Centralized monitoring from Fabric

### Scenario 3: OneLake Connectivity from ADF

**When to Use:**
- Transfer data from external sources into Fabric OneLake
- Leverage Fabric's unified storage layer
- Enable seamless data access across Fabric workloads

**Fabric Lakehouse Linked Service:**

```json
{
  "name": "FabricLakehouseConnection",
  "properties": {
    "type": "Lakehouse",
    "typeProperties": {
      "workspaceId": "<fabric-workspace-id>",
      "artifactId": "<lakehouse-artifact-id>",
      "authenticationType": "UserAssignedManagedIdentity",
      "credential": {
        "referenceName": "fabric-uami-credential",
        "type": "CredentialReference"
      }
    },
    "connectVia": {
      "referenceName": "AutoResolveIntegrationRuntime",
      "type": "IntegrationRuntimeReference"
    }
  }
}
```

**Fabric Warehouse Linked Service:**

```json
{
  "name": "FabricWarehouseConnection",
  "properties": {
    "type": "Warehouse",
    "typeProperties": {
      "endpoint": "<fabric-warehouse-endpoint>",
      "workspaceId": "<fabric-workspace-id>",
      "artifactId": "<warehouse-artifact-id>",
      "authenticationType": "SystemAssignedManagedIdentity"
    },
    "connectVia": {
      "referenceName": "AutoResolveIntegrationRuntime",
      "type": "IntegrationRuntimeReference"
    }
  }
}
```

**Copy Data to OneLake Pipeline:**

```json
{
  "name": "CopyToOneLake",
  "activities": [
    {
      "name": "CopyToLakehouse",
      "type": "Copy",
      "inputs": [
        {
          "referenceName": "SourceAzureBlobDataset",
          "type": "DatasetReference"
        }
      ],
      "outputs": [
        {
          "referenceName": "FabricLakehouseDataset",
          "type": "DatasetReference"
        }
      ],
      "typeProperties": {
        "source": {
          "type": "BinarySource",
          "storeSettings": {
            "type": "AzureBlobStorageReadSettings",
            "recursive": true
          }
        },
        "sink": {
          "type": "BinarySink",
          "storeSettings": {
            "type": "LakehouseWriteSettings",
            "copyBehavior": "PreserveHierarchy",
            "metadata": [
              {
                "name": "sourceSystem",
                "value": "AzureBlob"
              },
              {
                "name": "loadTimestamp",
                "value": "$$LASTMODIFIED"
              }
            ]
          }
        }
      }
    }
  ]
}
```

**Native Staging with OneLake:**

```json
{
  "name": "CopyWithOneLakeStaging",
  "activities": [
    {
      "name": "CopyFromOnPremToSnowflake",
      "type": "Copy",
      "typeProperties": {
        "source": {
          "type": "SqlServerSource"
        },
        "sink": {
          "type": "SnowflakeSink"
        },
        "enableStaging": true,
        "stagingSettings": {
          "linkedServiceName": {
            "referenceName": "FabricOneLakeStaging",
            "type": "LinkedServiceReference"
          },
          "path": "staging/temp",
          "enableCompression": true
        }
      }
    }
  ]
}
```

**Benefits:**
- Unified storage across Fabric workloads
- Zero-copy access with OneLake shortcuts
- Open Delta Parquet format
- Automatic metadata management

### Scenario 4: Variable Libraries for CI/CD

**When to Use:**
- Deploy pipelines across multiple Fabric environments
- Need environment-specific configuration values
- Simplify parameter management during promotion

**Configure Variable Libraries:**

1. **Create Variable Library in Fabric**

```json
{
  "name": "PipelineVariables",
  "description": "Environment-specific variables for data pipelines",
  "variables": [
    {
      "key": "sourceConnectionString",
      "environments": {
        "dev": "Server=dev-sql.database.windows.net;...",
        "test": "Server=test-sql.database.windows.net;...",
        "prod": "Server=prod-sql.database.windows.net;..."
      }
    },
    {
      "key": "storageAccountName",
      "environments": {
        "dev": "devstorageaccount",
        "test": "teststorageaccount",
        "prod": "prodstorageaccount"
      }
    },
    {
      "key": "oneLakePath",
      "environments": {
        "dev": "/workspaces/dev-workspace/lakehouses/dev-lakehouse",
        "test": "/workspaces/test-workspace/lakehouses/test-lakehouse",
        "prod": "/workspaces/prod-workspace/lakehouses/prod-lakehouse"
      }
    }
  ]
}
```

2. **Reference Variables in Pipelines**

```json
{
  "name": "DataIngestionPipeline",
  "parameters": {
    "sourceConnection": {
      "type": "string",
      "defaultValue": "@variables('sourceConnectionString')"
    },
    "targetPath": {
      "type": "string",
      "defaultValue": "@variables('oneLakePath')"
    }
  }
}
```

3. **Automatic Value Substitution During Deployment**

When promoting pipeline from dev → test → prod, Fabric automatically:
- Detects current environment
- Substitutes variable values from library
- No manual parameter file updates required

**Benefits:**
- Eliminates separate parameter files per environment
- Automatic variable substitution during promotion
- Centralized configuration management
- Reduced deployment errors

## Security and Permissions

### Required Permissions for Mounting

**Azure Data Factory:**
- Data Factory Contributor role
- Reader role on resource group

**Microsoft Fabric:**
- Workspace Admin or Contributor role
- Permission to create connections

### Managed Identity Configuration

**System-Assigned Managed Identity:**
```json
{
  "authenticationType": "SystemAssignedManagedIdentity"
}
```

**User-Assigned Managed Identity (Recommended for cross-workspace):**
```json
{
  "authenticationType": "UserAssignedManagedIdentity",
  "credential": {
    "referenceName": "<credential-name>",
    "type": "CredentialReference"
  }
}
```

**Grant Permissions:**
- Fabric workspace: Admin or Contributor
- OneLake storage: Storage Blob Data Contributor
- SQL endpoints: db_datareader, db_datawriter

### Managed VNet Configuration

**Enable Managed VNet for Secure Communication:**

```json
{
  "secureConnection": {
    "type": "ManagedVNet",
    "vnetReference": "<vnet-name>",
    "privateEndpoints": [
      {
        "name": "fabric-workspace-pe",
        "resourceId": "<workspace-resource-id>"
      }
    ]
  }
}
```

## Monitoring and Troubleshooting

### Monitor Cross-Workspace Pipelines

**From Fabric Workspace:**
- Navigate to Monitoring → Pipeline runs
- View runs across all invoked platforms (Fabric, ADF, Synapse)
- Drill down into specific activity execution details

**Common Issues:**

1. **Authentication Failures**
   - **Error**: "Failed to authenticate to target workspace"
   - **Solution**: Verify managed identity has permissions on target workspace
   - **Check**: Azure Portal → Fabric workspace → Access control (IAM)

2. **Mounted ADF Not Visible**
   - **Error**: "ADF pipelines not appearing in Fabric"
   - **Solution**: Ensure mounting configuration is correct and connection is active
   - **Check**: Fabric workspace → Settings → External connections

3. **Variable Library Not Resolving**
   - **Error**: "Variable 'variableName' not found"
   - **Solution**: Verify variable library is published and assigned to workspace
   - **Check**: Fabric workspace → Settings → Variable libraries

4. **OneLake Permission Denied**
   - **Error**: "Access denied to OneLake path"
   - **Solution**: Grant Storage Blob Data Contributor role to managed identity
   - **Check**: OneLake storage → Access control

## Best Practices

### 1. Start with Mounting for Existing ADF
- Mount first to validate connectivity
- Test pipelines in Fabric environment
- Gradually adopt Fabric-native features

### 2. Use User-Assigned Managed Identity for Multi-Workspace
- Single identity across multiple workspaces
- Easier permission management
- Better for cross-workspace orchestration

### 3. Leverage Variable Libraries from Day 1
- Avoid hardcoded environment-specific values
- Design pipelines with variables from start
- Simplifies future CI/CD automation

### 4. Design for Cross-Platform Orchestration
- Use Invoke Pipeline for modular architecture
- Keep platform-specific logic in respective pipelines
- Centralize orchestration in Fabric

### 5. OneLake as Unified Landing Zone
- Route all data to OneLake first
- Use shortcuts to avoid data duplication
- Leverage Fabric workloads (Warehouse, Lakehouse, Power BI) seamlessly

## Migration Strategies

### Strategy 1: Lift-and-Shift (Mounting)
- **Timeframe**: Days
- **Effort**: Low
- **Approach**: Mount existing ADF in Fabric, no code changes

### Strategy 2: Hybrid Approach
- **Timeframe**: Weeks to Months
- **Effort**: Medium
- **Approach**: Mount ADF, gradually migrate critical pipelines to Fabric-native

### Strategy 3: Greenfield Fabric
- **Timeframe**: Months
- **Effort**: High
- **Approach**: Rebuild pipelines as Fabric-native, leverage all modern features

## Resources

**Microsoft Learn:**
- Fabric Data Factory: https://learn.microsoft.com/en-us/fabric/data-factory/
- ADF Mounting: https://learn.microsoft.com/en-us/fabric/data-factory/azure-data-factory-mounting
- OneLake Connectivity: https://learn.microsoft.com/en-us/fabric/onelake/onelake-overview

**Context7 Library:**
- Library ID: `/websites/learn_microsoft_en-us_fabric_data-factory`

This integration enables a seamless journey from Azure Data Factory to Microsoft Fabric's unified data platform while preserving existing investments and enabling modern capabilities.
