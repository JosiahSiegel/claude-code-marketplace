---
description: Deploy metadata, manage change sets, use SFDX CLI, and implement CI/CD for Salesforce
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

**GitHub Actions Example**:
```yaml
name: Salesforce CI/CD

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  validate:
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
