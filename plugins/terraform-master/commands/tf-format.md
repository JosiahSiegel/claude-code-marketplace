# Format and Lint Terraform Code

Format Terraform code to follow HCL canonical style and apply linting best practices across all platforms.

## Your Task

You are helping format and lint Terraform configuration files. Follow these steps:

1. **Assess Current State**:
   - Check if this is a single file, directory, or entire project
   - Identify platform (Windows/Linux/macOS) for command syntax
   - Determine if this is for local development or CI/CD

2. **Basic Formatting** (terraform fmt):

   **Check Format** (dry-run):
   ```bash
   # Check single file
   terraform fmt -check main.tf

   # Check all files in current directory
   terraform fmt -check

   # Recursively check all subdirectories
   terraform fmt -check -recursive

   # Show what would change (diff)
   terraform fmt -diff
   ```

   **Apply Formatting**:
   ```bash
   # Format current directory
   terraform fmt

   # Format recursively
   terraform fmt -recursive

   # Format specific file
   terraform fmt variables.tf

   # Show changes while formatting
   terraform fmt -diff -recursive
   ```

3. **Platform-Specific Scripts**:

   **Windows PowerShell**:
   ```powershell
   # Format all Terraform files
   function Format-Terraform {
       param(
           [switch]$Check,
           [switch]$Recursive
       )

       $params = @()
       if ($Check) { $params += "-check" }
       if ($Recursive) { $params += "-recursive" }
       $params += "-diff"

       Write-Host "Formatting Terraform files..." -ForegroundColor Cyan
       terraform fmt @params

       if ($LASTEXITCODE -ne 0 -and $Check) {
           Write-Host "Formatting issues found. Run without -Check to fix." -ForegroundColor Yellow
           exit 1
       }
       Write-Host "Formatting complete!" -ForegroundColor Green
   }

   # Usage:
   Format-Terraform -Recursive
   Format-Terraform -Check -Recursive  # For CI/CD
   ```

   **Linux/macOS Bash**:
   ```bash
   #!/bin/bash
   # format-terraform.sh

   set -e

   CHECK_ONLY=false
   RECURSIVE=true

   while [[ $# -gt 0 ]]; do
       case $1 in
           --check) CHECK_ONLY=true; shift ;;
           --no-recursive) RECURSIVE=false; shift ;;
           *) echo "Unknown option: $1"; exit 1 ;;
       esac
   done

   ARGS="-diff"
   [[ "$CHECK_ONLY" == true ]] && ARGS="$ARGS -check"
   [[ "$RECURSIVE" == true ]] && ARGS="$ARGS -recursive"

   echo "Formatting Terraform files..."
   terraform fmt $ARGS

   if [[ $? -ne 0 && "$CHECK_ONLY" == true ]]; then
       echo "Formatting issues found. Run without --check to fix."
       exit 1
   fi

   echo "Formatting complete!"
   ```

4. **CI/CD Integration**:

   **Azure DevOps**:
   ```yaml
   - task: TerraformCLI@0
     displayName: 'Terraform Format Check'
     inputs:
       command: 'custom'
       customCommand: 'fmt'
       workingDirectory: '$(System.DefaultWorkingDirectory)/terraform'
       commandOptions: '-check -recursive -diff'

   # Or using bash script
   - task: Bash@3
     displayName: 'Terraform Format Check'
     inputs:
       targetType: 'inline'
       script: |
         if ! terraform fmt -check -recursive; then
           echo "##vso[task.logissue type=error]Terraform files are not formatted correctly"
           echo "##vso[task.complete result=Failed;]"
           exit 1
         fi
   ```

   **GitHub Actions**:
   ```yaml
   - name: Terraform Format Check
     run: |
       terraform fmt -check -recursive
     continue-on-error: false

   # With automatic fixes in PR
   - name: Terraform Format
     run: terraform fmt -recursive

   - name: Commit Formatting Changes
     if: github.event_name == 'pull_request'
     run: |
       git config --local user.email "action@github.com"
       git config --local user.name "GitHub Action"
       git diff --quiet && git diff --staged --quiet || (
         git add -A
         git commit -m "Auto-format Terraform files [skip ci]"
         git push
       )
   ```

   **GitLab CI**:
   ```yaml
   terraform:format:
     stage: validate
     script:
       - terraform fmt -check -recursive -diff
     allow_failure: false

   terraform:format:fix:
     stage: validate
     script:
       - terraform fmt -recursive
       - git diff --exit-code || (echo "Formatting needed" && exit 1)
     only:
       - merge_requests
   ```

5. **Pre-Commit Hooks**:

   **Using pre-commit framework**:
   ```yaml
   # .pre-commit-config.yaml
   repos:
     - repo: https://github.com/antonbabenko/pre-commit-terraform
       rev: v1.86.0
       hooks:
         - id: terraform_fmt
           args:
             - --args=-diff
         - id: terraform_validate
         - id: terraform_docs
           args:
             - --hook-config=--path-to-file=README.md
             - --hook-config=--add-to-existing-file=true
         - id: terraform_tfsec
           args:
             - --args=--minimum-severity=MEDIUM
   ```

   **Git hook (manual)**:
   ```bash
   # .git/hooks/pre-commit
   #!/bin/bash

   echo "Running Terraform fmt check..."
   terraform fmt -check -recursive

   if [ $? -ne 0 ]; then
       echo "Terraform files are not formatted correctly."
       echo "Please run: terraform fmt -recursive"
       exit 1
   fi

   echo "Terraform formatting check passed!"
   ```

6. **VS Code Integration**:

   **settings.json**:
   ```json
   {
     "[terraform]": {
       "editor.defaultFormatter": "hashicorp.terraform",
       "editor.formatOnSave": true,
       "editor.formatOnSaveMode": "file"
     },
     "terraform.languageServer.enable": true,
     "terraform.experimentalFeatures.validateOnSave": true
   }
   ```

   **extensions.json**:
   ```json
   {
     "recommendations": [
       "hashicorp.terraform",
       "hashicorp.hcl"
     ]
   }
   ```

7. **Additional Linting**:

   **TFLint** (Advanced Terraform Linter):
   ```bash
   # Install TFLint
   # Windows: choco install tflint
   # macOS: brew install tflint
   # Linux: curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

   # Initialize TFLint
   tflint --init

   # Run linting
   tflint

   # With specific ruleset
   tflint --config .tflint.hcl

   # Recursive linting
   tflint --recursive
   ```

   **.tflint.hcl** (Configuration):
   ```hcl
   plugin "terraform" {
     enabled = true
     preset  = "recommended"
   }

   plugin "azurerm" {
     enabled = true
     version = "0.25.0"
     source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
   }

   plugin "aws" {
     enabled = true
     version = "0.29.0"
     source  = "github.com/terraform-linters/tflint-ruleset-aws"
   }

   rule "terraform_deprecated_index" {
     enabled = true
   }

   rule "terraform_unused_declarations" {
     enabled = true
   }

   rule "terraform_comment_syntax" {
     enabled = true
   }

   rule "terraform_documented_variables" {
     enabled = true
   }

   rule "terraform_typed_variables" {
     enabled = true
   }

   rule "terraform_naming_convention" {
     enabled = true
     format  = "snake_case"
   }
   ```

8. **Custom Formatting Rules**:

   While `terraform fmt` handles standard formatting, enforce additional style through code review:

   **Variable Organization**:
   ```hcl
   # Good: Variables grouped logically
   # Network variables
   variable "vnet_address_space" {}
   variable "subnet_prefixes" {}

   # Compute variables
   variable "vm_size" {}
   variable "vm_count" {}
   ```

   **Resource Naming**:
   ```hcl
   # Good: Descriptive, snake_case names
   resource "azurerm_resource_group" "web_application" {}

   # Bad: Abbreviated, unclear names
   resource "azurerm_resource_group" "rg1" {}
   ```

   **Comments**:
   ```hcl
   # Good: Explain WHY, not WHAT
   # Using Standard SKU for zone redundancy in production
   sku = "Standard"

   # Bad: Obvious comments
   # Set SKU to Standard
   sku = "Standard"
   ```

9. **Formatting Standards Checklist**:

   - [ ] Indentation is 2 spaces (enforced by terraform fmt)
   - [ ] No trailing whitespace (enforced by terraform fmt)
   - [ ] Files end with single newline (enforced by terraform fmt)
   - [ ] Attributes before blocks (enforced by terraform fmt)
   - [ ] Variables have descriptions
   - [ ] Variables have types
   - [ ] Variables have validation where appropriate
   - [ ] Outputs have descriptions
   - [ ] Resources follow naming convention (snake_case)
   - [ ] Comments explain complex logic
   - [ ] No commented-out code in version control

10. **Troubleshooting Format Issues**:

    **Issue: Files keep getting reformatted differently**
    ```bash
    # Check Terraform version consistency
    terraform version

    # Ensure same version in CI and locally
    # Use .terraform-version file or version constraint
    ```

    **Issue: Line ending differences (Windows)**
    ```bash
    # Configure git to handle line endings
    git config core.autocrlf input

    # Add .gitattributes
    echo "*.tf text eol=lf" > .gitattributes
    echo "*.tfvars text eol=lf" >> .gitattributes
    ```

    **Issue: Formatting breaking on Unicode characters**
    ```bash
    # Ensure files are UTF-8 encoded
    # Set editor to use UTF-8 without BOM
    ```

## Formatting Best Practices

1. **Always format before committing**:
   ```bash
   terraform fmt -recursive && git add -A && git commit -m "Your message"
   ```

2. **Use pre-commit hooks** to enforce formatting automatically

3. **Configure CI/CD** to reject unformatted code

4. **Use consistent Terraform versions** across team and CI/CD

5. **Configure editor** to format on save

6. **Run TFLint** for additional style enforcement

7. **Document exceptions** when deviating from standard formatting

## Critical Reminders

- ✅ ALWAYS run `terraform fmt -recursive` before committing
- ✅ CONFIGURE pre-commit hooks to automate formatting
- ✅ SET UP CI/CD to enforce formatting standards
- ✅ USE consistent Terraform versions across environments
- ✅ CONFIGURE line endings properly (.gitattributes)
- ⚠️ NEVER commit unformatted code
- ⚠️ ENSURE team uses same Terraform version for formatting

Activate the terraform-expert agent for advanced formatting guidance and troubleshooting.
