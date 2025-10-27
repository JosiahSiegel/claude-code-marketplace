# Terraform Testing Framework

Comprehensive testing for Terraform configurations using Terraform 1.6+ native test framework, integration testing, and unit testing strategies.

## Your Task

You are helping implement comprehensive testing for Terraform infrastructure. Provide testing strategies, test implementation, and CI/CD integration.

## Terraform Native Test Framework (1.6+)

### Overview

**Terraform 1.6+ Test Framework:**
- Native testing built into Terraform CLI
- `terraform test` command
- Test files: `*.tftest.hcl`
- Assertions using `condition` and `error_message`
- Setup/teardown lifecycle
- Variable overrides per test
- Multiple test runs in single file

### Basic Test Structure

```hcl
# tests/basic.tftest.hcl

# Run block - each creates isolated test
run "verify_resource_group" {
  command = plan

  assert {
    condition     = azurerm_resource_group.example.location == "eastus"
    error_message = "Resource group must be in East US region"
  }
}

run "verify_storage_account" {
  command = apply

  assert {
    condition     = azurerm_storage_account.example.account_tier == "Standard"
    error_message = "Storage account must use Standard tier"
  }

  assert {
    condition     = azurerm_storage_account.example.account_replication_type == "LRS"
    error_message = "Storage account must use LRS replication"
  }
}
```

### Running Tests

```bash
# Run all tests
terraform test

# Run specific test file
terraform test tests/basic.tftest.hcl

# Filter tests
terraform test -filter=tests/integration

# Verbose output
terraform test -verbose

# JSON output
terraform test -json

# JUnit XML output (Terraform 1.11+)
terraform test -junit-xml=test-results.xml
```

### Test with Variables

```hcl
# tests/environments.tftest.hcl

variables {
  environment = "dev"
  location    = "eastus"
}

run "dev_environment" {
  command = plan

  assert {
    condition     = azurerm_resource_group.example.tags["Environment"] == var.environment
    error_message = "Environment tag must match variable"
  }
}

run "prod_environment" {
  command = plan

  # Override variables for this run
  variables {
    environment = "prod"
    location    = "westus"
  }

  assert {
    condition     = azurerm_resource_group.example.location == "westus"
    error_message = "Production must be in West US"
  }
}
```

### Test with Mock Providers

```hcl
# tests/with-mocks.tftest.hcl

mock_provider "aws" {
  mock_resource "aws_instance" {
    defaults = {
      ami           = "ami-12345678"
      instance_type = "t2.micro"
    }
  }
}

run "test_with_mock" {
  command = plan

  # This uses mocked AWS provider
  assert {
    condition     = aws_instance.web.instance_type == "t2.micro"
    error_message = "Instance type mismatch"
  }
}
```

### Test with Modules

```hcl
# tests/module-test.tftest.hcl

run "test_module_outputs" {
  command = apply

  module {
    source = "./modules/networking"
  }

  variables {
    vnet_name = "test-vnet"
  }

  assert {
    condition     = output.vnet_id != ""
    error_message = "Module must output VNet ID"
  }

  assert {
    condition     = output.subnet_ids != null
    error_message = "Module must output subnet IDs"
  }
}
```

### Advanced Test Patterns

**Setup and Teardown:**
```hcl
# tests/lifecycle.tftest.hcl

# Setup - runs before tests
run "setup_dependencies" {
  command = apply

  module {
    source = "./tests/fixtures/dependencies"
  }
}

# Actual tests
run "test_main_resources" {
  command = apply

  assert {
    condition     = azurerm_storage_account.example.name != ""
    error_message = "Storage account must exist"
  }
}

# Teardown - runs after tests (automatic with destroy)
```

**Conditional Assertions:**
```hcl
run "conditional_test" {
  command = plan

  assert {
    condition = (
      var.environment == "prod" ?
      azurerm_storage_account.example.account_replication_type == "GRS" :
      azurerm_storage_account.example.account_replication_type == "LRS"
    )
    error_message = "Prod must use GRS, non-prod must use LRS"
  }
}
```

**Multiple Assertions:**
```hcl
run "comprehensive_checks" {
  command = apply

  # Resource exists
  assert {
    condition     = azurerm_storage_account.example != null
    error_message = "Storage account must exist"
  }

  # Encryption enabled
  assert {
    condition     = azurerm_storage_account.example.enable_https_traffic_only == true
    error_message = "HTTPS must be enforced"
  }

  # TLS version
  assert {
    condition     = azurerm_storage_account.example.min_tls_version == "TLS1_2"
    error_message = "Minimum TLS 1.2 required"
  }

  # Tags present
  assert {
    condition     = contains(keys(azurerm_storage_account.example.tags), "Environment")
    error_message = "Environment tag required"
  }
}
```

## Integration Testing with Terratest (Go)

### Installation

```bash
# Install Go
go version

# Create test directory
mkdir -p test
cd test
go mod init terraform-tests

# Install Terratest
go get github.com/gruntwork-io/terratest/modules/terraform
go get github.com/stretchr/testify/assert
```

### Basic Terratest Example

```go
// test/basic_test.go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestAzureStorageAccount(t *testing.T) {
    t.Parallel()

    terraformOptions := &terraform.Options{
        TerraformDir: "../",
        Vars: map[string]interface{}{
            "environment": "test",
            "location":    "eastus",
        },
    }

    // Cleanup
    defer terraform.Destroy(t, terraformOptions)

    // Init and Apply
    terraform.InitAndApply(t, terraformOptions)

    // Validate outputs
    storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")
    assert.NotEmpty(t, storageAccountName)

    resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
    assert.Equal(t, "test-rg", resourceGroupName)
}
```

### Advanced Terratest

```go
// test/advanced_test.go
package test

import (
    "testing"
    "time"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/gruntwork-io/terratest/modules/azure"
    "github.com/stretchr/testify/assert"
)

func TestStorageAccountWithValidation(t *testing.T) {
    t.Parallel()

    terraformOptions := &terraform.Options{
        TerraformDir: "../",
        Vars: map[string]interface{}{
            "environment": "test",
            "location":    "eastus",
        },
        RetryableTerraformErrors: map[string]string{
            ".*": "Retrying due to transient error...",
        },
        MaxRetries:         3,
        TimeBetweenRetries: 5 * time.Second,
    }

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    // Get outputs
    storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")
    resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

    // Validate with Azure SDK
    exists := azure.StorageAccountExists(t, storageAccountName, resourceGroupName, "")
    assert.True(t, exists, "Storage account should exist")

    // Validate properties
    storageAccount := azure.GetStorageAccount(t, storageAccountName, resourceGroupName, "")
    assert.Equal(t, "Standard", storageAccount.Sku.Name)
    assert.True(t, storageAccount.EnableHTTPSTrafficOnly)
}

func TestMultipleEnvironments(t *testing.T) {
    environments := []string{"dev", "staging", "prod"}

    for _, env := range environments {
        env := env // Capture range variable
        t.Run(env, func(t *testing.T) {
            t.Parallel()

            terraformOptions := &terraform.Options{
                TerraformDir: "../",
                Vars: map[string]interface{}{
                    "environment": env,
                },
            }

            defer terraform.Destroy(t, terraformOptions)
            terraform.InitAndApply(t, terraformOptions)

            // Environment-specific validations
            if env == "prod" {
                replicationType := terraform.Output(t, terraformOptions, "replication_type")
                assert.Equal(t, "GRS", replicationType, "Prod must use GRS")
            }
        })
    }
}
```

## Testing Best Practices

### 1. Test Organization

```
terraform-project/
├── main.tf
├── variables.tf
├── outputs.tf
├── tests/
│   ├── unit/
│   │   ├── basic.tftest.hcl
│   │   └── validations.tftest.hcl
│   ├── integration/
│   │   ├── full-stack.tftest.hcl
│   │   └── multi-region.tftest.hcl
│   └── fixtures/
│       └── dependencies/
│           └── main.tf
└── test/
    ├── go.mod
    ├── basic_test.go
    └── integration_test.go
```

### 2. Test Pyramid

```
        ┌─────────────┐
        │  End-to-End │  ← Few, expensive, real resources
        └─────────────┘
      ┌─────────────────┐
      │  Integration    │  ← Some, moderate cost, limited scope
      └─────────────────┘
    ┌─────────────────────┐
    │  Unit / Validation  │  ← Many, cheap, fast, mocked
    └─────────────────────┘
```

### 3. Testing Checklist

**Unit Tests (terraform test):**
- [ ] Resource configurations valid
- [ ] Variables properly validated
- [ ] Outputs correctly defined
- [ ] Conditional logic works
- [ ] Tag requirements met
- [ ] Naming conventions followed

**Integration Tests (Terratest):**
- [ ] Resources actually created
- [ ] Outputs match expectations
- [ ] Cross-resource dependencies work
- [ ] Security configurations applied
- [ ] Networking properly configured
- [ ] IAM/RBAC roles assigned

**Security Tests:**
- [ ] No public access where not needed
- [ ] Encryption enabled
- [ ] HTTPS/TLS enforced
- [ ] Logging enabled
- [ ] IAM follows least privilege

## CI/CD Integration

### GitHub Actions (2025)

```yaml
name: Terraform Tests

on: [pull_request, push]

jobs:
  terraform-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.11.0

      - name: Terraform Init
        run: terraform init

      - name: Terraform Test
        run: terraform test -verbose

      - name: Terraform Test (JUnit)
        if: always()
        run: terraform test -junit-xml=test-results.xml

      - name: Publish Test Results
        uses: EnricoMi/publish-unit-test-result-action@v2
        if: always()
        with:
          files: test-results.xml

  terratest:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Go
        uses: actions/setup-go@v5
        with:
          go-version: '1.21'

      - name: Run Terratest
        working-directory: test
        run: |
          go mod download
          go test -v -timeout 30m
        env:
          ARM_CLIENT_ID: ${{ secrets.ARM_CLIENT_ID }}
          ARM_CLIENT_SECRET: ${{ secrets.ARM_CLIENT_SECRET }}
          ARM_SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTION_ID }}
          ARM_TENANT_ID: ${{ secrets.ARM_TENANT_ID }}
```

### Azure DevOps

```yaml
stages:
- stage: Test
  jobs:
  - job: TerraformTest
    steps:
    - task: TerraformInstaller@0
      inputs:
        terraformVersion: '1.11.0'

    - task: Bash@3
      displayName: 'Terraform Init'
      inputs:
        targetType: 'inline'
        script: terraform init

    - task: Bash@3
      displayName: 'Terraform Test'
      inputs:
        targetType: 'inline'
        script: |
          terraform test -verbose
          terraform test -junit-xml=test-results.xml

    - task: PublishTestResults@2
      condition: always()
      inputs:
        testResultsFormat: 'JUnit'
        testResultsFiles: 'test-results.xml'

  - job: Terratest
    steps:
    - task: GoTool@0
      inputs:
        version: '1.21'

    - task: Go@0
      displayName: 'Run Terratest'
      inputs:
        command: 'test'
        arguments: '-v -timeout 30m'
        workingDirectory: '$(System.DefaultWorkingDirectory)/test'
```

## Example Test Suites

### Complete Unit Test Suite

```hcl
# tests/unit/complete.tftest.hcl

variables {
  environment = "test"
  location    = "eastus"
}

# Test 1: Basic configuration
run "basic_configuration" {
  command = plan

  assert {
    condition     = azurerm_resource_group.example.location == var.location
    error_message = "Resource group location mismatch"
  }

  assert {
    condition     = azurerm_resource_group.example.tags["Environment"] == var.environment
    error_message = "Environment tag not set correctly"
  }
}

# Test 2: Security settings
run "security_settings" {
  command = plan

  assert {
    condition     = azurerm_storage_account.example.enable_https_traffic_only == true
    error_message = "HTTPS must be enforced"
  }

  assert {
    condition     = azurerm_storage_account.example.min_tls_version == "TLS1_2"
    error_message = "Minimum TLS 1.2 required"
  }

  assert {
    condition     = azurerm_storage_account.example.public_network_access_enabled == false
    error_message = "Public network access must be disabled"
  }
}

# Test 3: Naming conventions
run "naming_conventions" {
  command = plan

  assert {
    condition     = can(regex("^[a-z0-9]{3,24}$", azurerm_storage_account.example.name))
    error_message = "Storage account name must follow Azure naming rules"
  }

  assert {
    condition     = length(azurerm_resource_group.example.name) <= 90
    error_message = "Resource group name too long"
  }
}

# Test 4: Production overrides
run "production_settings" {
  command = plan

  variables {
    environment = "prod"
  }

  assert {
    condition     = azurerm_storage_account.example.account_replication_type == "GRS"
    error_message = "Production must use GRS replication"
  }
}
```

### Complete Integration Test (Terratest)

```go
// test/integration_test.go
package test

import (
    "fmt"
    "strings"
    "testing"
    "github.com/gruntwork-io/terratest/modules/azure"
    "github.com/gruntwork-io/terratest/modules/random"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func TestCompleteInfrastructure(t *testing.T) {
    t.Parallel()

    // Generate unique names
    uniqueID := strings.ToLower(random.UniqueId())
    resourceGroupName := fmt.Sprintf("test-rg-%s", uniqueID)

    terraformOptions := &terraform.Options{
        TerraformDir: "../",
        Vars: map[string]interface{}{
            "resource_group_name": resourceGroupName,
            "environment":         "test",
            "location":            "eastus",
        },
        NoColor: true,
    }

    // Cleanup
    defer terraform.Destroy(t, terraformOptions)

    // Deploy
    terraform.InitAndApply(t, terraformOptions)

    // Get outputs
    storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")
    require.NotEmpty(t, storageAccountName)

    // Validate Resource Group
    exists := azure.ResourceGroupExists(t, resourceGroupName, "")
    assert.True(t, exists, "Resource group should exist")

    // Validate Storage Account
    storageAccount := azure.GetStorageAccount(t, storageAccountName, resourceGroupName, "")
    assert.NotNil(t, storageAccount)
    assert.True(t, storageAccount.EnableHTTPSTrafficOnly)
    assert.Equal(t, "TLS1_2", storageAccount.MinimumTLSVersion)

    // Validate Tags
    tags := storageAccount.Tags
    assert.Contains(t, tags, "Environment")
    assert.Equal(t, "test", tags["Environment"])

    // Validate Network Rules
    assert.Equal(t, "Deny", storageAccount.NetworkRuleSet.DefaultAction)
}

func TestMultiRegionDeployment(t *testing.T) {
    regions := []string{"eastus", "westus", "centralus"}

    for _, region := range regions {
        region := region
        t.Run(region, func(t *testing.T) {
            t.Parallel()

            uniqueID := strings.ToLower(random.UniqueId())
            resourceGroupName := fmt.Sprintf("test-%s-%s", region, uniqueID)

            terraformOptions := &terraform.Options{
                TerraformDir: "../",
                Vars: map[string]interface{}{
                    "resource_group_name": resourceGroupName,
                    "location":            region,
                },
            }

            defer terraform.Destroy(t, terraformOptions)
            terraform.InitAndApply(t, terraformOptions)

            // Validate region
            exists := azure.ResourceGroupExists(t, resourceGroupName, "")
            assert.True(t, exists)
        })
    }
}
```

## Testing Tools Comparison

| Tool | Type | Best For | Terraform Version | Learning Curve |
|------|------|----------|-------------------|----------------|
| **terraform test** | Native | Unit tests, fast validation | 1.6+ | Low |
| **Terratest** | Go framework | Integration, real resources | Any | Medium |
| **Kitchen-Terraform** | Ruby | Chef ecosystem | Any | Medium |
| **terraform-compliance** | Python BDD | Policy testing | Any | Low |
| **Checkov** | Python | Security scanning | Any | Low |

## Best Practices Summary

1. **Write tests before/during development** (TDD/BDD)
2. **Use terraform test for fast feedback** (1.6+)
3. **Use Terratest for real resource validation**
4. **Mock external dependencies where possible**
5. **Test multiple environments/configurations**
6. **Integrate testing in CI/CD pipelines**
7. **Maintain test coverage > 80%**
8. **Test security configurations**
9. **Clean up resources after tests**
10. **Version pin test dependencies**

Activate the terraform-expert agent for comprehensive testing guidance.
