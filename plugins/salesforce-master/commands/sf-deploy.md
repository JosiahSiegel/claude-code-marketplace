---
description: Deploy metadata, manage change sets, use SFDX CLI, and implement CI/CD for Salesforce
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

# Salesforce Deployment and Metadata Management

## Purpose
Guide Salesforce deployments including change sets, metadata API, SFDX CLI, CI/CD pipelines, and best practices for moving changes between environments (dev → test → staging → production).

## Instructions

### Step 1: Choose Deployment Method

**Deployment Method Selection**:
| Method | Use Case | Best For | Limitations |
|--------|----------|----------|-------------|
| Change Sets | Simple deployments | Admins, declarative changes | No version control, sequential envs only |
| Metadata API | Programmatic deployments | Automated processes | Requires coding |
| SFDX CLI | Modern DevOps | CI/CD, version control | Learning curve |
| Managed Packages | ISV distribution | AppExchange apps | Restricted modifications |
| Unlocked Packages | Modular development | Large orgs, teams | Complex setup |

### Step 2: Salesforce DX (SFDX) CLI Deployment

**Prerequisites**:
- Install Salesforce CLI: `npm install -g @salesforce/cli`
- Authenticate org: `sf org login web --alias myOrg`
- Create SFDX project: `sf project generate --name myProject`

**Windows/Git Bash Path Compatibility**:

When using Salesforce CLI on Windows with Git Bash/MINGW, be aware of automatic path conversion behavior:

**Shell Detection**:
```bash
# Detect if running in Git Bash/MINGW
if [ -n "$MSYSTEM" ]; then
    echo "Running in Git Bash/MINGW: $MSYSTEM"
    # Use Windows-style paths or disable path conversion
fi

# Check shell type
case "$(uname -s)" in
    MINGW64*|MINGW32*) echo "Git Bash 64/32-bit" ;;
    MSYS*) echo "MSYS" ;;
    Darwin*) echo "macOS" ;;
    Linux*) echo "Linux" ;;
esac
```

**Path Conversion Issues & Solutions**:

1. **Disable Path Conversion** (when SF CLI expects exact paths):
   ```bash
   # Disable all path conversion for this command
   MSYS_NO_PATHCONV=1 sf project deploy start --source-dir force-app

   # Disable for entire script
   export MSYS_NO_PATHCONV=1
   sf project deploy start --source-dir force-app
   ```

2. **Use Relative Paths** (Git Bash handles these correctly):
   ```bash
   # Relative paths work reliably
   sf project deploy start --source-dir ./force-app
   sf project retrieve start --manifest ./manifest/package.xml
   ```

3. **Backslashes in Scripts** (Windows native paths):
   ```bash
   # Use backslashes for Windows paths in Git Bash
   sf project deploy start --source-dir "C:\projects\mysfproject\force-app"

   # Or convert using cygpath
   WIN_PATH="C:\projects\mysfproject\force-app"
   UNIX_PATH=$(cygpath -u "$WIN_PATH")
   sf project deploy start --source-dir "$UNIX_PATH"
   ```

4. **Manifest Files** (package.xml paths):
   ```bash
   # Always use forward slashes in package.xml (Salesforce standard)
   # Git Bash converts file paths correctly
   sf project deploy start --manifest manifest/package.xml

   # Avoid: --manifest C:\path\package.xml (may cause issues)
   # Use: --manifest C:/path/package.xml or relative paths
   ```

**Cross-Platform Deployment Script Pattern**:
```bash
#!/bin/bash

# Detect operating system and shell
detect_environment() {
    case "$(uname -s)" in
        MINGW*|MSYS*)
            export IS_WINDOWS=1
            export IS_GIT_BASH=1
            echo "Detected: Windows Git Bash"
            ;;
        Linux*)
            export IS_LINUX=1
            echo "Detected: Linux"
            ;;
        Darwin*)
            export IS_MACOS=1
            echo "Detected: macOS"
            ;;
    esac
}

# Convert paths if needed
normalize_path() {
    local path=$1
    if [ -n "$IS_GIT_BASH" ]; then
        # Use relative paths or cygpath for Windows
        echo "$path" | sed 's|\\|/|g'
    else
        echo "$path"
    fi
}

# Deploy with proper path handling
deploy_to_salesforce() {
    local source_dir=$(normalize_path "$1")
    local target_org="$2"

    echo "Deploying from: $source_dir"

    # Disable path conversion for Git Bash
    if [ -n "$IS_GIT_BASH" ]; then
        export MSYS_NO_PATHCONV=1
    fi

    sf project deploy start \
        --source-dir "$source_dir" \
        --target-org "$target_org" \
        --test-level RunLocalTests
}

# Main
detect_environment
deploy_to_salesforce "./force-app" "my-org-alias"
```

**SFDX Project Structure**:
```
myProject/
├── sfdx-project.json          # Project configuration
├── config/
│   └── project-scratch-def.json  # Scratch org definition
├── force-app/                 # Source code
│   └── main/
│       └── default/
│           ├── classes/
│           ├── triggers/
│           ├── objects/
│           ├── lwc/
│           └── ...
└── manifest/
    └── package.xml            # Metadata package definition
```

**Common SFDX Commands**:

**Retrieve Metadata from Org**:
```bash
# Retrieve specific metadata
sf project retrieve start --metadata ApexClass:MyClass,CustomObject:MyObject__c

# Retrieve from manifest
sf project retrieve start --manifest manifest/package.xml

# Retrieve source from org
sf project retrieve start --source-dir force-app/main/default/classes
```

**Deploy Metadata to Org**:
```bash
# Deploy all source
sf project deploy start --source-dir force-app

# Deploy specific metadata
sf project deploy start --metadata ApexClass:MyClass

# Validate deployment (check-only)
sf project deploy start --source-dir force-app --test-level RunLocalTests --dry-run

# Quick deploy (use previously validated deployment)
sf project deploy quick --job-id 0Af...

# Deploy with specific tests
sf project deploy start --source-dir force-app --test-level RunSpecifiedTests --tests MyTestClass,AnotherTestClass
```

**Scratch Org Management**:
```bash
# Create scratch org
sf org create scratch --definition-file config/project-scratch-def.json --alias myScratchOrg --set-default

# Push source to scratch org
sf project deploy start --source-dir force-app --target-org myScratchOrg

# Pull changes from scratch org
sf project retrieve start --target-org myScratchOrg

# Open scratch org
sf org open --target-org myScratchOrg

# Delete scratch org
sf org delete scratch --target-org myScratchOrg
```

### Step 3: Change Set Deployment

**Outbound Change Set (Source Org)**:
1. Setup → Outbound Change Sets → New
2. Add components (Apex classes, custom objects, fields, etc.)
3. Add related dependencies (profiles, permission sets)
4. Upload to target org
5. Target org must be in Deployment Settings

**Inbound Change Set (Target Org)**:
1. Setup → Inbound Change Sets
2. Review components
3. Validate deployment
4. Deploy (if validation passes)
5. Run tests (if production)

**Change Set Limitations**:
- No version control
- Sequential deployment path only (dev → test → prod)
- Can't delete components
- Dependency management is manual
- No rollback capability

### Step 4: Metadata API Deployment

**Package.xml Structure**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
    <types>
        <members>MyApexClass</members>
        <members>AnotherApexClass</members>
        <name>ApexClass</name>
    </types>
    <types>
        <members>Account</members>
        <members>MyCustomObject__c</members>
        <name>CustomObject</name>
    </types>
    <types>
        <members>*</members>
        <name>ApexTrigger</name>
    </types>
    <version>60.0</version>
</Package>
```

**Metadata API Deploy via SFDX**:
```bash
# Deploy from manifest
sf project deploy start --manifest manifest/package.xml

# Deploy with test level
sf project deploy start --manifest manifest/package.xml --test-level RunLocalTests
```

### Step 5: Deployment Validation and Testing

**Test Levels**:
- **NoTestRun**: No tests (sandbox only)
- **RunSpecifiedTests**: Run specific test classes
- **RunLocalTests**: Run all local tests (non-managed)
- **RunAllTestsInOrg**: Run all tests including managed packages

**Production Deployment Requirements**:
- 75% code coverage minimum
- All tests must pass
- No errors in deployment
- Must run tests (can't use NoTestRun)

**Validation Steps**:
1. **Validate Deployment**:
   ```bash
   sf project deploy start --manifest manifest/package.xml --test-level RunLocalTests --dry-run
   ```
2. **Review Validation Results**: Check for errors, warnings
3. **Quick Deploy** (if validated successfully):
   ```bash
   sf project deploy quick --job-id <validation-job-id>
   ```

**Check Deployment Status**:
```bash
sf project deploy report --job-id <deploy-id>
sf project deploy resume --job-id <deploy-id>
sf project deploy cancel --job-id <deploy-id>
```

### Step 6: CI/CD Pipeline Implementation

**GitHub Actions Example** (Cross-Platform):
```yaml
name: Salesforce CI/CD

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  validate:
    # Ubuntu recommended (no path conversion issues)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Install Salesforce CLI
        run: npm install -g @salesforce/cli

      - name: Authenticate to Salesforce
        run: |
          echo "${{ secrets.SFDX_AUTH_URL }}" > authfile
          sf org login sfdx-url --sfdx-url-file authfile --alias target-org

      - name: Run Apex Tests
        run: sf apex run test --test-level RunLocalTests --code-coverage --result-format human

      - name: Deploy to Salesforce
        if: github.event_name == 'push'
        run: sf project deploy start --source-dir force-app --test-level RunLocalTests

  # Windows runner example (if needed)
  validate-windows:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v2

      - name: Install Salesforce CLI
        run: npm install -g @salesforce/cli
        shell: pwsh

      - name: Authenticate to Salesforce
        run: |
          echo "${{ secrets.SFDX_AUTH_URL }}" > authfile
          sf org login sfdx-url --sfdx-url-file authfile --alias target-org
        shell: pwsh

      - name: Deploy to Salesforce (Windows PowerShell)
        if: github.event_name == 'push'
        run: sf project deploy start --source-dir force-app --test-level RunLocalTests
        shell: pwsh
        # Note: Use PowerShell (pwsh) or cmd on Windows, NOT Git Bash in CI/CD
```

**Azure DevOps Pipeline Example**:
```yaml
trigger:
  branches:
    include:
      - main

pool:
  vmImage: 'ubuntu-latest'

steps:
- script: npm install -g @salesforce/cli
  displayName: 'Install Salesforce CLI'

- script: |
    echo $(SFDX_AUTH_URL) > authfile
    sf org login sfdx-url --sfdx-url-file authfile --alias target-org
  displayName: 'Authenticate Salesforce'

- script: sf project deploy start --source-dir force-app --test-level RunLocalTests
  displayName: 'Deploy to Salesforce'
```

**CI/CD Best Practices**:
- Store org credentials securely (secrets/variables)
- Use separate orgs per environment (dev, test, uat, prod)
- Automate tests on every commit
- Validate before merging to main branch
- Quick deploy validated deployments to production
- Implement approval gates for production
- Monitor deployment metrics
- Automate rollback procedures

### Step 7: Deployment Troubleshooting

**Common Deployment Errors**:

**Missing Dependencies**:
- Error: "Cannot find field X on object Y"
- Solution: Add dependent fields/objects to package.xml

**Test Failures**:
- Error: "Test coverage less than 75%"
- Solution: Write more test classes, ensure @isTest annotation

**Locked Components**:
- Error: "Component is locked by another deployment"
- Solution: Wait for other deployment to complete, or cancel it

**Field-Level Security**:
- Error: "Field is not visible"
- Solution: Add field permissions to profiles/permission sets in package

**Validation Rules**:
- Error: "Validation rule failed"
- Solution: Temporarily deactivate validation rules, or fix data

**Destructive Changes**:
- To delete components, use destructiveChanges.xml:
  ```xml
  <?xml version="1.0" encoding="UTF-8"?>
  <Package xmlns="http://soap.sforce.com/2006/04/metadata">
      <types>
          <members>ObsoleteClass</members>
          <name>ApexClass</name>
      </types>
      <version>60.0</version>
  </Package>
  ```
- Deploy with: `sf project deploy start --metadata-dir destructive --post-destructive-changes destructiveChanges.xml`

### Step 8: Environment Strategy

**Recommended Environment Flow**:
```
Developer Scratch Orgs → Developer Sandbox → QA/Test Sandbox → UAT Sandbox → Production
```

**Sandbox Types**:
- **Developer**: Small, fast refresh (1 day), code/config testing
- **Developer Pro**: Larger data storage, more robust testing
- **Partial Copy**: Sample production data, integration testing
- **Full Sandbox**: Complete production copy, performance/UAT testing

**Refresh Cadence**:
- Developer: Daily/Weekly
- QA/Test: Weekly
- UAT: Before major releases
- Full: Before major releases (quarterly)

**Deployment Checklist**:
- [ ] Code reviewed and approved
- [ ] All tests passing (>75% coverage)
- [ ] Validated in sandbox
- [ ] Deployment window scheduled (for production)
- [ ] Rollback plan prepared
- [ ] Stakeholders notified
- [ ] Release notes prepared
- [ ] Database backups completed (if data changes)
- [ ] Monitoring alerts configured
- [ ] Post-deployment testing plan ready

## Best Practices
- Use version control (Git) for all metadata
- Automate deployments via CI/CD
- Validate before deploying to production
- Use quick deploy for validated deployments
- Maintain environment parity (same config across envs)
- Test in sandbox before production
- Implement code review process
- Use source control branching strategy (GitFlow, trunk-based)
- Document deployment procedures
- Monitor deployment success rates
- Implement automated rollback
- Use unlocked packages for modular development
- Schedule deployments during low-usage windows

## Reference Resources
- SFDX CLI Reference: https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/
- Metadata API Guide: https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/
- Deployment Best Practices: https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_develop.htm
- CI/CD Examples: https://github.com/forcedotcom/sfdx-project-template
