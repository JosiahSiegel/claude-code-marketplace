---
description: Optimize PowerShell scripts for performance with parallel processing, efficient filtering, and .NET 9 enhancements
---

# PowerShell Performance Optimization

Optimize PowerShell scripts using parallel processing (PowerShell 7+), efficient cmdlet usage, and .NET 9 performance features.

## When to Use

- Scripts running slowly with large datasets
- Long-running automation tasks
- Batch processing operations
- CPU-intensive computations
- File system operations at scale

## Instructions

### 1. Use Parallel Processing (PowerShell 7+)

**ForEach-Object -Parallel** for concurrent operations:

```powershell
# Sequential (slow) - processes one at a time
1..100 | ForEach-Object {
    Start-Sleep -Milliseconds 100
    "Processing $_"
}
# Takes ~10 seconds

# Parallel (fast) - processes concurrently
1..100 | ForEach-Object -Parallel {
    Start-Sleep -Milliseconds 100
    "Processing $_"
} -ThrottleLimit 10
# Takes ~1 second (10x faster)
```

**Real-world examples:**

```powershell
# Process files in parallel
Get-ChildItem "C:\Logs" -Filter "*.log" | ForEach-Object -Parallel {
    $content = Get-Content $_.FullName
    $errors = $content | Select-String "ERROR"
    [PSCustomObject]@{
        File = $_.Name
        ErrorCount = $errors.Count
    }
} -ThrottleLimit 10

# Query multiple servers concurrently
$servers = @("server1", "server2", "server3", "server4")
$results = $servers | ForEach-Object -Parallel {
    Test-Connection $_ -Count 1 -Quiet
} -ThrottleLimit 4

# Parallel API calls
$urls = @("https://api1.example.com", "https://api2.example.com")
$urls | ForEach-Object -Parallel {
    Invoke-RestMethod -Uri $_
} -ThrottleLimit 5
```

### 2. Efficient Filtering

**Use -Filter instead of Where-Object:**

```powershell
# SLOW - Where-Object filters after retrieval
Get-ChildItem C:\Temp | Where-Object { $_.Extension -eq ".log" }
# Retrieves ALL files, then filters

# FAST - Filter parameter filters at source
Get-ChildItem C:\Temp -Filter "*.log"
# Only retrieves .log files (10x+ faster)
```

**Provider-specific filtering:**

```powershell
# Active Directory - SLOW
Get-ADUser -Filter * | Where-Object { $_.Department -eq "IT" }

# Active Directory - FAST
Get-ADUser -Filter "Department -eq 'IT'"

# Azure - SLOW
Get-AzVM | Where-Object { $_.Location -eq "eastus" }

# Azure - FAST
Get-AzVM -ResourceGroupName "MyRG" | Where-Object { $_.Location -eq "eastus" }
# Or use Azure Resource Graph for complex queries
```

### 3. Avoid Array Concatenation in Loops

**Problem:**

```powershell
# VERY SLOW - creates new array on each iteration
$results = @()
foreach ($i in 1..10000) {
    $results += $i * 2  # Array copy on every iteration
}
# Takes ~15 seconds for 10,000 items
```

**Solution 1: Use ArrayList or List<T>**

```powershell
# FAST - efficient Add method
$results = [System.Collections.ArrayList]::new()
foreach ($i in 1..10000) {
    [void]$results.Add($i * 2)
}
# Takes ~0.05 seconds

# Or use generic List
$results = [System.Collections.Generic.List[int]]::new()
foreach ($i in 1..10000) {
    $results.Add($i * 2)
}
```

**Solution 2: Output to Pipeline (PowerShell 7.5+)**

```powershell
# FASTEST in PowerShell 7.5+ - optimized += operator
$results = @()
foreach ($i in 1..10000) {
    $results += $i * 2
}
# PowerShell 7.5: ~0.1 seconds (100x faster than 7.4)

# Or let PowerShell collect automatically
$results = foreach ($i in 1..10000) {
    $i * 2  # Output to pipeline
}
# PowerShell collects efficiently
```

### 4. Use .NET Methods for Performance

**String operations:**

```powershell
# SLOW - PowerShell string operations
$text = "Hello World"
$text.Replace("World", "PowerShell")

# FAST - .NET string methods (same speed, but more options)
[string]::Join(",", $array)
[string]::IsNullOrEmpty($value)
[string]::Format("{0} {1}", $first, $last)
```

**File I/O:**

```powershell
# SLOW - Get-Content for large files
$content = Get-Content "large-file.txt"

# FAST - .NET StreamReader for large files
$reader = [System.IO.StreamReader]::new("large-file.txt")
while ($null -ne ($line = $reader.ReadLine())) {
    # Process line
}
$reader.Close()

# Or use -ReadCount for chunked reading
Get-Content "large-file.txt" -ReadCount 1000 | ForEach-Object {
    # Process 1000 lines at a time
}
```

### 5. Optimize Pipeline Usage

```powershell
# SLOW - Multiple pipeline passes
Get-Process | Where-Object { $_.WorkingSet -gt 100MB } |
    Sort-Object CPU -Descending |
    Select-Object -First 10

# FASTER - Minimize pipeline stages
Get-Process |
    Where-Object { $_.WorkingSet -gt 100MB } |
    Sort-Object CPU -Descending -Top 10  # PowerShell 7+
```

### 6. Measure Performance

**Use Measure-Command:**

```powershell
# Measure script execution time
Measure-Command {
    # Your code here
    1..1000 | ForEach-Object { $_ * 2 }
}

# Compare approaches
$approach1 = Measure-Command {
    Get-ChildItem C:\Temp | Where-Object { $_.Length -gt 1MB }
}

$approach2 = Measure-Command {
    Get-ChildItem C:\Temp -File | Where-Object { $_.Length -gt 1MB }
}

Write-Host "Approach 1: $($approach1.TotalMilliseconds)ms"
Write-Host "Approach 2: $($approach2.TotalMilliseconds)ms"
```

### 7. Memory Optimization

```powershell
# Monitor memory usage
[System.GC]::GetTotalMemory($false) / 1MB  # Current memory in MB

# Force garbage collection (use sparingly)
[System.GC]::Collect()

# Use streaming instead of loading entire datasets
# SLOW - loads entire file into memory
$lines = Get-Content "huge-file.txt"
$errors = $lines | Select-String "ERROR"

# FAST - streams file line by line
$errors = Select-String -Path "huge-file.txt" -Pattern "ERROR"
```

## Performance Patterns

### Pattern 1: Batch Processing

```powershell
# Process items in batches
$allItems = 1..10000
$batchSize = 100

for ($i = 0; $i -lt $allItems.Count; $i += $batchSize) {
    $batch = $allItems[$i..[Math]::Min($i + $batchSize - 1, $allItems.Count - 1)]

    # Process batch in parallel
    $batch | ForEach-Object -Parallel {
        # Process item
    } -ThrottleLimit 10

    Write-Progress -Activity "Processing" -PercentComplete (($i / $allItems.Count) * 100)
}
```

### Pattern 2: Async Operations

```powershell
# Start background jobs for long-running tasks
$jobs = @()
1..5 | ForEach-Object {
    $jobs += Start-ThreadJob {
        # Long-running operation
        Start-Sleep -Seconds 10
        "Job $using:_ completed"
    }
}

# Wait for all jobs and collect results
$results = $jobs | Wait-Job | Receive-Job
$jobs | Remove-Job
```

### Pattern 3: Caching

```powershell
# Cache expensive lookups
$userCache = @{}

function Get-CachedUser {
    param($UserId)

    if (-not $userCache.ContainsKey($UserId)) {
        # Expensive operation
        $userCache[$UserId] = Get-ADUser -Identity $UserId
    }

    return $userCache[$UserId]
}

# Use cache in loop
foreach ($record in $records) {
    $user = Get-CachedUser -UserId $record.UserId
    # Process with cached user data
}
```

## .NET 9 Performance Features (PowerShell 7.5+)

PowerShell 7.5 built on .NET 9 includes:

- **28% faster** large pipeline processing
- **25% faster** startup time
- **21% lower** memory usage
- **16% faster** web requests
- **Optimized += operator** for arrays (100x faster)

```powershell
# PowerShell 7.5 automatically benefits from:
# - Improved JIT compilation
# - Better garbage collection
# - Optimized array operations
# - Faster string operations

# Check your version
$PSVersionTable.PSVersion  # Should be 7.5+
```

## Quick Performance Checklist

- [ ] Use `ForEach-Object -Parallel` for concurrent operations (PowerShell 7+)
- [ ] Use `-Filter` parameter instead of `Where-Object` when available
- [ ] Avoid `+=` for arrays in loops (use ArrayList or List<T>)
- [ ] Use .NET methods for intensive operations
- [ ] Stream large files instead of loading into memory
- [ ] Measure with `Measure-Command` to verify improvements
- [ ] Cache expensive lookups
- [ ] Use `-ThrottleLimit` appropriately (typically CPU cores * 2)
- [ ] Upgrade to PowerShell 7.5+ for .NET 9 performance benefits

## Example: Complete Optimization

```powershell
# BEFORE (slow)
$results = @()
Get-ChildItem C:\Logs -Recurse | ForEach-Object {
    if ($_.Extension -eq ".log") {
        $content = Get-Content $_.FullName
        $errorCount = ($content | Select-String "ERROR").Count
        $results += [PSCustomObject]@{
            File = $_.Name
            Errors = $errorCount
        }
    }
}
# Takes ~60 seconds for 1000 files

# AFTER (fast)
$results = Get-ChildItem C:\Logs -Recurse -Filter "*.log" |
    ForEach-Object -Parallel {
        $errorCount = (Select-String -Path $_.FullName -Pattern "ERROR").Count
        [PSCustomObject]@{
            File = $_.Name
            Errors = $errorCount
        }
    } -ThrottleLimit 10
# Takes ~6 seconds (10x faster)
```
