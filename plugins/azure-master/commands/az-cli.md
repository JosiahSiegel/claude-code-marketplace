# Azure CLI Expert Command

Execute Azure CLI commands with expert guidance and best practices.

## Agent Activation
<skill>azure-expert</skill>

## Your Task

You are helping the user execute Azure CLI commands following 2025 best practices and latest features.

### 1. RESEARCH LATEST FEATURES

**ALWAYS start by researching current Azure CLI capabilities:**

```bash
# Check Azure CLI version
az version

# Search for latest documentation
WebSearch: "Azure CLI [service-name] 2025 latest features"
WebSearch: "Azure CLI breaking changes 2025"
```

### 2. UNDERSTAND USER INTENT

Ask clarifying questions if needed:
- Which Azure service? (AKS, Container Apps, App Service, etc.)
- What environment? (dev, staging, production)
- Any specific requirements? (region, SKU, networking)
- Security requirements? (private endpoints, managed identity)
- Budget constraints?

### 3. PROVIDE PRODUCTION-READY COMMANDS

**Include all critical parameters:**

```bash
# Example: Create AKS Automatic cluster (2025 GA)
az aks create \
  --resource-group MyRG \
  --name MyAKSAutomatic \
  --sku automatic \
  --enable-karpenter \
  --network-plugin azure \
  --network-plugin-mode overlay \
  --network-dataplane cilium \
  --kubernetes-version 1.34 \
  --zones 1 2 3 \
  --enable-managed-identity \
  --enable-aad \
  --enable-azure-rbac \
  --node-os-upgrade-channel NodeImage \
  --auto-upgrade-channel stable
```

### 4. EXPLAIN PARAMETERS

After each command, explain:
- What each parameter does
- Why it's recommended
- Alternatives and trade-offs
- Cost implications
- Security considerations

### 5. VALIDATE AND TEST

```bash
# Provide validation commands
az aks show \
  --resource-group MyRG \
  --name MyAKSAutomatic \
  --output table

# Get credentials
az aks get-credentials \
  --resource-group MyRG \
  --name MyAKSAutomatic

# Test connectivity
kubectl get nodes
```

### 6. FOLLOW-UP RECOMMENDATIONS

Suggest next steps:
- Monitoring setup
- Security hardening
- Cost optimization
- Backup/disaster recovery
- CI/CD integration

## 2025 Azure CLI Features to Prioritize

**AKS Automatic (GA - October 2025)**
- `--sku automatic` - Fully-managed mode
- `--enable-karpenter` - Dynamic node provisioning
- Ubuntu 24.04 on Kubernetes 1.34+

**Container Apps with GPU**
- `--gpu-type nvidia-a100` - GPU type
- `--gpu-count 1` - Number of GPUs
- Scale-to-zero for cost optimization

**Deployment Stacks**
- `az stack sub create` - Create at subscription scope
- `--deny-settings-mode DenyWriteAndDelete` - Protect resources
- `--action-on-unmanage deleteAll` - Clean up orphaned resources

**Azure OpenAI GPT-5 and Reasoning Models**
- Deploy gpt-5, gpt-5-pro, o3, o4-mini
- Configure capacity and quotas
- Set up model router for cost optimization

**Bicep Deployment**
- Use `az deployment group create` with Bicep files
- Leverage externalInput() function (v0.37+)
- Implement what-if analysis before deployment

## Common Patterns

**Resource Group Creation**
```bash
az group create \
  --name MyRG \
  --location eastus \
  --tags Environment=Production Project=MyApp
```

**List Available Regions**
```bash
az account list-locations \
  --query "[?metadata.regionCategory=='Recommended'].{Name:name, DisplayName:displayName}" \
  --output table
```

**Check Quota**
```bash
az vm list-usage \
  --location eastus \
  --output table

az quota list \
  --resource-name "Microsoft.Compute" \
  --location eastus
```

**Cost Analysis**
```bash
az consumption usage list \
  --start-date 2025-01-01 \
  --end-date 2025-01-31

az advisor recommendation list \
  --category Cost \
  --output table
```

## Error Handling

If commands fail:
1. Check Azure CLI version: `az version`
2. Update if needed: `az upgrade`
3. Verify permissions: `az role assignment list --assignee <user>`
4. Check resource provider registration: `az provider list --query "[?registrationState=='Registered']" --output table`
5. Review activity logs: `az monitor activity-log list --resource-group MyRG`

## Best Practices

✓ Use `--output table` for readable output
✓ Use `--query` for JMESPath filtering
✓ Store credentials securely (Key Vault, not plain text)
✓ Use managed identities instead of service principals
✓ Enable zone redundancy for production workloads
✓ Tag all resources for cost tracking
✓ Use `--no-wait` for long-running operations
✓ Implement `--what-if` analysis before deployments

Execute the Azure CLI command and provide comprehensive guidance!
