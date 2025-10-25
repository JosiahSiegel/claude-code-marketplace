---
description: Execute Azure CLI commands with expert guidance and best practices
---

# Azure CLI Command

Get expert assistance with Azure CLI commands, syntax, authentication, and automation.

## Purpose

This command provides comprehensive Azure CLI guidance, including:
- Command syntax and parameters
- Authentication methods
- Resource management
- Query optimization (JMESPath)
- Scripting and automation
- Error handling
- Cross-platform compatibility

## Instructions

When this command is invoked:

1. **Fetch Latest Documentation**:
   - Always research the latest Azure CLI documentation first
   - Use WebFetch to get current command syntax and best practices

2. **Understand the Request**:
   - Clarify which Azure service or operation is needed
   - Identify the target environment (dev, staging, production)
   - Determine if this is for interactive use or automation

3. **Provide Complete Guidance**:
   - Show the full command with all required parameters
   - Include common optional parameters
   - Explain each parameter's purpose
   - Show expected output format

4. **Include Best Practices**:
   - Add error handling for scripts
   - Show idempotent patterns when applicable
   - Include security considerations (no hardcoded credentials)
   - Provide cross-platform examples when needed

5. **Offer Related Commands**:
   - Show verification commands
   - Suggest related operations
   - Include query examples for filtering results

## Examples

### Example 1: Create Resource Group
```bash
# Create resource group
az group create \
  --name MyResourceGroup \
  --location eastus \
  --tags Environment=Production CostCenter=IT

# Verify creation
az group show --name MyResourceGroup --output table
```

### Example 2: VM Management with Error Handling
```bash
# Check if VM exists
if az vm show --resource-group MyRG --name MyVM &>/dev/null; then
    echo "VM exists, starting..."
    az vm start --resource-group MyRG --name MyVM --no-wait
else
    echo "VM does not exist, creating..."
    az vm create \
        --resource-group MyRG \
        --name MyVM \
        --image Ubuntu2204 \
        --size Standard_D2s_v3 \
        --generate-ssh-keys
fi
```

### Example 3: Query and Filter
```bash
# List running VMs in specific location
az vm list \
  --query "[?powerState=='VM running' && location=='eastus'].{Name:name, Size:hardwareProfile.vmSize, ResourceGroup:resourceGroup}" \
  --output table

# Get VM IDs for scripting
vmIds=$(az vm list --query "[].id" --output tsv)
```

## Tips

- Use `--output table` for human-readable output
- Use `--output tsv` for scripting and parsing
- Use `--query` with JMESPath for filtering results
- Use `--no-wait` for async operations
- Use `--debug` for troubleshooting
- Always test commands in dev environment first
