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


# Initialize Terraform Project

Initialize a new Terraform project or reinitialize an existing one following industry best practices and platform-specific considerations.

## Your Task

You are helping initialize a Terraform project. Follow these steps systematically:

1. **Assess Current State**:
   - Check if this is a new project or existing one
   - Look for existing Terraform files (*.tf, .terraform/)
   - Identify the platform (Windows/Linux/macOS) for platform-specific instructions
   - Check for existing backend configuration

2. **Gather Requirements**:
   - Ask which cloud provider(s) they're using (Azure/AWS/GCP/other)
   - Determine Terraform version (check `.terraform-version`, `versions.tf`, or ask)
   - Understand their backend preference (local, Azure Storage, S3, GCS, Terraform Cloud)
   - Ask about their environment (single vs multi-environment)

3. **Research Latest Versions**:
   - Use WebSearch to find the latest stable Terraform version if not specified
   - Find current provider versions for their cloud platform(s)
   - Check for any known compatibility issues

4. **Generate Configuration**:
   Create appropriate files:

   **versions.tf**: Required provider configuration with version constraints
   ```hcl
   terraform {
     required_version = ">= 1.0"
     required_providers {
       # Provider configuration based on their needs
     }
   }
   ```

   **backend.tf** (if using remote backend): Backend configuration

   **main.tf**: Basic structure with provider blocks

   **variables.tf**: Common variable definitions

   **outputs.tf**: Standard output structure

   **terraform.tfvars.example**: Example variable values (never with secrets)

   **.gitignore**: Proper Terraform gitignore patterns

5. **Platform-Specific Setup**:

   **Windows**:
   ```powershell
   # Installation via Chocolatey or Scoop
   # Environment setup for provider credentials
   # PowerShell execution context
   ```

   **Linux**:
   ```bash
   # Installation via package manager or direct download
   # Environment variables for credentials
   # Plugin cache configuration
   ```

   **macOS**:
   ```bash
   # Homebrew installation
   # Credential helper setup
   # Path configuration
   ```

6. **Initialize**:
   Provide the appropriate initialization command with explanations:
   ```bash
   terraform init
   # Or with backend configuration:
   terraform init -backend-config="key=value"
   ```

7. **Post-Initialization**:
   - Verify successful initialization
   - Explain the `.terraform/` directory
   - Explain `terraform.lock.hcl` and its importance
   - Suggest next steps (validate, plan)

8. **Best Practices Guidance**:
   - Recommend using version constraints for all providers
   - Suggest setting up pre-commit hooks (terraform fmt, validate, tfsec)
   - Advise on directory structure for modules
   - Recommend documentation standards
   - Suggest CI/CD integration patterns

9. **Security Considerations**:
   - Never commit `.terraform/` directory
   - Never commit `terraform.tfstate` or `*.tfstate.backup`
   - Never commit files with secrets (use .tfvars but not committed)
   - Use secure backend storage with encryption
   - Implement state locking

## Multi-Environment Setup

If initializing for multi-environment:
- Suggest workspace strategy vs directory strategy
- Provide backend configuration per environment
- Explain state isolation approaches
- Show environment-specific tfvars patterns

## Troubleshooting Common Init Issues

Be prepared to help with:
- Provider plugin installation failures (proxy, air-gapped)
- Backend authentication issues (platform-specific)
- Version constraint conflicts
- Lock file conflicts
- Platform-specific path issues (Windows)

## Critical Reminders

- ALWAYS pin provider versions in production
- ALWAYS use remote state backend for teams
- ALWAYS enable state locking
- NEVER commit sensitive information
- CHECK Terraform and provider versions for compatibility

Activate the terraform-expert agent to provide comprehensive guidance for this initialization.
