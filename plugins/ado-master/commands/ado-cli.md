---
description: Manage Azure DevOps pipelines, repos, and workflows using Azure DevOps CLI
---

# Azure DevOps CLI Operations

## Purpose
Use Azure DevOps CLI (`az devops` and `az pipelines`) to manage pipelines, repositories, work items, and other ADO resources from the command line.

## Before Using CLI

**Check latest CLI documentation:**
1. Azure DevOps CLI extension documentation
2. Latest CLI version and features
3. Authentication methods
4. Breaking changes in recent releases

**Resources:**
- https://learn.microsoft.com/en-us/azure/devops/cli/
- https://github.com/Azure/azure-devops-cli-extension

## Setup and Configuration

### Installation

```bash
# Install Azure CLI (if not already installed)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Azure DevOps extension
az extension add --name azure-devops

# Update extension
az extension update --name azure-devops

# Check version
az devops --version
az extension list
```

### Authentication

```bash
# Method 1: Personal Access Token (PAT)
export AZURE_DEVOPS_EXT_PAT=your-pat-token

# Method 2: Az login (for Azure AD authenticated orgs)
az login

# Method 3: Interactive
az devops login --organization https://dev.azure.com/yourorg

# Verify authentication
az devops user show
```

### Configuration

```bash
# Set default organization and project
az devops configure --defaults organization=https://dev.azure.com/yourorg project=myproject

# List current defaults
az devops configure --list

# Set output format
az devops configure --defaults output=table
# Options: json, jsonc, table, tsv, yaml, yamlc, none
```

## Pipeline Management

### List and View Pipelines

```bash
# List all pipelines
az pipelines list --output table

# List with specific fields
az pipelines list --query "[].{Name:name, ID:id, Path:path}" --output table

# Show specific pipeline
az pipelines show --id <pipeline-id>
az pipelines show --name "My Pipeline"

# Get pipeline YAML
az pipelines show --id <pipeline-id> --query "configuration.path"
```

### Create Pipeline

```bash
# Create pipeline from YAML file
az pipelines create \
  --name "New Pipeline" \
  --description "My new pipeline" \
  --repository myrepo \
  --branch main \
  --yml-path azure-pipelines.yml

# Create with service connection
az pipelines create \
  --name "Docker Pipeline" \
  --repository myrepo \
  --branch main \
  --yml-path pipelines/docker.yml \
  --service-connection my-acr-connection
```

### Run Pipelines

```bash
# Queue a pipeline run
az pipelines run --id <pipeline-id>

# Run with branch
az pipelines run --name "My Pipeline" --branch feature/new-feature

# Run with variables
az pipelines run --id <pipeline-id> \
  --variables buildConfiguration=Release environment=production

# Run with parameters (runtime parameters)
az pipelines run --id <pipeline-id> \
  --parameters environment=prod deployRegion=eastus
```

### Pipeline Runs

```bash
# List recent runs
az pipelines runs list --pipeline-id <id> --top 10 --output table

# List failed runs
az pipelines runs list --status failed --top 20

# Show specific run
az pipelines runs show --id <run-id>

# Show run with logs
az pipelines runs show --id <run-id> --open

# List artifacts from run
az pipelines runs artifact list --run-id <run-id>

# Download artifact
az pipelines runs artifact download \
  --run-id <run-id> \
  --artifact-name drop \
  --path ./downloads
```

### Pipeline Variables

```bash
# List pipeline variables
az pipelines variable list --pipeline-id <id>

# Create variable
az pipelines variable create \
  --pipeline-id <id> \
  --name apiUrl \
  --value "https://api.example.com"

# Create secret variable
az pipelines variable create \
  --pipeline-id <id> \
  --name apiKey \
  --value "secret-value" \
  --secret true

# Update variable
az pipelines variable update \
  --pipeline-id <id> \
  --name apiUrl \
  --value "https://api-new.example.com"

# Delete variable
az pipelines variable delete \
  --pipeline-id <id> \
  --name oldVariable \
  --yes
```

### Variable Groups

```bash
# List variable groups
az pipelines variable-group list --output table

# Create variable group
az pipelines variable-group create \
  --name "Production Variables" \
  --variables apiUrl=https://api.prod.com environment=production

# Add variable to group
az pipelines variable-group variable create \
  --group-id <group-id> \
  --name newVar \
  --value "new value"

# Create secret variable in group
az pipelines variable-group variable create \
  --group-id <group-id> \
  --name apiSecret \
  --value "secret" \
  --secret true

# Link variable group to Key Vault
az pipelines variable-group create \
  --name "KeyVault Secrets" \
  --authorize true \
  --variables \
  --keyvault-name my-keyvault \
  --keyvault-subscription <subscription-id>
```

## Repository Management

### List and View Repos

```bash
# List repositories
az repos list --output table

# Show specific repository
az repos show --repository myrepo

# Get default branch
az repos show --repository myrepo --query defaultBranch
```

### Branch Operations

```bash
# List branches
az repos ref list --repository myrepo --filter heads

# Create branch
az repos ref create \
  --name refs/heads/feature/new-feature \
  --repository myrepo \
  --object-id <commit-sha>

# Delete branch
az repos ref delete \
  --name refs/heads/old-feature \
  --repository myrepo \
  --object-id <commit-sha>

# Lock branch
az repos ref lock \
  --name refs/heads/main \
  --repository myrepo
```

### Pull Requests

```bash
# List pull requests
az repos pr list --repository myrepo --output table

# List active PRs
az repos pr list --status active

# Create pull request
az repos pr create \
  --repository myrepo \
  --source-branch feature/new-feature \
  --target-branch main \
  --title "Add new feature" \
  --description "This PR adds a new feature"

# Show PR details
az repos pr show --id <pr-id>

# List PR reviewers
az repos pr reviewer list --id <pr-id>

# Add reviewer
az repos pr reviewer add \
  --id <pr-id> \
  --reviewers user@example.com

# Set PR status
az repos pr update --id <pr-id> --status completed

# Set auto-complete
az repos pr set-vote --id <pr-id> --vote approve
```

### Policy Management

```bash
# List branch policies
az repos policy list --repository myrepo --branch main

# Create build validation policy
az repos policy build create \
  --blocking true \
  --branch main \
  --build-definition-id <pipeline-id> \
  --display-name "Build Validation" \
  --enabled true \
  --manual-queue-only false \
  --queue-on-source-update-only false \
  --repository-id <repo-id> \
  --valid-duration 720

# Create required reviewers policy
az repos policy required-reviewer create \
  --blocking true \
  --branch main \
  --enabled true \
  --message "Code review required" \
  --repository-id <repo-id> \
  --required-reviewer-ids user1@example.com user2@example.com
```

## Work Item Management

```bash
# List work items
az boards work-item show --id <work-item-id>

# Create work item
az boards work-item create \
  --title "New Task" \
  --type Task \
  --assigned-to user@example.com

# Update work item
az boards work-item update \
  --id <work-item-id> \
  --state "In Progress" \
  --assigned-to user@example.com

# Query work items
az boards query \
  --wiql "SELECT [System.Id], [System.Title] FROM WorkItems WHERE [System.WorkItemType] = 'Bug' AND [System.State] = 'Active'"
```

## Service Endpoints (Service Connections)

```bash
# List service endpoints
az devops service-endpoint list --output table

# Show specific endpoint
az devops service-endpoint show --id <endpoint-id>

# Create Azure RM service endpoint
az devops service-endpoint azurerm create \
  --azure-rm-service-principal-id <sp-id> \
  --azure-rm-subscription-id <subscription-id> \
  --azure-rm-subscription-name "My Subscription" \
  --azure-rm-tenant-id <tenant-id> \
  --name "Azure Connection"

# Create GitHub service endpoint
az devops service-endpoint github create \
  --github-url https://github.com \
  --name "GitHub Connection"
```

## Useful Scripts and Automation

### Bulk Pipeline Operations

```bash
#!/bin/bash
# Run all pipelines matching a pattern

az devops configure --defaults organization=https://dev.azure.com/myorg project=myproject

# Get all pipelines with "CI" in name
pipelines=$(az pipelines list --query "[?contains(name, 'CI')].id" -o tsv)

for pipeline_id in $pipelines; do
  echo "Running pipeline: $pipeline_id"
  az pipelines run --id $pipeline_id --branch main
done
```

### Monitor Pipeline Status

```bash
#!/bin/bash
# Check status of recent pipeline runs

run_id=$1

while true; do
  status=$(az pipelines runs show --id $run_id --query "status" -o tsv)
  result=$(az pipelines runs show --id $run_id --query "result" -o tsv)

  echo "Status: $status, Result: $result"

  if [ "$status" = "completed" ]; then
    if [ "$result" = "succeeded" ]; then
      echo "Pipeline succeeded!"
      exit 0
    else
      echo "Pipeline failed!"
      exit 1
    fi
  fi

  sleep 30
done
```

### Export Pipeline Definitions

```bash
#!/bin/bash
# Export all pipeline definitions

output_dir="pipeline-exports"
mkdir -p $output_dir

# Get all pipeline IDs
pipeline_ids=$(az pipelines list --query "[].id" -o tsv)

for id in $pipeline_ids; do
  name=$(az pipelines show --id $id --query "name" -o tsv)
  # Replace spaces with underscores
  filename="${name// /_}"

  echo "Exporting: $name"

  # Get pipeline definition as JSON
  az pipelines show --id $id > "$output_dir/${filename}.json"
done

echo "Exported pipelines to $output_dir"
```

### Bulk Variable Updates

```bash
#!/bin/bash
# Update variable across multiple pipelines

variable_name="apiUrl"
new_value="https://api-new.example.com"

# Get all pipeline IDs
pipeline_ids=$(az pipelines list --query "[].id" -o tsv)

for id in $pipeline_ids; do
  echo "Updating pipeline: $id"

  # Check if variable exists
  existing=$(az pipelines variable list --pipeline-id $id --query "*.name" -o tsv | grep -w "$variable_name")

  if [ -n "$existing" ]; then
    az pipelines variable update \
      --pipeline-id $id \
      --name "$variable_name" \
      --value "$new_value"
  else
    echo "Variable $variable_name not found in pipeline $id"
  fi
done
```

### PR Report

```bash
#!/bin/bash
# Generate PR report

echo "Pull Request Report - $(date)"
echo "================================"

# Active PRs
active_count=$(az repos pr list --status active --query "length(@)")
echo "Active PRs: $active_count"

# PRs by author
echo -e "\nPRs by Author:"
az repos pr list --status active --query "[].{Author: createdBy.displayName}" -o tsv | sort | uniq -c

# Old PRs (> 7 days)
echo -e "\nPRs older than 7 days:"
seven_days_ago=$(date -d '7 days ago' -u +"%Y-%m-%dT%H:%M:%SZ")
az repos pr list --status active \
  --query "[?creationDate<'$seven_days_ago'].{ID: pullRequestId, Title: title, Created: creationDate}" \
  -o table
```

## Output

When providing CLI help, include:
1. Complete working command with all required parameters
2. Explanation of what the command does
3. Common flags and options
4. Output format examples
5. Error handling recommendations
6. Related commands to consider
7. Script examples for automation
8. Links to official CLI documentation
