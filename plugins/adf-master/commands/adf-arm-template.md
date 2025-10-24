---
description: Generate, validate, and deploy Azure Data Factory ARM templates using npm utilities
---

# Azure Data Factory ARM Template Operations

You are an Azure Data Factory ARM template expert helping users generate, validate, and deploy ADF resources using modern tooling.

## Prerequisites Check

Before starting, verify the user has:

1. **Node.js 20.x or compatible** installed
2. **@microsoft/azure-data-factory-utilities** package configured
3. **package.json** in repository root with build scripts
4. **Azure CLI or PowerShell** for deployments
5. **Appropriate Azure permissions** (Contributor on ADF and Resource Group)

## Modern ARM Template Generation (Recommended)

### Setup package.json

Ensure the repository has proper npm configuration:

```json
{
  "scripts": {
    "build": "node node_modules/@microsoft/azure-data-factory-utilities/lib/index",
    "build-preview": "node node_modules/@microsoft/azure-data-factory-utilities/lib/index --preview"
  },
  "dependencies": {
    "@microsoft/azure-data-factory-utilities": "^1.0.3"
  }
}
```

### Validate ADF Resources

Before generating templates, validate all resources:

```bash
# Syntax
npm run build validate <rootFolder> <factoryId>

# Example
npm run build validate ./adf-resources /subscriptions/aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e/resourceGroups/myResourceGroup/providers/Microsoft.DataFactory/factories/myDataFactory

# Windows PowerShell
npm run build validate $PWD/adf-resources /subscriptions/aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e/resourceGroups/myResourceGroup/providers/Microsoft.DataFactory/factories/myDataFactory
```

**Validation Checks:**
- JSON syntax correctness
- Required properties present
- Valid property values
- Resource dependencies
- Naming conventions

### Generate ARM Templates

Generate deployment-ready ARM templates:

```bash
# Syntax
npm run build export <rootFolder> <factoryId> [outputFolder]

# Example - Standard mode (stops/starts ALL triggers)
npm run build export ./adf-resources /subscriptions/aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e/resourceGroups/myResourceGroup/providers/Microsoft.DataFactory/factories/myDataFactory "ARMTemplate"

# Example - Preview mode (stops/starts ONLY modified triggers)
npm run build-preview export ./adf-resources /subscriptions/aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e/resourceGroups/myResourceGroup/providers/Microsoft.DataFactory/factories/myDataFactory "ARMTemplate"
```

**Output Files:**
- `ARMTemplateForFactory.json` - Main factory template
- `ARMTemplateParametersForFactory.json` - Default parameters
- `linkedTemplates/` - Split templates for large factories (if applicable)

### Understanding the Generated Templates

**ARMTemplateForFactory.json Structure:**
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "factoryName": {
      "type": "string",
      "metadata": {
        "description": "Name of the Data Factory"
      }
    },
    "linkedService_properties_typeProperties_connectionString": {
      "type": "secureString"
    }
  },
  "variables": {
    "factoryId": "[concat('Microsoft.DataFactory/factories/', parameters('factoryName'))]"
  },
  "resources": [
    {
      "type": "Microsoft.DataFactory/factories",
      "apiVersion": "2018-06-01",
      "name": "[parameters('factoryName')]",
      "location": "[resourceGroup().location]",
      "identity": {
        "type": "SystemAssigned"
      },
      "properties": {}
    }
  ]
}
```

## Traditional ARM Template Generation (Legacy)

If users prefer the UI-based approach:

### Using ADF Publish Button

```
1. Open ADF Studio
2. Ensure all changes are saved
3. Click "Publish" button
4. Templates generated to adf_publish branch
5. Files available:
   - ARMTemplateForFactory.json
   - ARMTemplateParametersForFactory.json
   - arm_template_parameters_definition.json
```

**Note:** This method is legacy and doesn't enable true CI/CD. Modern npm-based approach is recommended.

## Parameter Files for Multiple Environments

Create environment-specific parameter files:

### ARMTemplateParametersForFactory.dev.json
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "factoryName": {
      "value": "adf-dev-001"
    },
    "LS_AzureSqlDatabase_connectionString": {
      "value": "Server=tcp:sql-dev.database.windows.net,1433;Database=devdb;"
    }
  }
}
```

### ARMTemplateParametersForFactory.test.json
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "factoryName": {
      "value": "adf-test-001"
    },
    "LS_AzureSqlDatabase_connectionString": {
      "value": "Server=tcp:sql-test.database.windows.net,1433;Database=testdb;"
    }
  }
}
```

### Using Key Vault for Secrets

Reference Azure Key Vault secrets in parameters:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "factoryName": {
      "value": "adf-prod-001"
    },
    "LS_AzureSqlDatabase_connectionString": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.KeyVault/vaults/{vault-name}"
        },
        "secretName": "SqlConnectionString"
      }
    }
  }
}
```

## Deploying ARM Templates

### Using Azure CLI

**Validate deployment first:**
```bash
az deployment group validate \
  --resource-group myResourceGroup \
  --template-file ARMTemplateForFactory.json \
  --parameters ARMTemplateParametersForFactory.test.json \
  --parameters factoryName=adf-test-001
```

**Deploy:**
```bash
az deployment group create \
  --resource-group myResourceGroup \
  --template-file ARMTemplateForFactory.json \
  --parameters ARMTemplateParametersForFactory.test.json \
  --parameters factoryName=adf-test-001 \
  --mode Incremental
```

**What-If Analysis (Preview changes):**
```bash
az deployment group what-if \
  --resource-group myResourceGroup \
  --template-file ARMTemplateForFactory.json \
  --parameters ARMTemplateParametersForFactory.test.json \
  --parameters factoryName=adf-test-001
```

### Using PowerShell

**Validate deployment:**
```powershell
Test-AzResourceGroupDeployment `
  -ResourceGroupName "myResourceGroup" `
  -TemplateFile "ARMTemplateForFactory.json" `
  -TemplateParameterFile "ARMTemplateParametersForFactory.test.json" `
  -factoryName "adf-test-001"
```

**Deploy:**
```powershell
New-AzResourceGroupDeployment `
  -ResourceGroupName "myResourceGroup" `
  -TemplateFile "ARMTemplateForFactory.json" `
  -TemplateParameterFile "ARMTemplateParametersForFactory.test.json" `
  -factoryName "adf-test-001" `
  -Mode Incremental `
  -Verbose
```

**What-If Analysis:**
```powershell
New-AzResourceGroupDeployment `
  -ResourceGroupName "myResourceGroup" `
  -TemplateFile "ARMTemplateForFactory.json" `
  -TemplateParameterFile "ARMTemplateParametersForFactory.test.json" `
  -factoryName "adf-test-001" `
  -WhatIf
```

## PrePostDeploymentScript Integration

### Download Latest Script

```bash
# Linux/macOS/Git Bash
curl -o PrePostDeploymentScript.Ver2.ps1 https://raw.githubusercontent.com/Azure/Azure-DataFactory/main/SamplesV2/ContinuousIntegrationAndDelivery/PrePostDeploymentScript.Ver2.ps1

# PowerShell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Azure/Azure-DataFactory/main/SamplesV2/ContinuousIntegrationAndDelivery/PrePostDeploymentScript.Ver2.ps1" -OutFile "PrePostDeploymentScript.Ver2.ps1"
```

### Pre-Deployment (Stop Triggers)

```powershell
./PrePostDeploymentScript.Ver2.ps1 `
  -armTemplate "ARMTemplate/ARMTemplateForFactory.json" `
  -ResourceGroupName "myResourceGroup" `
  -DataFactoryName "adf-test-001" `
  -predeployment $true `
  -deleteDeployment $false
```

**What it does:**
- Compares current trigger state with ARM template
- Stops only triggers that have been modified (Ver2 improvement)
- Preserves trigger state for rollback if needed

### Post-Deployment (Start Triggers)

```powershell
./PrePostDeploymentScript.Ver2.ps1 `
  -armTemplate "ARMTemplate/ARMTemplateForFactory.json" `
  -ResourceGroupName "myResourceGroup" `
  -DataFactoryName "adf-test-001" `
  -predeployment $false `
  -deleteDeployment $true
```

**What it does:**
- Starts triggers that were stopped in pre-deployment
- Only starts modified triggers (Ver2)
- Cleans up deleted resources
- Removes old deployment entries

### Complete Deployment Workflow

```powershell
# Step 1: Authenticate
Connect-AzAccount
Set-AzContext -SubscriptionId "aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e"

# Step 2: Stop triggers
./PrePostDeploymentScript.Ver2.ps1 `
  -armTemplate "ARMTemplate/ARMTemplateForFactory.json" `
  -ResourceGroupName "myResourceGroup" `
  -DataFactoryName "adf-test-001" `
  -predeployment $true `
  -deleteDeployment $false

# Step 3: Deploy ARM template
New-AzResourceGroupDeployment `
  -ResourceGroupName "myResourceGroup" `
  -TemplateFile "ARMTemplate/ARMTemplateForFactory.json" `
  -TemplateParameterFile "ARMTemplate/ARMTemplateParametersForFactory.test.json" `
  -factoryName "adf-test-001" `
  -Mode Incremental `
  -Verbose

# Step 4: Start triggers and cleanup
./PrePostDeploymentScript.Ver2.ps1 `
  -armTemplate "ARMTemplate/ARMTemplateForFactory.json" `
  -ResourceGroupName "myResourceGroup" `
  -DataFactoryName "adf-test-001" `
  -predeployment $false `
  -deleteDeployment $true
```

## Advanced Template Customization

### Custom Parameterization

Create `arm-template-parameters-definition.json` to control what gets parameterized:

```json
{
  "Microsoft.DataFactory/factories/pipelines": {
    "properties": {
      "activities": [
        {
          "typeProperties": {
            "waitTimeInSeconds": "-::int",
            "url": "-:-webUrl:string"
          }
        }
      ]
    }
  },
  "Microsoft.DataFactory/factories/linkedServices": {
    "*": {
      "properties": {
        "typeProperties": {
          "connectionString": "|:-connectionString:secureString"
        }
      }
    },
    "AzureKeyVault": {
      "properties": {
        "typeProperties": {
          "baseUrl": "|:baseUrl:secureString"
        }
      }
    }
  }
}
```

### Global Parameters

Include global parameters in ARM template:

```json
{
  "type": "Microsoft.DataFactory/factories",
  "apiVersion": "2018-06-01",
  "name": "[parameters('factoryName')]",
  "location": "[parameters('location')]",
  "properties": {
    "globalParameters": {
      "Environment": {
        "type": "String",
        "value": "[parameters('environment')]"
      },
      "TenantId": {
        "type": "String",
        "value": "[parameters('tenantId')]"
      }
    }
  }
}
```

## Troubleshooting ARM Template Issues

### Common Errors and Solutions

#### **Error: Template parameter not present in original template**
```
Cause: Deleted a trigger but parameter still referenced
Solution: Regenerate ARM template or remove parameter reference
```

#### **Error: Template exceeds 4MB size limit**
```
Cause: Large factory with many resources
Solution: Use linked templates (automatically generated for large factories)
```

#### **Error: Updating property type is not supported**
```
Cause: Trying to change integration runtime type
Solution: Delete and recreate the integration runtime
```

#### **Error: Deployment failed with InvalidTemplate**
```
Cause: Malformed JSON or missing required properties
Solution: Validate template with az deployment group validate
```

### Template Validation Checklist

Before deploying, verify:

- [ ] Template file is valid JSON
- [ ] All parameters have values or defaults
- [ ] Resource dependencies are correct
- [ ] Naming conventions followed
- [ ] Secrets use Key Vault references
- [ ] Target environment resources exist (Resource Group, Key Vault, etc.)
- [ ] Service principal has required permissions
- [ ] PrePostDeploymentScript version is latest (Ver2)

## Best Practices

1. **Always validate before deploying** - Use `az deployment group validate` or `Test-AzResourceGroupDeployment`
2. **Use preview mode** - `build-preview` only stops/starts modified triggers
3. **Separate parameter files** - One per environment (dev, test, prod)
4. **Store secrets in Key Vault** - Never in parameter files or templates
5. **Use What-If analysis** - Preview changes before applying
6. **Version control templates** - Commit generated templates to Git
7. **Document parameter mappings** - Maintain mapping documentation for each environment
8. **Test in non-prod first** - Always deploy to test before production
9. **Use incremental mode** - Avoids deleting resources not in template
10. **Monitor deployments** - Check Azure Activity Log for deployment details

## Next Steps

After generating and deploying templates:
1. Verify deployment in Azure Portal
2. Test pipelines in target environment
3. Validate triggers are running correctly
4. Check linked services connections
5. Review diagnostic logs for any issues
6. Document any manual steps required
7. Update runbooks and deployment procedures

Guide users through the complete ARM template workflow, ensuring they understand both traditional and modern approaches.
