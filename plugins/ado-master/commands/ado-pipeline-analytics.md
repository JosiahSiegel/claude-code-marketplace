---
description: Analyze pipeline performance, track metrics, and identify optimization opportunities
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

# Pipeline Performance Analytics

## Purpose

Analyze Azure Pipelines performance metrics, identify bottlenecks, track trends, and generate actionable insights for optimization. Monitor success rates, execution times, agent utilization, and cost efficiency.

## Key Metrics

### 1. Pipeline Duration Metrics

**Average duration:**
- Total pipeline execution time
- Stage-level duration
- Job-level duration
- Task-level duration

**Critical thresholds:**
- CI pipelines: < 10 minutes (target)
- CD pipelines: < 30 minutes (target)
- Full CI/CD: < 45 minutes (target)

### 2. Success Metrics

**Success rate:**
- Overall success rate
- Success by branch
- Success by trigger type
- Failure patterns

**Targets:**
- Main branch: > 95% success
- Feature branches: > 85% success
- PR validations: > 90% success

### 3. Resource Metrics

**Agent utilization:**
- Wait time for agent
- Agent pool capacity
- Parallel job usage
- Self-hosted vs hosted agent costs

**Cost metrics:**
- Parallel job minutes consumed
- Storage costs (artifacts)
- Agent pool costs
- Optimization opportunities

## Analysis Commands

### Using Azure DevOps CLI

**Install and configure:**
```bash
# Install Azure CLI
# Windows: winget install Microsoft.AzureCLI
# macOS: brew install azure-cli
# Linux: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Azure DevOps extension
az extension add --name azure-devops

# Configure defaults
az devops configure --defaults \
  organization=https://dev.azure.com/your-org \
  project=your-project
```

**List recent pipeline runs:**
```bash
# Get last 50 runs
az pipelines runs list \
  --pipeline-id <pipeline-id> \
  --top 50 \
  --output table

# With specific columns
az pipelines runs list \
  --pipeline-id <pipeline-id> \
  --query "[].{ID:id, Status:status, Result:result, Duration:finishTime, QueueTime:queueTime}" \
  --output table
```

**Get pipeline statistics:**
```bash
# Average duration (last 30 runs)
az pipelines runs list \
  --pipeline-id <pipeline-id> \
  --top 30 \
  --query "avg([?finishTime].durationInSeconds)" \
  --output tsv

# Success rate
az pipelines runs list \
  --pipeline-id <pipeline-id> \
  --top 100 \
  --query "length([?result=='succeeded']) * 100 / length(@)" \
  --output tsv
```

**Failure analysis:**
```bash
# Get failed runs
az pipelines runs list \
  --pipeline-id <pipeline-id> \
  --status failed \
  --top 20 \
  --query "[].{ID:id, Result:result, Reason:reason, Branch:sourceBranch}" \
  --output table

# Get cancellation reasons
az pipelines runs list \
  --pipeline-id <pipeline-id> \
  --status canceled \
  --query "[].{ID:id, RequestedBy:requestedBy.displayName, CanceledBy:canceledBy.displayName}" \
  --output table
```

## Analytics Dashboard YAML

**Create analytics pipeline:**
```yaml
# analytics-pipeline.yml
trigger: none

schedules:
  - cron: "0 8 * * MON"  # Every Monday at 8 AM
    displayName: 'Weekly Pipeline Analytics'
    branches:
      include:
        - main

pool:
  vmImage: 'ubuntu-24.04'

variables:
  - name: analysisStartDate
    value: $[format('{0:yyyy-MM-dd}', addDays(pipeline.startTime, -30))]
  - name: targetPipelineId
    value: '123'  # Pipeline to analyze

stages:
  - stage: Analyze
    displayName: 'Pipeline Analytics'
    jobs:
      - job: Metrics
        displayName: 'Calculate Metrics'
        steps:
          - task: AzureCLI@2
            displayName: 'Install Azure DevOps Extension'
            inputs:
              azureSubscription: 'service-connection'
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                az extension add --name azure-devops --yes || true

          - script: |
              set -e

              echo "## Pipeline Performance Report"
              echo "Analysis Period: Last 30 days"
              echo ""

              # Configure Azure DevOps
              export AZURE_DEVOPS_EXT_PAT=$(System.AccessToken)
              az devops configure --defaults \
                organization=$(System.CollectionUri) \
                project=$(System.TeamProject)

              # Get pipeline runs
              echo "Fetching pipeline data..."
              RUNS=$(az pipelines runs list \
                --pipeline-id $(targetPipelineId) \
                --top 100 \
                --query-order QueueTimeDesc \
                --output json)

              # Calculate metrics
              TOTAL_RUNS=$(echo "$RUNS" | jq 'length')
              SUCCEEDED=$(echo "$RUNS" | jq '[.[] | select(.result=="succeeded")] | length')
              FAILED=$(echo "$RUNS" | jq '[.[] | select(.result=="failed")] | length')
              CANCELED=$(echo "$RUNS" | jq '[.[] | select(.result=="canceled")] | length')

              SUCCESS_RATE=$(echo "scale=2; $SUCCEEDED * 100 / $TOTAL_RUNS" | bc)

              # Duration analysis
              AVG_DURATION=$(echo "$RUNS" | jq '[.[] | select(.finishTime != null) |
                ((.finishTime | fromdateiso8601) - (.startTime | fromdateiso8601))] |
                add / length')
              AVG_DURATION_MIN=$(echo "scale=2; $AVG_DURATION / 60" | bc)

              # Agent wait time
              AVG_WAIT=$(echo "$RUNS" | jq '[.[] |
                ((.startTime | fromdateiso8601) - (.queueTime | fromdateiso8601))] |
                add / length')
              AVG_WAIT_SEC=$(echo "scale=0; $AVG_WAIT" | bc)

              # Output results
              echo "### Summary"
              echo "- Total Runs: $TOTAL_RUNS"
              echo "- Succeeded: $SUCCEEDED"
              echo "- Failed: $FAILED"
              echo "- Canceled: $CANCELED"
              echo "- Success Rate: ${SUCCESS_RATE}%"
              echo ""
              echo "### Performance"
              echo "- Average Duration: ${AVG_DURATION_MIN} minutes"
              echo "- Average Wait Time: ${AVG_WAIT_SEC} seconds"
              echo ""

              # Trends
              echo "### Failure Analysis"
              echo "$RUNS" | jq -r '[.[] | select(.result=="failed")] |
                group_by(.sourceBranch) |
                map({branch: .[0].sourceBranch, count: length}) |
                .[] | "- \(.branch): \(.count) failures"'

              # Save report
              echo "Saving report..."
              cat > $(Build.ArtifactStagingDirectory)/pipeline-report.txt <<EOF
              Pipeline Analytics Report
              Generated: $(date)

              Total Runs: $TOTAL_RUNS
              Success Rate: ${SUCCESS_RATE}%
              Average Duration: ${AVG_DURATION_MIN} minutes
              Average Wait Time: ${AVG_WAIT_SEC} seconds
              EOF

            displayName: 'Analyze Pipeline Performance'
            env:
              AZURE_DEVOPS_EXT_PAT: $(System.AccessToken)

          - task: PublishBuildArtifacts@1
            displayName: 'Publish Analytics Report'
            inputs:
              pathToPublish: '$(Build.ArtifactStagingDirectory)'
              artifactName: 'pipeline-analytics'

          - script: |
              # Send notification (example with Teams webhook)
              curl -H 'Content-Type: application/json' \
                -d "{\"text\": \"Pipeline Analytics Complete: Success Rate ${SUCCESS_RATE}%\"}" \
                $(TEAMS_WEBHOOK_URL)
            displayName: 'Send Notification'
            condition: succeededOrFailed()
```

## Advanced Analytics

### Cost Analysis

**Parallel job consumption:**
```bash
#!/bin/bash

# Calculate monthly parallel job minutes
START_DATE=$(date -d "30 days ago" +%Y-%m-%d)
END_DATE=$(date +%Y-%m-%d)

# Get all pipeline runs in period
az pipelines runs list \
  --query "[?queueTime >= '$START_DATE' && queueTime <= '$END_DATE'].durationInSeconds" \
  --output tsv | \
  awk '{sum+=$1} END {print "Total minutes:", sum/60}'

# Estimate cost (Microsoft-hosted agents)
# Free tier: 1,800 minutes/month
# Additional: $40/parallel job
```

**Agent pool efficiency:**
```bash
# Self-hosted agent utilization
az pipelines pool show --pool-id <pool-id>

# Calculate utilization percentage
# (Active job time / Total available time) * 100
```

### Bottleneck Identification

**Stage duration breakdown:**
```yaml
steps:
  - script: |
      # Get stage durations
      PIPELINE_ID=<pipeline-id>
      RUN_ID=$(az pipelines runs list \
        --pipeline-id $PIPELINE_ID \
        --top 1 \
        --query "[0].id" -o tsv)

      az pipelines runs show \
        --id $RUN_ID \
        --query "stages[].{Name:name, Duration:duration}" \
        --output table
    displayName: 'Stage Duration Analysis'
```

**Task-level metrics:**
```yaml
steps:
  - script: |
      # Extract task durations from timeline
      az pipelines build show \
        --id $(Build.BuildId) \
        --output json | \
        jq '.timeline.records[] |
          select(.type=="Task") |
          {name: .name, duration: .percentComplete}'
    displayName: 'Task Performance'
```

### Trend Analysis

**Track metrics over time:**
```python
# analytics.py
import requests
import json
from datetime import datetime, timedelta

org_url = "https://dev.azure.com/your-org"
project = "your-project"
pipeline_id = 123
pat_token = "your-pat-token"

headers = {
    "Authorization": f"Basic {pat_token}",
    "Content-Type": "application/json"
}

# Get last 90 days
end_date = datetime.now()
start_date = end_date - timedelta(days=90)

# Fetch runs
url = f"{org_url}/{project}/_apis/pipelines/{pipeline_id}/runs?api-version=7.0"
response = requests.get(url, headers=headers)
runs = response.json()['value']

# Calculate weekly trends
weeks = {}
for run in runs:
    week = datetime.fromisoformat(run['createdDate']).strftime("%Y-W%W")
    if week not in weeks:
        weeks[week] = {'total': 0, 'succeeded': 0, 'durations': []}

    weeks[week]['total'] += 1
    if run['result'] == 'succeeded':
        weeks[week]['succeeded'] += 1

    if 'finishedDate' in run:
        duration = (datetime.fromisoformat(run['finishedDate']) -
                   datetime.fromisoformat(run['createdDate'])).total_seconds()
        weeks[week]['durations'].append(duration)

# Output trends
for week, data in sorted(weeks.items()):
    success_rate = (data['succeeded'] / data['total']) * 100
    avg_duration = sum(data['durations']) / len(data['durations']) if data['durations'] else 0
    print(f"{week}: {success_rate:.1f}% success, {avg_duration/60:.1f} min avg")
```

## Reporting Dashboard

**Generate HTML report:**
```yaml
steps:
  - script: |
      cat > $(Build.ArtifactStagingDirectory)/report.html <<'EOF'
      <!DOCTYPE html>
      <html>
      <head>
        <title>Pipeline Analytics</title>
        <style>
          body { font-family: Arial, sans-serif; margin: 20px; }
          .metric { display: inline-block; padding: 20px; margin: 10px;
                   border: 1px solid #ddd; border-radius: 8px; }
          .success { background-color: #d4edda; }
          .warning { background-color: #fff3cd; }
          .danger { background-color: #f8d7da; }
        </style>
      </head>
      <body>
        <h1>Pipeline Performance Dashboard</h1>
        <div class="metric success">
          <h2>Success Rate</h2>
          <p>${SUCCESS_RATE}%</p>
        </div>
        <div class="metric">
          <h2>Avg Duration</h2>
          <p>${AVG_DURATION} min</p>
        </div>
        <div class="metric">
          <h2>Total Runs</h2>
          <p>${TOTAL_RUNS}</p>
        </div>
      </body>
      </html>
      EOF
    displayName: 'Generate HTML Report'

  - task: PublishBuildArtifacts@1
    inputs:
      pathToPublish: '$(Build.ArtifactStagingDirectory)/report.html'
      artifactName: 'dashboard'
```

## Alerting

**Set up alerts for degradation:**
```yaml
steps:
  - script: |
      # Check if success rate drops below threshold
      SUCCESS_RATE=$(az pipelines runs list \
        --pipeline-id $(targetPipelineId) \
        --top 10 \
        --query "length([?result=='succeeded']) * 100 / length(@)" \
        --output tsv)

      THRESHOLD=90
      if (( $(echo "$SUCCESS_RATE < $THRESHOLD" | bc -l) )); then
        echo "##vso[task.logissue type=warning]Success rate ${SUCCESS_RATE}% below threshold ${THRESHOLD}%"
        # Send alert
        curl -X POST $(ALERT_WEBHOOK) \
          -H "Content-Type: application/json" \
          -d "{\"message\": \"Pipeline success rate dropped to ${SUCCESS_RATE}%\"}"
      fi
    displayName: 'Check Success Rate'
```

## Best Practices

**Regular monitoring:**
- Daily: Monitor critical pipelines
- Weekly: Review trends and patterns
- Monthly: Comprehensive performance analysis
- Quarterly: Cost optimization review

**Key questions to answer:**
1. Are pipelines getting slower over time?
2. What percentage of runs succeed?
3. Where are the bottlenecks?
4. Is agent capacity sufficient?
5. Can we reduce costs?
6. Which stages take longest?
7. Are failures concentrated in specific areas?

**Action items from analytics:**
- Identify slow tasks → optimize or parallelize
- Low success rate → investigate root causes
- High wait times → increase agent capacity
- Rising costs → implement caching, reduce redundancy
- Frequent failures → improve tests, add validation

## Integration with Azure Monitor

**Send metrics to Application Insights:**
```yaml
steps:
  - task: AzureCLI@2
    inputs:
      azureSubscription: 'service-connection'
      scriptType: 'bash'
      scriptLocation: 'inlineScript'
      inlineScript: |
        # Send custom metric
        az monitor app-insights metrics show \
          --app pipeline-insights \
          --resource-group monitoring-rg \
          --metrics customMetrics/PipelineDuration \
          --aggregation avg
```

## Resources

- [Azure Pipelines Analytics](https://learn.microsoft.com/azure/devops/pipelines/reports/pipelinereport)
- [Azure DevOps CLI Reference](https://learn.microsoft.com/cli/azure/pipelines)
- [REST API Documentation](https://learn.microsoft.com/rest/api/azure/devops/pipelines)
- [Pipeline Reporting](https://learn.microsoft.com/azure/devops/report/powerbi/what-is-analytics)

## Summary

Pipeline analytics provides visibility into performance, reliability, and cost efficiency. Regular monitoring and analysis enable data-driven optimization decisions, improving development velocity and reducing operational costs. Use these tools and techniques to maintain high-performing CI/CD pipelines.
