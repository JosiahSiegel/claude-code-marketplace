---
description: Deploy Azure resources using ARM templates, Bicep, or Terraform with best practices
---

# Azure Deploy Command

Get expert guidance on deploying Azure resources using infrastructure-as-code (ARM, Bicep, Terraform).

## Purpose

This command assists with:
- ARM template deployment
- Bicep infrastructure deployment
- Terraform Azure provider deployments
- Validation and what-if analysis
- Parameter file management
- Multi-environment deployments
- CI/CD integration

## Instructions

When this command is invoked:

1. **Identify the IaC Tool**:
   - Determine if using ARM, Bicep, or Terraform
   - Check for existing templates or modules
   - Understand the deployment scope (resource group, subscription, etc.)

2. **Validate Before Deploy**:
   - Always run validation first
   - Use what-if analysis (ARM/Bicep) or plan (Terraform)
   - Review expected changes

3. **Provide Complete Deployment Commands**:
   - Include all required parameters
   - Show parameter file usage
   - Add deployment mode (incremental/complete)
   - Include output retrieval

4. **Include Error Handling**:
   - Check for successful deployment
   - Show rollback procedures if needed
   - Provide troubleshooting commands

5. **Security Best Practices**:
   - Never hardcode secrets
   - Use Key Vault references
   - Use secure parameters
   - Implement RBAC

## Examples

### Example 1: Bicep Deployment
```bash
# Validate template
az deployment group validate \
  --resource-group MyRG \
  --template-file main.bicep \
  --parameters @parameters.json

# Preview changes (what-if)
az deployment group what-if \
  --resource-group MyRG \
  --template-file main.bicep \
  --parameters @parameters.json

# Deploy
az deployment group create \
  --name MyDeployment \
  --resource-group MyRG \
  --template-file main.bicep \
  --parameters @parameters.json \
  --mode Incremental

# Get outputs
az deployment group show \
  --name MyDeployment \
  --resource-group MyRG \
  --query properties.outputs
```

### Example 2: Terraform Deployment
```bash
# Initialize
terraform init

# Format and validate
terraform fmt
terraform validate

# Plan with specific var file
terraform plan \
  -var-file="environments/prod.tfvars" \
  -out=tfplan

# Review plan
terraform show tfplan

# Apply if approved
terraform apply tfplan

# Get outputs
terraform output
```

### Example 3: ARM Template with Key Vault Secret
```json
{
  "parameters": {
    "adminPassword": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/{subscription-id}/resourceGroups/{rg}/providers/Microsoft.KeyVault/vaults/{vault-name}"
        },
        "secretName": "vmAdminPassword"
      }
    }
  }
}
```

## Best Practices

- **Always validate** before deploying
- **Use what-if/plan** to preview changes
- **Version control** all IaC code
- **Test in dev** environment first
- **Use parameter files** for environment-specific values
- **Implement CI/CD** for automated deployments
- **Monitor deployments** with Azure Monitor
- **Document** deployment procedures

## Troubleshooting

Common issues:
1. **Validation failures**: Check template syntax, API versions
2. **Permission denied**: Verify RBAC assignments
3. **Resource conflicts**: Check for existing resources, naming
4. **Quota exceeded**: Request quota increase or use different region
5. **Dependency errors**: Review resource dependencies, deployment order
