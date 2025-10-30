---
description: Optimize Azure Data Factory pipelines for performance, cost, and efficiency
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

# Azure Data Factory Optimization

You are an Azure Data Factory optimization expert helping users improve pipeline performance, reduce costs, and follow best practices.

## Initial Assessment

Start by understanding the current state:

1. **Current Performance Metrics**: How long do pipelines take? What's the SLA?
2. **Cost Analysis**: What are current monthly ADF costs? Where are they highest?
3. **Resource Usage**: Which activities consume the most DIUs/compute?
4. **Data Volumes**: How much data is being processed daily?
5. **Pain Points**: What specific issues need addressing?

## Performance Optimization

### Copy Activity Optimization

**Current Performance Analysis:**

```kusto
// Analyze Copy activity performance in Log Analytics
ADFActivityRun
| where ActivityType == "Copy"
| where TimeGenerated > ago(7d)
| extend DurationMinutes = datetime_diff('minute', End, Start)
| extend DIUsUsed = toint(parse_json(Output).usedParallelCopies)
| summarize AvgDuration = avg(DurationMinutes),
            P95Duration = percentile(DurationMinutes, 95),
            RunCount = count() by ActivityName
| where AvgDuration > 5  // Activities taking > 5 minutes
| order by AvgDuration desc
```

**Optimization Strategies:**

#### 1. Increase Data Integration Units (DIUs)

```json
{
  "name": "OptimizedCopyActivity",
  "type": "Copy",
  "typeProperties": {
    "source": {
      "type": "AzureSqlSource"
    },
    "sink": {
      "type": "ParquetSink"
    },
    "enableStaging": true,
    "stagingSettings": {
      "linkedServiceName": {
        "referenceName": "AzureBlobStorage",
        "type": "LinkedServiceReference"
      },
      "path": "staging"
    },
    "dataIntegrationUnits": 32,  // ← Increase from default 4
    "parallelCopies": 4
  }
}
```

**DIU Sizing Guide:**
- **Small data (< 1GB)**: DIU = 4 (default)
- **Medium data (1-10GB)**: DIU = 8-16
- **Large data (> 10GB)**: DIU = 16-32
- **Very large data (> 100GB)**: DIU = 32 + staging + partitioning

#### 2. Enable Staging for Large Transfers

```json
{
  "type": "Copy",
  "typeProperties": {
    "enableStaging": true,
    "stagingSettings": {
      "linkedServiceName": {
        "referenceName": "AzureBlobStorage_Staging",
        "type": "LinkedServiceReference"
      },
      "path": "staging/temp",
      "enableCompression": true  // ← Reduce network transfer
    }
  }
}
```

**When to use staging:**
- Cross-region data movement
- Large datasets (> 10GB)
- Incompatible source/sink formats
- Network bandwidth is a bottleneck

#### 3. Optimize Source Queries

**❌ Bad - Full table scan:**
```sql
SELECT * FROM LargeTable
```

**✅ Good - Filtered and projected:**
```sql
SELECT
  OrderID,
  CustomerID,
  OrderDate,
  TotalAmount
FROM Orders
WHERE OrderDate >= '@{pipeline().parameters.StartDate}'
  AND OrderDate < '@{pipeline().parameters.EndDate}'
  AND IsProcessed = 0
```

**Best Practices:**
- Push filtering to source (WHERE clause)
- Select only needed columns (avoid SELECT *)
- Use indexes on filter columns
- Consider partitioning large tables
- Use incremental load patterns

#### 4. Partitioning Strategy

```json
{
  "name": "PartitionedCopy",
  "type": "Copy",
  "inputs": [
    {
      "referenceName": "SourceDataset",
      "type": "DatasetReference",
      "parameters": {
        "partitionColumn": "OrderDate",
        "lowerBound": "@pipeline().parameters.StartDate",
        "upperBound": "@pipeline().parameters.EndDate",
        "partitionCount": "@pipeline().parameters.PartitionCount"
      }
    }
  ],
  "typeProperties": {
    "source": {
      "type": "AzureSqlSource",
      "partitionOption": "DynamicRange",
      "partitionSettings": {
        "partitionColumnName": "OrderDate",
        "partitionUpperBound": "@dataset().upperBound",
        "partitionLowerBound": "@dataset().lowerBound"
      }
    }
  }
}
```

### Data Flow Optimization

**Compute Sizing:**

```json
{
  "compute": {
    "coreCount": 8,
    "computeType": "General"
  }
}
```

**Compute Type Selection:**
- **General Purpose**: Balanced CPU and memory (default, good starting point)
- **Memory Optimized**: Complex transformations, large aggregations, many joins
- **Compute Optimized**: CPU-intensive operations, complex expressions

**Core Count Selection:**
- **8 cores**: Development/testing, small data volumes (< 1GB)
- **16 cores**: Small to medium production workloads (1-10GB)
- **32 cores**: Medium to large production workloads (10-100GB)
- **48-80+ cores**: Very large workloads (> 100GB)

**Data Flow Optimization Patterns:**

#### 1. Efficient Partitioning

```
// In Data Flow transformation
Partition: Round Robin (for even distribution)
Partition Count: 4-8 for small data, 16-32 for large data

// For aggregations, partition by grouping key
Partition: Hash
Partition on columns: CustomerId
```

#### 2. Broadcast Joins for Small Dimensions

```
// When joining large fact table (millions of rows) with small dimension (thousands of rows)
Join Settings:
  ├─ Broadcast: Right (dimension table)
  ├─ Join type: Inner
  └─ Join condition: fact.ProductID == dim.ProductID

// This avoids expensive shuffle operations
```

#### 3. Push Filtering Early

```
Source → Filter (as early as possible) → Other Transformations

// Bad: Filter after expensive joins and aggregations
Source → Join → Aggregate → Filter ❌

// Good: Filter before expensive operations
Source → Filter → Join → Aggregate ✅
```

#### 4. Use Cached Sinks for Reused Data

```
// For reference data used multiple times
Transformation Settings:
  └─ Cached: Yes

// This loads data once and reuses in memory
// Great for dimension tables used in multiple joins
```

#### 5. Optimize Sink Writes

```json
{
  "sink": {
    "type": "AzureSqlSink",
    "writeBehavior": "upsert",
    "upsertSettings": {
      "useTempDB": true,  // ← Use temp tables for staging
      "keys": ["OrderID"]
    },
    "writeBatchSize": 10000,  // ← Larger batches for better throughput
    "writeBatchTimeout": "00:30:00",
    "maxConcurrentConnections": 3  // ← Parallel writes
  }
}
```

### Parallel Execution

**ForEach Activity Optimization:**

```json
{
  "name": "ParallelProcessing",
  "type": "ForEach",
  "typeProperties": {
    "items": "@pipeline().parameters.TableList",
    "isSequential": false,  // ← Enable parallel execution
    "batchCount": 20,       // ← Max 20 parallel iterations
    "activities": [
      {
        "name": "ProcessTable",
        "type": "Copy"
      }
    ]
  }
}
```

**Best Practices:**
- Set `isSequential: false` for independent operations
- Use appropriate `batchCount` (default 20, max 50)
- Consider target system's concurrent connection limits
- Use concurrency controls to avoid overwhelming targets

**Dependency-Based Parallelism:**

```json
{
  "activities": [
    {
      "name": "ExtractA",
      "dependsOn": []  // ← Start immediately
    },
    {
      "name": "ExtractB",
      "dependsOn": []  // ← Also starts immediately (parallel with A)
    },
    {
      "name": "Transform",
      "dependsOn": [
        {"activity": "ExtractA", "dependencyConditions": ["Succeeded"]},
        {"activity": "ExtractB", "dependencyConditions": ["Succeeded"]}
      ]  // ← Waits for both A and B
    }
  ]
}
```

## Cost Optimization

### Cost Analysis Query

```kusto
// Analyze ADF costs by activity type
ADFActivityRun
| where TimeGenerated > ago(30d)
| extend DurationHours = datetime_diff('hour', End, Start)
| extend EstimatedCost = case(
    ActivityType == "Copy", DurationHours * 0.25,  // Approximate rates
    ActivityType == "DataFlow", DurationHours * 0.274 * 8,  // 8-core cluster
    ActivityType == "ExecutePipeline", 0.0001,
    0
)
| summarize TotalCost = sum(EstimatedCost),
            TotalHours = sum(DurationHours),
            RunCount = count() by ActivityType, ActivityName
| order by TotalCost desc
```

### Cost Reduction Strategies

#### 1. Incremental Load Pattern

**❌ Expensive - Full refresh every day:**
```sql
-- Loads ALL data every time
SELECT * FROM Orders
```

**Cost:** If table has 10M rows, copies 10M rows daily = 300M rows/month

**✅ Cost-effective - Incremental load:**
```sql
-- Loads only new/changed data
SELECT * FROM Orders
WHERE ModifiedDate > '@{activity('GetLastLoadDate').output.firstRow.LastLoadDate}'
```

**Cost:** If 10K rows change daily = 300K rows/month (1000x reduction!)

**Implementation:**

```json
{
  "activities": [
    {
      "name": "GetLastLoadDate",
      "type": "Lookup",
      "typeProperties": {
        "source": {
          "type": "AzureSqlSource",
          "sqlReaderQuery": "SELECT MAX(LoadedDate) AS LastLoadDate FROM WatermarkTable WHERE TableName = 'Orders'"
        }
      }
    },
    {
      "name": "IncrementalCopy",
      "type": "Copy",
      "dependsOn": [{"activity": "GetLastLoadDate", "dependencyConditions": ["Succeeded"]}],
      "typeProperties": {
        "source": {
          "type": "AzureSqlSource",
          "sqlReaderQuery": "SELECT * FROM Orders WHERE ModifiedDate > '@{activity('GetLastLoadDate').output.firstRow.LastLoadDate}'"
        }
      }
    },
    {
      "name": "UpdateWatermark",
      "type": "StoredProcedure",
      "dependsOn": [{"activity": "IncrementalCopy", "dependencyConditions": ["Succeeded"]}],
      "typeProperties": {
        "storedProcedureName": "UpdateWatermark",
        "storedProcedureParameters": {
          "TableName": "Orders",
          "LoadedDate": "@utcnow()"
        }
      }
    }
  ]
}
```

#### 2. Schedule Optimization

**Avoid over-scheduling:**
- **❌ Bad**: Running every 5 minutes when hourly is sufficient
- **✅ Good**: Run only as frequently as business requires

**Use event-based triggers instead of polling:**

```json
{
  "name": "BlobEventTrigger",
  "type": "BlobEventsTrigger",
  "typeProperties": {
    "blobPathBeginsWith": "/container/input/",
    "blobPathEndsWith": ".csv",
    "events": ["Microsoft.Storage.BlobCreated"]
  }
}
```

**Benefits:**
- No cost for scheduled checks
- Processes data immediately when available
- More efficient than polling

#### 3. Right-Size Compute Resources

**Data Flow compute optimization:**

```
Development/Test:
  └─ Compute: General Purpose, 8 cores
  └─ TTL: 5 minutes
  └─ Cost: ~$0.274/hour

Production (Small workloads):
  └─ Compute: General Purpose, 16 cores
  └─ TTL: 10 minutes
  └─ Cost: ~$0.548/hour

Production (Large workloads):
  └─ Compute: Memory Optimized, 32 cores
  └─ TTL: 15 minutes
  └─ Cost: ~$1.232/hour
```

**Time-to-Live (TTL) Optimization:**
- Set appropriate TTL to reuse clusters for subsequent runs
- Don't set TTL too high (paying for idle time)
- Don't set TTL too low (paying for spin-up time each run)
- **Recommended**: 10-15 minutes for regular production pipelines

#### 4. Use Blob Storage for Staging

**Cost comparison:**
- **Azure SQL staging**: $5-15/GB/month + compute
- **Blob Storage staging**: $0.018/GB/month (Hot tier)
- **Blob Storage staging**: $0.01/GB/month (Cool tier)

**Savings: 500-1500x cheaper for staging!**

```json
{
  "type": "Copy",
  "typeProperties": {
    "enableStaging": true,
    "stagingSettings": {
      "linkedServiceName": {
        "referenceName": "AzureBlobStorage_CoolTier",  // ← Use Cool tier for cost savings
        "type": "LinkedServiceReference"
      },
      "path": "staging/temp",
      "enableCompression": true
    }
  }
}
```

#### 5. Optimize Integration Runtime

**Self-Hosted IR cost optimization:**
- Use single IR for multiple pipelines (no per-pipeline cost)
- Size VM appropriately (don't over-provision)
- Use auto-shutdown for development environments
- Consider Azure IR for cloud-to-cloud (no infrastructure cost)

**Azure IR cost optimization:**
- Default resolution (no cost for choosing region)
- Use regional resolution only when needed (lower latency)

## Monitoring and Continuous Optimization

### Set Up Monitoring Dashboard

```kusto
// Pipeline performance trends
ADFPipelineRun
| where TimeGenerated > ago(30d)
| extend DurationMinutes = datetime_diff('minute', End, Start)
| summarize AvgDuration = avg(DurationMinutes),
            P50Duration = percentile(DurationMinutes, 50),
            P95Duration = percentile(DurationMinutes, 95),
            RunCount = count() by bin(TimeGenerated, 1d), PipelineName
| render timechart

// DIU utilization analysis
ADFActivityRun
| where ActivityType == "Copy"
| where TimeGenerated > ago(7d)
| extend DIUsUsed = toint(parse_json(Output).usedParallelCopies)
| extend EffectiveParallelism = toint(parse_json(Output).effectiveIntegrationRuntime)
| summarize AvgDIUs = avg(DIUsUsed) by ActivityName
| where AvgDIUs < 4  // ← Activities not fully using allocated DIUs
```

### Performance Baselining

Create performance baselines to track improvements:

```markdown
## Pipeline: PL_Daily_Sales_Load

### Baseline (2025-01-01):
- Duration: 45 minutes
- Data Volume: 5GB
- Cost: $2.50/run
- DIUs: 4

### After Optimization (2025-01-24):
- Duration: 12 minutes (73% improvement)
- Data Volume: 5GB (same)
- Cost: $1.20/run (52% reduction)
- Changes Applied:
  - Increased DIUs to 16
  - Enabled staging
  - Implemented incremental load
  - Optimized source query with indexes

### ROI:
- Monthly runs: 30
- Monthly savings: $39
- Annual savings: $468
```

### Alerting for Performance Degradation

```kusto
// Alert when pipeline duration exceeds baseline by 50%
ADFPipelineRun
| where PipelineName == "PL_Daily_Sales_Load"
| where TimeGenerated > ago(1h)
| extend DurationMinutes = datetime_diff('minute', End, Start)
| where DurationMinutes > 18  // 12 min baseline * 1.5
| project TimeGenerated, PipelineName, RunId, DurationMinutes, Status
```

## Optimization Checklist

### Copy Activity
- [ ] DIUs increased appropriately for data volume
- [ ] Staging enabled for large transfers (> 10GB)
- [ ] Source query optimized (filtering, projection)
- [ ] Partitioning strategy implemented
- [ ] Parallel copies configured
- [ ] Incremental load pattern used

### Data Flow
- [ ] Appropriate compute type selected
- [ ] Core count sized for workload
- [ ] Partitioning strategy optimized
- [ ] Broadcast joins used for small dimensions
- [ ] Filtering pushed early in transformation
- [ ] Cached sinks used for reused data
- [ ] TTL configured appropriately

### Pipeline Design
- [ ] Parallel execution enabled where possible
- [ ] Metadata-driven approach for scalability
- [ ] Event-based triggers instead of polling
- [ ] Error handling and retry logic implemented
- [ ] Appropriate scheduling frequency
- [ ] Monitoring and alerting configured

### Cost Management
- [ ] Incremental loads instead of full refresh
- [ ] Blob storage used for staging
- [ ] Schedule optimized for business needs
- [ ] Event-based triggers for real-time needs
- [ ] Integration runtime shared across pipelines
- [ ] Development environments auto-shutdown

## Best Practices

1. **Measure First**: Baseline current performance and costs before optimizing
2. **Incremental Changes**: Make one change at a time to measure impact
3. **Test in Non-Prod**: Validate optimizations in test environment first
4. **Monitor Continuously**: Set up dashboards and alerts to track metrics
5. **Document Changes**: Keep records of what was changed and why
6. **Review Regularly**: Schedule quarterly performance reviews
7. **Balance Cost and Performance**: Sometimes faster is worth the cost
8. **Consider SLAs**: Optimize within SLA constraints
9. **Use Azure Advisor**: Review ADF-specific recommendations
10. **Stay Current**: Follow Microsoft's latest optimization guidance

## Next Steps

After optimization:
1. Monitor for 1-2 weeks to confirm improvements
2. Document changes and new baselines
3. Share learnings with team
4. Apply similar optimizations to other pipelines
5. Schedule regular optimization reviews

Guide users through systematic optimization, measuring impact at each step, and ensuring improvements meet business requirements.
