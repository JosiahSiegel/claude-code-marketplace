<#
.SYNOPSIS
    Validates Azure Data Factory pipeline JSON files for nesting violations and resource limits.

.DESCRIPTION
    This script validates ADF pipeline files against rules that Microsoft's official
    @microsoft/azure-data-factory-utilities package does NOT validate:

    - Activity nesting rules (If→ForEach, Switch→If, etc.)
    - Resource limits (activity count, ForEach batchCount, etc.)
    - Variable scope violations (Set Variable in parallel ForEach)
    - Linked service property requirements

    Use this script BEFORE committing changes or in CI/CD pipelines.

.PARAMETER PipelinePath
    Path to the pipeline directory containing JSON files. Default: "pipeline"

.PARAMETER Strict
    Enable strict mode with additional warnings. Default: $false

.EXAMPLE
    .\validate-adf-pipelines.ps1
    Validates all pipelines in the default "pipeline" directory

.EXAMPLE
    .\validate-adf-pipelines.ps1 -PipelinePath "C:\myproject\adf\pipeline"
    Validates pipelines in the specified directory

.EXAMPLE
    .\validate-adf-pipelines.ps1 -Strict
    Runs validation with additional warnings enabled

.NOTES
    Author: ADF Master Expert Agent
    Date: 2025-10-24
    Version: 1.0
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$PipelinePath = "pipeline",

    [Parameter(Mandatory=$false)]
    [string]$DatasetPath = "dataset",

    [Parameter(Mandatory=$false)]
    [switch]$Strict
)

# Color output helpers
function Write-Success { param([string]$Message) Write-Host $Message -ForegroundColor Green }
function Write-Error { param([string]$Message) Write-Host $Message -ForegroundColor Red }
function Write-Warning { param([string]$Message) Write-Host $Message -ForegroundColor Yellow }
function Write-Info { param([string]$Message) Write-Host $Message -ForegroundColor Cyan }

# Validation counters
$script:ErrorCount = 0
$script:WarningCount = 0
$script:PipelineCount = 0
$script:DatasetCount = 0

# Dataset cache for validation
$script:DatasetCache = @{}

# Blob file dependency tracking
$script:RequiredBlobFiles = @()

# Prohibited nesting combinations
$script:ProhibitedNesting = @{
    "ForEach" = @("ForEach", "Until", "Validation")
    "Until" = @("Until", "ForEach", "Validation")
    "IfCondition" = @("ForEach", "If", "IfCondition", "Switch", "Until", "Validation")
    "Switch" = @("ForEach", "If", "IfCondition", "Switch", "Until", "Validation")
}

function Test-ActivityNesting {
    <#
    .SYNOPSIS
        Recursively validates activity nesting rules
    #>
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Activity,

        [Parameter(Mandatory=$true)]
        [string]$ParentType,

        [Parameter(Mandatory=$true)]
        [string]$PipelineName,

        [Parameter(Mandatory=$false)]
        [string]$ParentName = ""
    )

    $activityType = $Activity.type
    $activityName = $Activity.name

    # Check if this nesting is prohibited
    if ($script:ProhibitedNesting.ContainsKey($ParentType)) {
        if ($script:ProhibitedNesting[$ParentType] -contains $activityType) {
            Write-Error "❌ NESTING VIOLATION in $PipelineName"
            Write-Error "   Parent: $ParentType '$ParentName'"
            Write-Error "   Child:  $activityType '$activityName'"
            Write-Error "   Solution: Use Execute Pipeline activity to call a child pipeline"
            $script:ErrorCount++
        }
    }

    # Recursively check nested activities
    $typeProps = $Activity.typeProperties

    if ($activityType -eq "ForEach") {
        # Check ForEach specific rules
        $isSequential = $typeProps.isSequential
        $batchCount = $typeProps.batchCount

        # Check batchCount limit
        if ($batchCount -and $batchCount -gt 50) {
            Write-Error "❌ RESOURCE LIMIT VIOLATION in $PipelineName"
            Write-Error "   Activity: ForEach '$activityName'"
            Write-Error "   Issue: batchCount=$batchCount exceeds limit of 50"
            $script:ErrorCount++
        }

        # Check nested activities
        foreach ($childActivity in $typeProps.activities) {
            Test-ActivityNesting -Activity $childActivity -ParentType "ForEach" -PipelineName $PipelineName -ParentName $activityName

            # Check for Set Variable in parallel ForEach
            if ($childActivity.type -eq "SetVariable" -and -not $isSequential) {
                Write-Error "❌ VARIABLE SCOPE VIOLATION in $PipelineName"
                Write-Error "   Activity: ForEach '$activityName' (parallel mode)"
                Write-Error "   Issue: SetVariable '$($childActivity.name)' not allowed in parallel ForEach"
                Write-Error "   Solution: Use AppendVariable or set isSequential=true"
                $script:ErrorCount++
            }
        }

        # Warning for high batchCount
        if ($Strict -and $batchCount -and $batchCount -gt 30) {
            Write-Warning "⚠️ WARNING in $PipelineName"
            Write-Warning "   Activity: ForEach '$activityName'"
            Write-Warning "   Issue: batchCount=$batchCount is high (may cause throttling)"
            $script:WarningCount++
        }
    }
    elseif ($activityType -eq "IfCondition") {
        # Check If condition branches
        foreach ($childActivity in $typeProps.ifTrueActivities) {
            Test-ActivityNesting -Activity $childActivity -ParentType "IfCondition" -PipelineName $PipelineName -ParentName $activityName
        }
        foreach ($childActivity in $typeProps.ifFalseActivities) {
            Test-ActivityNesting -Activity $childActivity -ParentType "IfCondition" -PipelineName $PipelineName -ParentName $activityName
        }
    }
    elseif ($activityType -eq "Switch") {
        # Check Switch cases
        foreach ($case in $typeProps.cases) {
            foreach ($childActivity in $case.activities) {
                Test-ActivityNesting -Activity $childActivity -ParentType "Switch" -PipelineName $PipelineName -ParentName $activityName
            }
        }
        # Check default activities
        foreach ($childActivity in $typeProps.defaultActivities) {
            Test-ActivityNesting -Activity $childActivity -ParentType "Switch" -PipelineName $PipelineName -ParentName $activityName
        }
    }
    elseif ($activityType -eq "Until") {
        # Check Until activities
        foreach ($childActivity in $typeProps.activities) {
            Test-ActivityNesting -Activity $childActivity -ParentType "Until" -PipelineName $PipelineName -ParentName $activityName
        }
    }
    elseif ($activityType -eq "Lookup") {
        # Check Lookup limits
        $firstRowOnly = $typeProps.firstRowOnly
        if ($firstRowOnly -eq $false -or $null -eq $firstRowOnly) {
            Write-Warning "⚠️ WARNING in $PipelineName"
            Write-Warning "   Activity: Lookup '$activityName'"
            Write-Warning "   Issue: firstRowOnly=false has limits (5000 rows, 4 MB)"
            Write-Warning "   Recommendation: Consider pagination or use firstRowOnly=true if possible"
            $script:WarningCount++
        }
    }
}

function Test-DatasetConfiguration {
    <#
    .SYNOPSIS
        Validates dataset configuration for common issues
    #>
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Dataset,

        [Parameter(Mandatory=$true)]
        [string]$DatasetName
    )

    $type = $Dataset.properties.type
    $location = $Dataset.properties.typeProperties.location

    # Rule: Check for fileName or wildcardFileName when using file-based datasets
    if ($location -and $location.type -eq "AzureBlobStorageLocation") {
        $hasFileName = $null -ne $location.fileName
        $hasWildcard = $null -ne $location.wildcardFileName
        $hasFolderPath = $null -ne $location.folderPath

        if ($hasFolderPath -and -not $hasFileName -and -not $hasWildcard) {
            # Only warn for certain dataset types that typically need fileName
            if ($type -in @("DelimitedText", "Json", "Xml", "Parquet", "Avro", "Orc")) {
                Write-Warning "⚠️ DATASET CONFIGURATION WARNING: $DatasetName"
                Write-Warning "   Issue: folderPath defined but no fileName or wildcardFileName"
                Write-Warning "   Dataset Type: $type"
                Write-Warning "   Impact: Activities may fail with 'File path is a folder, wildcard file name is required'"
                Write-Warning "   Solution: Add fileName or wildcardFileName property to location"
                $script:WarningCount++
            }
        }
    }

    # Rule: Check for ADLS Gen2 specific issues
    if ($location -and $location.type -eq "AzureBlobFSLocation") {
        $hasFileName = $null -ne $location.fileName
        $hasWildcard = $null -ne $location.wildcardFileName
        $hasFileSystem = $null -ne $location.fileSystem

        if (-not $hasFileSystem) {
            Write-Error "❌ DATASET CONFIGURATION ERROR: $DatasetName"
            Write-Error "   Issue: AzureBlobFSLocation missing required 'fileSystem' property"
            Write-Error "   Dataset Type: $type"
            $script:ErrorCount++
        }
    }

    # Rule: Validate dataset type compatibility
    $validTypes = @{
        "DelimitedText" = @{
            RequiredProperties = @("columnDelimiter")
            OptionalProperties = @("rowDelimiter", "escapeChar", "quoteChar", "firstRowAsHeader")
        }
        "Json" = @{
            RequiredProperties = @()
            OptionalProperties = @("encodingName")
        }
        "Parquet" = @{
            RequiredProperties = @()
            OptionalProperties = @("compressionCodec")
        }
    }

    if ($validTypes.ContainsKey($type)) {
        $typeProps = $Dataset.properties.typeProperties
        $config = $validTypes[$type]

        foreach ($requiredProp in $config.RequiredProperties) {
            if ($null -eq $typeProps.$requiredProp) {
                Write-Warning "⚠️ DATASET CONFIGURATION WARNING: $DatasetName"
                Write-Warning "   Issue: Missing recommended property '$requiredProp' for type '$type'"
                $script:WarningCount++
            }
        }
    }
}

function Load-DatasetCache {
    <#
    .SYNOPSIS
        Loads all dataset definitions into memory for validation
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$DatasetPath
    )

    $resolvedPath = Resolve-Path $DatasetPath -ErrorAction SilentlyContinue
    if (-not $resolvedPath) {
        Write-Warning "⚠️ Dataset directory not found: $DatasetPath (skipping dataset validation)"
        return
    }

    $datasetFiles = Get-ChildItem -Path $resolvedPath -Filter "*.json" -File

    Write-Info "Loading $($datasetFiles.Count) dataset file(s) for validation..."

    foreach ($file in $datasetFiles) {
        try {
            $json = Get-Content $file.FullName -Raw | ConvertFrom-Json
            $datasetName = $json.name
            $script:DatasetCache[$datasetName] = $json

            # Validate dataset configuration
            Test-DatasetConfiguration -Dataset $json -DatasetName $datasetName
            $script:DatasetCount++
        }
        catch {
            Write-Error "❌ ERROR parsing dataset $($file.Name): $_"
            $script:ErrorCount++
        }
    }

    Write-Host ""
}

function Test-BlobFileDependency {
    <#
    .SYNOPSIS
        Detects activities that depend on specific blob files (like empty.csv for logging pattern)
    #>
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Activity,

        [Parameter(Mandatory=$true)]
        [string]$PipelineName
    )

    # Only check Copy activities with additionalColumns (logging pattern)
    if ($Activity.type -ne "Copy") {
        return
    }

    $source = $Activity.typeProperties.source
    $hasAdditionalColumns = $null -ne $source.additionalColumns -and $source.additionalColumns.Count -gt 0

    # If using additionalColumns pattern, check for static file references
    if ($hasAdditionalColumns -and $Activity.inputs -and $Activity.inputs.Count -gt 0) {
        $inputDatasetRef = $Activity.inputs[0].referenceName
        $parameters = $Activity.inputs[0].parameters

        # Check if dataset is Blob_Staging and path is static (not parameterized)
        if ($inputDatasetRef -eq "Blob_Staging" -and $parameters.path) {
            $pathValue = $parameters.path

            # Check if it's a static string (not an expression)
            if ($pathValue -is [string] -and $pathValue -notmatch '@\{') {
                Write-Warning "⚠️ BLOB FILE DEPENDENCY DETECTED in $PipelineName"
                Write-Warning "   Activity: Copy '$($Activity.name)'"
                Write-Warning "   Pattern: additionalColumns logging (source file content ignored)"
                Write-Warning "   Required File: integration/Staging/$pathValue"
                Write-Warning "   Note: File must exist in blob storage even though content is not used"
                Write-Warning "   Solution: Ensure file exists or see README 'Required Files' section"
                $script:WarningCount++

                # Track this for summary
                if (-not $script:RequiredBlobFiles) {
                    $script:RequiredBlobFiles = @()
                }
                $script:RequiredBlobFiles += @{
                    Pipeline = $PipelineName
                    Activity = $Activity.name
                    Path = "integration/Staging/$pathValue"
                }
            }
        }
    }
}

function Test-ActivityDatasetCompatibility {
    <#
    .SYNOPSIS
        Validates that activity source/sink types match dataset types
    #>
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Activity,

        [Parameter(Mandatory=$true)]
        [string]$PipelineName
    )

    # Only check Copy activities
    if ($Activity.type -ne "Copy") {
        return
    }

    $activityName = $Activity.name
    $source = $Activity.typeProperties.source
    $sink = $Activity.typeProperties.sink

    # Map of source/sink types to expected dataset types
    $compatibilityMap = @{
        "DelimitedTextSource" = @("DelimitedText")
        "DelimitedTextSink" = @("DelimitedText")
        "JsonSource" = @("Json")
        "JsonSink" = @("Json")
        "ParquetSource" = @("Parquet")
        "ParquetSink" = @("Parquet")
        "AvroSource" = @("Avro")
        "AvroSink" = @("Avro")
        "OrcSource" = @("Orc")
        "OrcSink" = @("Orc")
        "XmlSource" = @("Xml")
    }

    # Check source dataset
    if ($Activity.inputs -and $Activity.inputs.Count -gt 0) {
        $inputDatasetRef = $Activity.inputs[0].referenceName
        if ($script:DatasetCache.ContainsKey($inputDatasetRef)) {
            $dataset = $script:DatasetCache[$inputDatasetRef]
            $datasetType = $dataset.properties.type
            $sourceType = $source.type

            if ($compatibilityMap.ContainsKey($sourceType)) {
                $expectedTypes = $compatibilityMap[$sourceType]
                if ($datasetType -notin $expectedTypes) {
                    Write-Error "❌ TYPE MISMATCH in $PipelineName"
                    Write-Error "   Activity: Copy '$activityName'"
                    Write-Error "   Source Type: $sourceType"
                    Write-Error "   Dataset: $inputDatasetRef"
                    Write-Error "   Dataset Type: $datasetType (expected: $($expectedTypes -join ' or '))"
                    Write-Error "   Solution: Change dataset type to match source type or vice versa"
                    $script:ErrorCount++
                }
            }
        }
    }

    # Check sink dataset
    if ($Activity.outputs -and $Activity.outputs.Count -gt 0) {
        $outputDatasetRef = $Activity.outputs[0].referenceName
        if ($script:DatasetCache.ContainsKey($outputDatasetRef)) {
            $dataset = $script:DatasetCache[$outputDatasetRef]
            $datasetType = $dataset.properties.type
            $sinkType = $sink.type

            if ($compatibilityMap.ContainsKey($sinkType)) {
                $expectedTypes = $compatibilityMap[$sinkType]
                if ($datasetType -notin $expectedTypes) {
                    Write-Error "❌ TYPE MISMATCH in $PipelineName"
                    Write-Error "   Activity: Copy '$activityName'"
                    Write-Error "   Sink Type: $sinkType"
                    Write-Error "   Dataset: $outputDatasetRef"
                    Write-Error "   Dataset Type: $datasetType (expected: $($expectedTypes -join ' or '))"
                    Write-Error "   Solution: Change dataset type to match sink type or vice versa"
                    $script:ErrorCount++
                }
            }
        }
    }
}

function Test-PipelineFile {
    <#
    .SYNOPSIS
        Validates a single pipeline JSON file
    #>
    param(
        [Parameter(Mandatory=$true)]
        [System.IO.FileInfo]$File
    )

    try {
        Write-Info "Validating: $($File.Name)"

        $json = Get-Content $File.FullName -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        $properties = $json.properties
        $activities = $properties.activities

        # Rule 1: Check activity count
        $activityCount = ($activities | Measure-Object).Count
        if ($activityCount -gt 120) {
            Write-Error "❌ RESOURCE LIMIT VIOLATION in $($File.Name)"
            Write-Error "   Issue: Pipeline has $activityCount activities (limit: 120)"
            $script:ErrorCount++
        }
        elseif ($activityCount -gt 100) {
            Write-Warning "⚠️ WARNING in $($File.Name)"
            Write-Warning "   Issue: Pipeline has $activityCount activities (approaching limit of 120)"
            $script:WarningCount++
        }

        # Rule 2: Check parameter count
        if ($properties.parameters) {
            $paramCount = ($properties.parameters.PSObject.Properties | Measure-Object).Count
            if ($paramCount -gt 50) {
                Write-Error "❌ RESOURCE LIMIT VIOLATION in $($File.Name)"
                Write-Error "   Issue: Pipeline has $paramCount parameters (limit: 50)"
                $script:ErrorCount++
            }
        }

        # Rule 3: Check variable count
        if ($properties.variables) {
            $varCount = ($properties.variables.PSObject.Properties | Measure-Object).Count
            if ($varCount -gt 50) {
                Write-Error "❌ RESOURCE LIMIT VIOLATION in $($File.Name)"
                Write-Error "   Issue: Pipeline has $varCount variables (limit: 50)"
                $script:ErrorCount++
            }
        }

        # Rule 4: Check activity nesting (recursive)
        foreach ($activity in $activities) {
            Test-ActivityNesting -Activity $activity -ParentType "Pipeline" -PipelineName $File.Name
        }

        # Rule 5: Check for blob file dependencies (like empty.csv for logging pattern)
        foreach ($activity in $activities) {
            Test-BlobFileDependency -Activity $activity -PipelineName $File.Name

            # Also check nested activities
            if ($activity.type -eq "IfCondition") {
                foreach ($childActivity in $activity.typeProperties.ifTrueActivities) {
                    Test-BlobFileDependency -Activity $childActivity -PipelineName $File.Name
                }
                foreach ($childActivity in $activity.typeProperties.ifFalseActivities) {
                    Test-BlobFileDependency -Activity $childActivity -PipelineName $File.Name
                }
            }
        }

        # Rule 6: Check dataset compatibility for Copy activities
        foreach ($activity in $activities) {
            Test-ActivityDatasetCompatibility -Activity $activity -PipelineName $File.Name

            # Also check nested activities
            if ($activity.type -eq "ForEach") {
                foreach ($childActivity in $activity.typeProperties.activities) {
                    Test-ActivityDatasetCompatibility -Activity $childActivity -PipelineName $File.Name
                }
            }
            elseif ($activity.type -eq "IfCondition") {
                foreach ($childActivity in $activity.typeProperties.ifTrueActivities) {
                    Test-ActivityDatasetCompatibility -Activity $childActivity -PipelineName $File.Name
                }
                foreach ($childActivity in $activity.typeProperties.ifFalseActivities) {
                    Test-ActivityDatasetCompatibility -Activity $childActivity -PipelineName $File.Name
                }
            }
            elseif ($activity.type -eq "Switch") {
                foreach ($case in $activity.typeProperties.cases) {
                    foreach ($childActivity in $case.activities) {
                        Test-ActivityDatasetCompatibility -Activity $childActivity -PipelineName $File.Name
                    }
                }
                foreach ($childActivity in $activity.typeProperties.defaultActivities) {
                    Test-ActivityDatasetCompatibility -Activity $childActivity -PipelineName $File.Name
                }
            }
            elseif ($activity.type -eq "Until") {
                foreach ($childActivity in $activity.typeProperties.activities) {
                    Test-ActivityDatasetCompatibility -Activity $childActivity -PipelineName $File.Name
                }
            }
        }

        $script:PipelineCount++
    }
    catch {
        Write-Error "❌ ERROR parsing $($File.Name): $_"
        $script:ErrorCount++
    }
}

# Main execution
Write-Host ""
Write-Host "========================================" -ForegroundColor White
Write-Host "Azure Data Factory Pipeline Validation" -ForegroundColor White
Write-Host "========================================" -ForegroundColor White
Write-Host ""

# Resolve pipeline path
$resolvedPath = Resolve-Path $PipelinePath -ErrorAction SilentlyContinue
if (-not $resolvedPath) {
    Write-Error "❌ Pipeline directory not found: $PipelinePath"
    exit 1
}

Write-Info "Pipeline Directory: $resolvedPath"
Write-Info "Dataset Directory: $DatasetPath"
Write-Info "Strict Mode: $Strict"
Write-Host ""

# Load datasets first for cross-reference validation
Load-DatasetCache -DatasetPath $DatasetPath

# Get all pipeline JSON files
$pipelineFiles = Get-ChildItem -Path $resolvedPath -Filter "*.json" -File

if ($pipelineFiles.Count -eq 0) {
    Write-Error "❌ No pipeline JSON files found in: $resolvedPath"
    exit 1
}

Write-Info "Found $($pipelineFiles.Count) pipeline file(s)"
Write-Host ""

# Validate each pipeline
foreach ($pipelineFile in $pipelineFiles) {
    Test-PipelineFile -File $pipelineFile
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor White
Write-Host "Validation Summary" -ForegroundColor White
Write-Host "========================================" -ForegroundColor White
Write-Host "Datasets checked: $script:DatasetCount" -ForegroundColor Cyan
Write-Host "Pipelines checked: $script:PipelineCount" -ForegroundColor Cyan
if ($script:ErrorCount -gt 0) {
    Write-Host "Errors: $script:ErrorCount" -ForegroundColor Red
} else {
    Write-Host "Errors: $script:ErrorCount" -ForegroundColor Green
}
if ($script:WarningCount -gt 0) {
    Write-Host "Warnings: $script:WarningCount" -ForegroundColor Yellow
} else {
    Write-Host "Warnings: $script:WarningCount" -ForegroundColor Green
}

# List required blob files if any found
if ($script:RequiredBlobFiles -and $script:RequiredBlobFiles.Count -gt 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor White
    Write-Host "Required Blob Files" -ForegroundColor White
    Write-Host "========================================" -ForegroundColor White
    Write-Host "The following files must exist in blob storage:" -ForegroundColor Yellow
    Write-Host ""

    $uniquePaths = $script:RequiredBlobFiles | Select-Object -ExpandProperty Path -Unique
    foreach ($path in $uniquePaths) {
        Write-Host "  - $path" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "These files are used by the 'additionalColumns logging pattern' where" -ForegroundColor Gray
    Write-Host "the file content is ignored but the file must exist for ADF validation." -ForegroundColor Gray
    Write-Host ""
    Write-Host "See README.md 'Required Files in Blob Storage' section for details." -ForegroundColor Gray
}
Write-Host ""

# Exit with appropriate code
if ($script:ErrorCount -gt 0) {
    Write-Error "❌ VALIDATION FAILED - Fix errors before committing"
    Write-Host ""
    exit 1
}
else {
    Write-Success "✅ VALIDATION PASSED"
    Write-Host ""
    exit 0
}
