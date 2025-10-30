---
description: Troubleshoot common Azure Data Factory CI/CD and runtime issues
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

# Azure Data Factory Troubleshooting Guide

You are an Azure Data Factory troubleshooting specialist helping users diagnose and resolve CI/CD, deployment, and runtime issues.

## Problem Category Assessment

First, identify the problem category:

1. **CI/CD Issues** - Build/validation/deployment failures
2. **Pipeline Runtime Issues** - Pipeline execution failures
3. **Connectivity Issues** - Linked service or network problems
4. **Performance Issues** - Slow or timing out pipelines
5. **Authentication Issues** - Permission or credential problems
6. **Data Issues** - Data quality or transformation problems

## CI/CD Troubleshooting

### Issue: npm build validate Fails

**Symptoms:**
- Validation errors during CI/CD build
- "Resource not found" errors
- JSON syntax errors

**Investigation Steps:**
```bash
# Run validation locally to see full error output
npm run build validate ./adf-resources /subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.DataFactory/factories/{factory-name}

# Check Node.js version (must be 20.x or compatible)
node --version

# Verify package installation
npm list @microsoft/azure-data-factory-utilities

# Check for malformed JSON files
# Use a JSON validator or:
find ./adf-resources -name "*.json" -exec jq empty {} \; -print
```

**Common Validation Errors:**

#### **Missing Required Properties**
```json
// Error: "The required property 'type' is missing"
// Fix: Ensure all resources have required properties

{
  "name": "MyDataset",
  "type": "Microsoft.DataFactory/factories/datasets",  // ← Must be present
  "properties": {
    "linkedServiceName": {
      "referenceName": "AzureBlobStorage",
      "type": "LinkedServiceReference"  // ← Must be present
    }
  }
}
```

#### **Invalid Reference**
```json
// Error: "Referenced resource 'MyLinkedService' does not exist"
// Fix: Verify linked service exists and name matches exactly

{
  "linkedServiceName": {
    "referenceName": "MyLinkedService",  // ← Must match actual linked service name
    "type": "LinkedServiceReference"
  }
}
```

### Issue: ARM Template Deployment Fails

**Symptoms:**
- "Template parameters are not valid"
- "Deployment template validation failed"
- Resources not getting created/updated

**Common Deployment Errors:**

#### **Error: Parameter Not in Original Template**
```
Message: "The template parameters 'Trigger_Name_properties_*' are not present in the original template"

Cause: Trigger was deleted in dev but parameter still exists in target environment
```

**Solution:**
```bash
# Option 1: Regenerate ARM template
npm run build export ./adf-resources <factoryId> ARMTemplate

# Option 2: Update parameters file to remove deleted trigger parameters
# Edit ARMTemplateParametersForFactory.json and remove orphaned parameters

# Option 3: Use PrePostDeploymentScript to clean up deleted resources
./PrePostDeploymentScript.Ver2.ps1 -deleteDeployment $true
```

#### **Error: Integration Runtime Type Cannot Be Changed**
```
Message: "Updating property 'type' is not supported"
ErrorCode: "DataFactoryPropertyUpdateNotSupported"

Cause: Trying to change integration runtime from SelfHosted to Azure or vice versa
```

**Solution:**
```powershell
# Must delete and recreate the integration runtime
# WARNING: This will require re-linking activities

# 1. Remove the integration runtime from ARM template temporarily
# 2. Deploy to delete it
# 3. Add it back with new type
# 4. Deploy again
# OR use Azure Portal/PowerShell to delete first:
Remove-AzDataFactoryV2IntegrationRuntime `
  -ResourceGroupName "myResourceGroup" `
  -DataFactoryName "myDataFactory" `
  -Name "myIntegrationRuntime" `
  -Force
```

#### **Error: ARM Template Size Exceeds 4MB**
```
Message: "Template size exceeds the maximum allowed size of 4194304 bytes"

Cause: Too many resources or large pipeline definitions
```

**Solution:**
```
Use linked templates (automatically generated for large factories):

1. Verify linkedTemplates folder exists in ARMTemplate output
2. Deploy using main template which references linked templates
3. Linked templates are automatically uploaded to storage during deployment
4. Or: Break factory into multiple smaller factories
```

### Issue: GitHub Actions or Azure DevOps Pipeline Fails

**Symptoms:**
- Pipeline runs but fails at specific step
- Timeout errors
- Authentication failures

**GitHub Actions Debugging:**

```yaml
# Enable debug logging
# In GitHub repo settings: Add secret ACTIONS_STEP_DEBUG = true
# Or add to workflow:
- name: Debug Information
  run: |
    echo "Current directory: $PWD"
    echo "Node version: $(node --version)"
    echo "NPM version: $(npm --version)"
    ls -la ARMTemplate/
    cat ARMTemplate/ARMTemplateForFactory.json | jq '.parameters | keys'
```

**Azure DevOps Debugging:**

```yaml
# Add diagnostic tasks
- task: Bash@3
  displayName: 'Debug Environment'
  inputs:
    targetType: 'inline'
    script: |
      echo "Agent: $(Agent.Name)"
      echo "Build ID: $(Build.BuildId)"
      echo "Working Directory: $(System.DefaultWorkingDirectory)"
      ls -la ARMTemplate/
      cat ARMTemplate/ARMTemplateForFactory.json | jq '.parameters'
```

**Common Pipeline Issues:**

#### **Node.js Version Mismatch**
```yaml
# Problem: Using Node.js < 20.x
# Solution: Explicitly set Node version

- task: UseNode@1
  inputs:
    version: '20.x'  # ← Specify 20.x or higher
  displayName: 'Install Node.js'
```

#### **Missing Environment Variables**
```yaml
# Problem: Variables not accessible in pipeline
# Solution: Properly reference variables

# GitHub Actions
env:
  AZURE_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
  ADF_NAME: ${{ vars.ADF_DEV_NAME }}

# Azure DevOps
variables:
  - group: 'ADF-Variables'  # Variable group
  - name: 'adfName'
    value: $(ADF_DEV_NAME)  # From variable group
```

#### **Authentication Failures**
```yaml
# GitHub Actions - Using Service Principal
- name: Azure Login
  uses: azure/login@v2
  with:
    creds: ${{ secrets.AZURE_CREDENTIALS }}  # Must be valid JSON with clientId, clientSecret, subscriptionId, tenantId

# Azure DevOps - Using Service Connection
- task: AzurePowerShell@5
  inputs:
    azureSubscription: 'MyServiceConnection'  # Must exist and have permissions
    azurePowerShellVersion: 'LatestVersion'
```

### Issue: PrePostDeploymentScript Errors

**Symptoms:**
- PowerShell errors during trigger stop/start
- "Access denied" errors
- Triggers not stopping or starting

**Common Issues:**

#### **PowerShell Version Issues**
```powershell
# Problem: Using Windows PowerShell instead of PowerShell Core
# Solution: Use pwsh: true in Azure DevOps or PowerShell Core locally

# Azure DevOps
- task: AzurePowerShell@5
  inputs:
    pwsh: true  # ← Use PowerShell Core
    azurePowerShellVersion: 'LatestVersion'

# Locally
# Use PowerShell 7+ (pwsh) not Windows PowerShell (powershell)
pwsh PrePostDeploymentScript.Ver2.ps1 -armTemplate "ARMTemplate/ARMTemplateForFactory.json" ...
```

#### **Missing Permissions**
```powershell
# Problem: Service principal lacks permissions
# Required permissions:
# - Microsoft.DataFactory/factories/triggers/read
# - Microsoft.DataFactory/factories/triggers/write
# - Microsoft.DataFactory/factories/triggers/start/action
# - Microsoft.DataFactory/factories/triggers/stop/action

# Check permissions:
az role assignment list --assignee <service-principal-object-id> --resource-group <resource-group>

# Add permissions:
az role assignment create `
  --assignee <service-principal-object-id> `
  --role "Data Factory Contributor" `
  --resource-group <resource-group>
```

## Runtime Troubleshooting

### Issue: Pipeline Works in Debug but Fails When Triggered

**Possible Causes:**

1. **Debug vs. Live Mode Differences**
```
Debug Mode: Uses current Git branch (latest code)
Live Mode: Uses published version (may be outdated)

Solution: Ensure you've published latest changes
```

2. **Parameterization Issues**
```
Debug Mode: You manually enter parameter values
Triggered Mode: Uses trigger parameter mappings or defaults

Solution: Review trigger configuration and parameter values
```

3. **Time-Dependent Issues**
```
Debug Mode: Runs immediately with current timestamp
Triggered Mode: Runs at scheduled time (data may not be ready)

Solution: Add wait/delay logic or check for data availability first
```

**Diagnosis Script:**
```kusto
// Query to compare debug vs triggered runs in Log Analytics
ADFPipelineRun
| where PipelineName == "YourPipelineName"
| where TimeGenerated > ago(7d)
| extend RunMode = case(
    TriggerName == "", "Debug",
    "Triggered"
)
| summarize SuccessCount = countif(Status == "Succeeded"),
            FailureCount = countif(Status == "Failed") by RunMode
| project RunMode, SuccessCount, FailureCount, SuccessRate = SuccessCount * 100.0 / (SuccessCount + FailureCount)
```

### Issue: Git Connection Problems

**Symptoms:**
- "Failed to connect to repository"
- "Authentication failed"
- "Repository not found"

**Solutions:**

#### **GitHub**
```
1. Verify personal access token (PAT) is valid
2. PAT must have 'repo' scope
3. Check if organization requires SSO authorization
4. Verify repository is accessible (not archived/deleted)
5. Check firewall allows access to github.com
```

#### **Azure Repos**
```
1. Verify service principal or PAT has permissions
2. Check organization URL is correct (dev.azure.com/orgname)
3. Verify project and repository names are exact
4. Ensure repository is not disabled
5. Check for Azure DevOps service outages
```

**Test Git Connection:**
```bash
# GitHub
git ls-remote https://github.com/user/repo.git

# Azure Repos
git ls-remote https://dev.azure.com/organization/project/_git/repository
```

### Issue: Performance Problems

**Symptoms:**
- Pipelines taking hours to complete
- Timeout errors
- High Azure costs

**Performance Analysis:**

```kusto
// Find slowest activities in Log Analytics
ADFActivityRun
| where TimeGenerated > ago(7d)
| where Status == "Succeeded"
| extend DurationMinutes = datetime_diff('minute', End, Start)
| summarize AvgDuration = avg(DurationMinutes),
            MaxDuration = max(DurationMinutes),
            RunCount = count() by ActivityName, ActivityType
| where AvgDuration > 10  // Activities taking > 10 minutes on average
| order by AvgDuration desc
```

**Optimization Checklist:**

- [ ] **Copy Activities**: Increase DIUs (Data Integration Units) from default 4 to 8, 16, or 32
- [ ] **Data Flows**: Use appropriate compute size (General Purpose vs Memory Optimized vs Compute Optimized)
- [ ] **Parallel Execution**: Set ForEach activities to isSequential: false
- [ ] **Partitioning**: Use proper partitioning strategy in Data Flows
- [ ] **Source Queries**: Push filtering down to source (use query instead of full table)
- [ ] **Staging**: Enable staging for large Copy activities
- [ ] **Incremental Loads**: Avoid full refreshes, use incremental patterns
- [ ] **Data Flow Caching**: Enable compute caching for reused Data Flows

## Diagnostic Tools and Queries

### Log Analytics Queries

**Failed Pipeline Runs:**
```kusto
ADFPipelineRun
| where Status == "Failed"
| where TimeGenerated > ago(24h)
| project TimeGenerated, PipelineName, RunId, Status, FailureType, ErrorMessage, Parameters
| order by TimeGenerated desc
```

**Most Common Errors:**
```kusto
ADFActivityRun
| where Status == "Failed"
| where TimeGenerated > ago(7d)
| summarize ErrorCount = count() by ErrorCode, ErrorMessage
| order by ErrorCount desc
| take 10
```

**Pipeline Performance Trends:**
```kusto
ADFPipelineRun
| where TimeGenerated > ago(30d)
| where Status == "Succeeded"
| extend DurationMinutes = datetime_diff('minute', End, Start)
| summarize AvgDuration = avg(DurationMinutes) by bin(TimeGenerated, 1d), PipelineName
| render timechart
```

### PowerShell Diagnostic Commands

```powershell
# Get pipeline run details
Get-AzDataFactoryV2PipelineRun `
  -ResourceGroupName "myResourceGroup" `
  -DataFactoryName "myDataFactory" `
  -PipelineRunId "run-id-here"

# Get activity run details
Get-AzDataFactoryV2ActivityRun `
  -ResourceGroupName "myResourceGroup" `
  -DataFactoryName "myDataFactory" `
  -PipelineRunId "run-id-here" `
  -RunStartedAfter (Get-Date).AddDays(-1) `
  -RunStartedBefore (Get-Date)

# Test linked service connection
Invoke-AzDataFactoryV2LinkedServiceDebugSession `
  -ResourceGroupName "myResourceGroup" `
  -DataFactoryName "myDataFactory" `
  -LinkedServiceName "MyLinkedService"

# Get integration runtime status
Get-AzDataFactoryV2IntegrationRuntime `
  -ResourceGroupName "myResourceGroup" `
  -DataFactoryName "myDataFactory" `
  -Name "MyIntegrationRuntime" `
  -Status
```

### Azure CLI Diagnostic Commands

```bash
# Get failed pipeline runs
az datafactory pipeline list-runs \
  --resource-group myResourceGroup \
  --factory-name myDataFactory \
  --last-updated-after "2025-01-24T00:00:00Z" \
  --query "[?status=='Failed']"

# Get activity runs for a pipeline run
az datafactory activity-run query \
  --resource-group myResourceGroup \
  --factory-name myDataFactory \
  --run-id "pipeline-run-id"

# Test linked service
az datafactory linked-service show \
  --resource-group myResourceGroup \
  --factory-name myDataFactory \
  --name MyLinkedService
```

## Troubleshooting Decision Tree

```
1. Is this a CI/CD or runtime issue?
   ├─ CI/CD → Check build logs, validation errors, deployment errors
   └─ Runtime → Check pipeline run history, activity errors

2. Did it ever work?
   ├─ Yes → What changed? (code, config, environment)
   └─ No → Configuration or setup issue

3. Is it consistent or intermittent?
   ├─ Consistent → Configuration or code bug
   └─ Intermittent → Resource contention, network issues, or external dependencies

4. Does it work in Debug mode?
   ├─ Yes → Trigger configuration or parameterization issue
   └─ No → Pipeline or resource configuration issue

5. Is the error message clear?
   ├─ Yes → Follow specific error guidance above
   └─ No → Enable diagnostic logging, check detailed logs
```

## Best Practices for Troubleshooting

1. **Enable Diagnostic Logging** - Send logs to Log Analytics for querying
2. **Use Activity Annotations** - Add metadata to track ownership and purpose
3. **Implement Custom Logging** - Log pipeline execution details to database
4. **Set Up Alerts** - Proactive monitoring for failures
5. **Maintain Runbooks** - Document common issues and solutions
6. **Version Control** - Track what changed when issues started
7. **Test in Lower Environments** - Validate changes before production
8. **Use What-If Analysis** - Preview deployment changes
9. **Review Activity Logs** - Check Azure Activity Log for deployment details
10. **Keep Current** - Use latest versions of tools and scripts

## Getting Additional Help

If issues persist after following these troubleshooting steps:

1. **Check Microsoft Q&A**: https://learn.microsoft.com/en-us/answers/tags/130/azure-data-factory
2. **Azure Support**: Create support ticket for platform issues
3. **GitHub Issues**: Report bugs in @microsoft/azure-data-factory-utilities
4. **Stack Overflow**: Search and ask questions with tag [azure-data-factory]
5. **Azure Status**: Check for service outages: https://status.azure.com

## Documentation References

- **CI/CD Troubleshooting**: https://learn.microsoft.com/en-us/azure/data-factory/ci-cd-github-troubleshoot-guide
- **General Troubleshooting**: https://learn.microsoft.com/en-us/azure/data-factory/data-factory-troubleshoot-guide
- **Monitoring**: https://learn.microsoft.com/en-us/azure/data-factory/monitor-visually
- **Diagnostic Logs**: https://learn.microsoft.com/en-us/azure/data-factory/monitor-using-azure-monitor

Guide users systematically through troubleshooting using the appropriate diagnostic tools and queries for their specific issue.
