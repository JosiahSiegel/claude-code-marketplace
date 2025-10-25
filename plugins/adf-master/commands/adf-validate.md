---
description: Validate Azure Data Factory pipelines and datasets against nesting rules, resource limits, and configuration requirements
---

# ADF Validate

## Purpose

Proactively validate Azure Data Factory pipeline JSON files and dataset configurations BEFORE committing changes or deploying to ADF. This command catches validation failures that Microsoft's official @microsoft/azure-data-factory-utilities package does NOT validate, preventing runtime errors and deployment failures.

## When to Use This Command

**PROACTIVELY use this command:**
1. **Before committing** any ADF pipeline or dataset changes to git
2. **After creating** or modifying any pipelines with nested activities
3. **When debugging** ADF pipeline failures related to nesting or configuration
4. **In CI/CD pipelines** as a pre-deployment validation step
5. **Before deploying** to any ADF environment (Dev/Test/Prod)
6. **After bulk operations** like copying/generating multiple pipelines
7. **When working with ForEach, If, Switch, or Until activities**
8. **When configuring** Azure Blob Storage or ADLS datasets

## What This Command Validates

### Activity Nesting Rules (NOT validated by Microsoft's npm package)
- **Prohibited nesting combinations** that will fail at runtime:
  - ForEach → ForEach, Until, Validation (nested loops not allowed)
  - Until → Until, ForEach, Validation (nested loops not allowed)
  - IfCondition → ForEach, If, IfCondition, Switch, Until, Validation (no loops in conditions)
  - Switch → ForEach, If, IfCondition, Switch, Until, Validation (no loops in switch cases)

### Resource Limits
- Pipeline activity count (max 120, warn at 100)
- Pipeline parameter count (max 50)
- Pipeline variable count (max 50)
- ForEach batchCount limit (max 50, warn at 30 in strict mode)

### Variable Scope Violations
- SetVariable in parallel ForEach (not allowed - causes race conditions)
- Proper use of AppendVariable vs SetVariable

### Dataset Configuration Issues
- Missing fileName or wildcardFileName for file-based datasets
- AzureBlobFSLocation missing required fileSystem property
- DelimitedText missing columnDelimiter property
- Type mismatches between Copy activity source/sink and dataset types

### Lookup Activity Limits
- firstRowOnly=false warnings (5000 row and 4 MB limits)

### Blob File Dependencies
- Detects additionalColumns logging pattern requiring static files
- Warns about required blob storage files (like empty.csv)

## Instructions

### Step 1: Determine Pipeline and Dataset Paths

Ask the user where their ADF pipeline and dataset JSON files are located, or attempt to detect common paths:

Common ADF repository structures:
- `pipeline/` - Pipeline JSON files
- `dataset/` - Dataset JSON files
- `linkedService/` - Linked service JSON files

If the user is in an ADF repository, these directories should exist at the root level.

### Step 2: Run the Validation Script

Use PowerShell to execute the validation script from the adf-master plugin:

**Basic validation (default):**
```powershell
${CLAUDE_PLUGIN_ROOT}/scripts/validate-adf-pipelines.ps1
```

**With custom paths:**
```powershell
${CLAUDE_PLUGIN_ROOT}/scripts/validate-adf-pipelines.ps1 -PipelinePath "path/to/pipeline" -DatasetPath "path/to/dataset"
```

**With strict mode (additional warnings):**
```powershell
${CLAUDE_PLUGIN_ROOT}/scripts/validate-adf-pipelines.ps1 -Strict
```

**Full example with all options:**
```powershell
${CLAUDE_PLUGIN_ROOT}/scripts/validate-adf-pipelines.ps1 `
    -PipelinePath "S:\repos\formstax-adf\pipeline" `
    -DatasetPath "S:\repos\formstax-adf\dataset" `
    -Strict
```

### Step 3: Parse and Present Results

The script outputs:
- ✅ **Green** for success/pass messages
- ❌ **Red** for errors (validation failures)
- ⚠️ **Yellow** for warnings (potential issues)
- ℹ️ **Cyan** for informational messages

**Exit codes:**
- `0` = Validation passed (no errors)
- `1` = Validation failed (errors found)

### Step 4: Explain Violations and Provide Solutions

For each error or warning found, explain:

1. **What the violation is** - What rule was broken
2. **Why it matters** - What would happen at runtime
3. **How to fix it** - Specific solution with code examples

**Example explanations:**

**Nesting Violation (ForEach → ForEach):**
```
❌ NESTING VIOLATION: ForEach cannot contain another ForEach activity

Why this matters:
- ADF does not support nested loops at runtime
- Pipeline will fail during execution with cryptic error
- Microsoft's npm validation package does NOT catch this

Solution:
Use Execute Pipeline activity to call a child pipeline:

Parent Pipeline (contains outer ForEach):
- ForEach activity
  └─ Execute Pipeline activity → calls ChildPipeline

Child Pipeline:
- ForEach activity (the inner loop logic)
```

**Variable Scope Violation (SetVariable in parallel ForEach):**
```
❌ VARIABLE SCOPE VIOLATION: SetVariable in parallel ForEach causes race conditions

Why this matters:
- Variables are pipeline-scoped, not ForEach iteration-scoped
- Parallel iterations would overwrite each other's values
- Results in unpredictable behavior and data corruption

Solution 1: Use AppendVariable instead
- AppendVariable is thread-safe for arrays
- Each iteration can safely append values

Solution 2: Set isSequential=true
- Forces ForEach to run one iteration at a time
- SetVariable will work correctly but may be slower
```

**Dataset Configuration Warning (missing fileName):**
```
⚠️ DATASET CONFIGURATION WARNING: folderPath defined but no fileName or wildcardFileName

Why this matters:
- Copy activities will fail with: "File path is a folder, wildcard file name is required"
- Common mistake when working with Azure Blob Storage datasets

Solution:
Add fileName or wildcardFileName to the dataset location:

"location": {
    "type": "AzureBlobStorageLocation",
    "folderPath": "data/input",
    "fileName": "myfile.csv",  // Static file name
    // OR
    "wildcardFileName": "*.csv"  // Pattern matching
}
```

### Step 5: Recommend Next Actions

Based on validation results:

**If errors found (exit code 1):**
1. Fix all errors before committing or deploying
2. Re-run validation after fixes
3. Do NOT proceed with deployment until validation passes

**If only warnings (exit code 0 but warnings present):**
1. Review warnings and assess risk
2. Fix critical warnings (like firstRowOnly=false on large datasets)
3. Document accepted warnings with reasoning
4. Safe to deploy but with caution

**If validation passed (exit code 0, no warnings):**
1. Pipelines are safe to commit
2. Pipelines are safe to deploy
3. Consider adding validation to CI/CD pipeline

### Step 6: Suggest CI/CD Integration

Recommend adding this validation to their CI/CD pipeline:

**GitHub Actions example:**
```yaml
- name: Validate ADF Pipelines
  run: |
    pwsh -File validate-adf-pipelines.ps1 -PipelinePath pipeline -DatasetPath dataset
  shell: pwsh
```

**Azure DevOps example:**
```yaml
- task: PowerShell@2
  displayName: 'Validate ADF Pipelines'
  inputs:
    filePath: 'validate-adf-pipelines.ps1'
    arguments: '-PipelinePath pipeline -DatasetPath dataset'
    pwsh: true
```

## Common Validation Scenarios

### Scenario 1: Pre-Commit Validation
```powershell
# Quick validation before git commit
pwsh -File validate-adf-pipelines.ps1
```

### Scenario 2: Debug Pipeline Failure
```powershell
# Run with strict mode to catch additional issues
pwsh -File validate-adf-pipelines.ps1 -Strict
```

### Scenario 3: Validate Specific Directory
```powershell
# Validate a specific ADF repository
pwsh -File validate-adf-pipelines.ps1 `
    -PipelinePath "C:\repos\my-adf\pipeline" `
    -DatasetPath "C:\repos\my-adf\dataset"
```

### Scenario 4: CI/CD Pipeline Validation
```yaml
# Add to GitHub Actions or Azure DevOps
- name: ADF Validation
  run: |
    pwsh validate-adf-pipelines.ps1 -PipelinePath pipeline -DatasetPath dataset
    if ($LASTEXITCODE -ne 0) { exit 1 }
```

## Platform Notes

- **Windows:** Native PowerShell support
- **Linux/macOS:** Requires PowerShell 7+ (`pwsh` command)
- **CI/CD:** Works in GitHub Actions, Azure DevOps, GitLab CI with PowerShell

## Related Commands

- `/adf-pipeline-create` - Create validated pipelines following nesting rules
- `/adf-pipeline-debug` - Debug pipeline failures with validation insights
- `/adf-troubleshoot` - Troubleshoot common ADF issues including validation failures
- `/adf-cicd-setup` - Setup CI/CD with automated validation

## Best Practices

1. **Always validate before committing** - Catch issues early
2. **Add validation to CI/CD** - Prevent invalid pipelines from deploying
3. **Use strict mode during development** - Catch potential issues early
4. **Re-validate after bulk changes** - Don't assume generated pipelines are valid
5. **Document validation exceptions** - If you must bypass a warning, document why
6. **Share validation results with team** - Help others avoid same mistakes

## Success Criteria

The command is successful when:
1. All validation rules are executed against pipeline and dataset JSON files
2. Results are clearly presented with color-coded output
3. Each error/warning is explained with context and solutions
4. User understands what to fix and how to fix it
5. User knows whether it's safe to commit/deploy
6. Validation is recommended for CI/CD integration
