---
description: Develop, debug, and optimize Apex code (classes, triggers, batch, scheduled, queueable)
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

# Salesforce Apex Development

## Purpose
Guide Apex development including classes, triggers, test classes, batch jobs, scheduled jobs, queueable jobs, and future methods. Ensure governor limits compliance and best practices.

## Instructions

### Step 1: Determine Apex Component Type
Identify what needs to be created:
- **Apex Class**: Business logic, helper methods, controllers
- **Trigger**: Before/after DML operations on objects
- **Batch Apex**: Process large data volumes (>50,000 records)
- **Scheduled Apex**: Time-based automation
- **Queueable Apex**: Asynchronous processing with chaining
- **Future Method**: Async callouts or cross-object operations
- **Test Class**: Code coverage (minimum 75% required)

### Step 2: Apex Class Structure
```apex
/**
 * @description [Purpose of class]
 * @author [Name]
 * @date [Date]
 */
public with sharing class ClassName {

    // Constants
    private static final String CONSTANT_NAME = 'value';

    // Properties
    private String propertyName { get; set; }

    // Constructor
    public ClassName() {
        // Initialization
    }

    // Public methods
    public void methodName(Type param) {
        // Implementation
    }

    // Private helper methods
    private void helperMethod() {
        // Helper logic
    }
}
```

### Step 3: Trigger Best Practices
**Use Trigger Handler Pattern**:
```apex
trigger AccountTrigger on Account (before insert, before update, after insert, after update) {
    new AccountTriggerHandler().run();
}

// Separate handler class
public class AccountTriggerHandler extends TriggerHandler {

    protected override void beforeInsert() {
        // Logic here
    }

    protected override void afterUpdate() {
        // Logic here
    }
}
```

**One Trigger Per Object**: Never create multiple triggers on same object
**Bulkify**: Always process Trigger.new/Trigger.old as collections

### Step 4: Asynchronous Apex Patterns

**Batch Apex** (for >50K records):
```apex
global class BatchClassName implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name FROM Account');
    }

    global void execute(Database.BatchableContext bc, List<Account> scope) {
        // Process batch (default 200 records)
    }

    global void finish(Database.BatchableContext bc) {
        // Post-processing
    }
}

// Execute: Database.executeBatch(new BatchClassName(), 200);
```

**Queueable Apex** (for chaining jobs):
```apex
public class QueueableClassName implements Queueable {

    public void execute(QueueableContext context) {
        // Async logic

        // Chain another job if needed
        if (condition) {
            System.enqueueJob(new AnotherQueueableClass());
        }
    }
}

// Execute: System.enqueueJob(new QueueableClassName());
```

**Scheduled Apex**:
```apex
global class ScheduledClassName implements Schedulable {

    global void execute(SchedulableContext sc) {
        // Execute batch or other logic
        Database.executeBatch(new BatchClassName());
    }
}

// Schedule: System.schedule('Job Name', '0 0 2 * * ?', new ScheduledClassName());
// Cron: Seconds Minutes Hours Day Month Weekday Year
```

### Step 5: Governor Limits and Optimization

**CRITICAL BREAKING CHANGE (API 62.0+)**:
Collections cannot be modified during iteration:
```apex
// ❌ THROWS FinalException in API 62.0+
Set<String> mySet = new Set<String>{'a', 'b', 'c'};
for (String s : mySet) {
    mySet.remove(s);  // System.FinalException!
}

// ✅ CORRECT pattern
Set<String> itemsToRemove = new Set<String>();
for (String s : mySet) {
    if (condition) itemsToRemove.add(s);
}
mySet.removeAll(itemsToRemove);
```

**Critical Limits to Monitor**:
- SOQL Queries: 100 (sync) / 200 (async) per transaction
- DML Statements: 150 per transaction
- Total Records Retrieved: 50,000 per transaction
- Heap Size: 6 MB (sync) / 12 MB (async)
- CPU Time: 10,000 ms (sync) / 60,000 ms (async)

**Optimization Techniques**:
1. **Bulkify Queries**: Query once, process collections
   ```apex
   // BAD
   for (Account acc : accounts) {
       Contact con = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
   }

   // GOOD
   Map<Id, Contact> contactsByAccountId = new Map<Id, Contact>();
   for (Contact con : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIds]) {
       contactsByAccountId.put(con.AccountId, con);
   }
   ```

2. **Use Maps for Lookups**: O(1) vs O(n) performance
3. **Selective Queries**: Use indexed fields (Id, Name, External ID, Unique)
4. **Lazy Loading**: Query only when needed
5. **Collections.sort() vs SOQL ORDER BY**: Sort in Apex when possible

### Step 6: Test Class Requirements
**Minimum 75% code coverage required for deployment**

```apex
@isTest
private class TestClassName {

    @testSetup
    static void setupTestData() {
        // Create test data once for all test methods
        Account acc = new Account(Name = 'Test Account');
        insert acc;
    }

    @isTest
    static void testPositiveScenario() {
        Test.startTest();
        // Execute code
        Test.stopTest();

        // Assertions
        System.assertEquals(expected, actual, 'Error message');
    }

    @isTest
    static void testBulkScenario() {
        // Test with 200 records
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(Name = 'Test ' + i));
        }

        Test.startTest();
        insert accounts;
        Test.stopTest();
    }
}
```

### Step 7: Debugging and Troubleshooting
- **Debug Logs**: Setup → Debug Logs → Set trace flags
- **System.debug()**: Use different log levels (ERROR, WARN, INFO, DEBUG, FINE)
- **Checkpoints**: Set in Developer Console for interactive debugging
- **Limits Class**: Monitor limits in real-time
  ```apex
  System.debug('SOQL Queries: ' + Limits.getQueries() + '/' + Limits.getLimitQueries());
  System.debug('DML Statements: ' + Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements());
  ```

## New Apex Features (Spring '25 / API 63.0+)

### Compression Namespace (GA Spring '25)

Compress and extract ZIP files natively in Apex:

```apex
// Create ZIP file from multiple attachments
public class ZipCreationService {
    public static Blob createZipFromAttachments(List<Id> attachmentIds) {
        List<Attachment> attachments = [SELECT Id, Name, Body
                                        FROM Attachment
                                        WHERE Id IN :attachmentIds];

        // Create Gzip instance
        Compression.Gzip gzip = new Compression.Gzip();

        // Add files to archive
        Map<String, Blob> files = new Map<String, Blob>();
        for (Attachment att : attachments) {
            files.put(att.Name, att.Body);
        }

        // Compress to ZIP
        Blob zipBlob = Compression.ZipUtil.createZip(files);

        return zipBlob;
    }

    // Extract files from ZIP
    public static Map<String, Blob> extractZip(Blob zipBlob) {
        // Extract all files
        Map<String, Blob> extractedFiles = Compression.ZipUtil.extractZip(zipBlob);

        return extractedFiles;
    }

    // Extract specific file without uncompressing entire archive
    public static Blob extractSingleFile(Blob zipBlob, String fileName) {
        Blob fileContent = Compression.ZipUtil.extractFile(zipBlob, fileName);

        return fileContent;
    }
}

// Set compression level
Compression.Gzip gzip = new Compression.Gzip();
gzip.setLevel(Compression.CompressionLevel.BEST_COMPRESSION);  // Max compression
gzip.setLevel(Compression.CompressionLevel.BEST_SPEED);        // Fast compression
gzip.setLevel(Compression.CompressionLevel.DEFAULT_COMPRESSION); // Balanced
```

**IMPORTANT**: Consider Apex heap size limits (6 MB sync / 12 MB async). Maximum file size depends on compression method and ratio.

**Use Cases**:
- Batch export of records as CSV archives
- Document bundling for customers
- Log file compression and archiving
- Attachment consolidation

### FormulaEval Namespace (GA Spring '25)

Build and evaluate dynamic formulas in Apex:

```apex
// Evaluate dynamic formula
public class DynamicFormulaService {
    public static Decimal calculateDiscount(Opportunity opp) {
        // Define formula as string
        String formula = 'IF(Amount > 100000, Amount * 0.15, Amount * 0.10)';

        // Evaluate formula
        FormulaEval.FormulaInstance instance = FormulaEval.create(formula);

        // Set context record
        instance.setSObjectContext(opp);

        // Evaluate and return result
        Object result = instance.evaluate();

        return (Decimal)result;
    }

    // Access polymorphic relationship fields
    public static String getTaskOwnerName(Task task) {
        String formula = 'Owner.Name';

        FormulaEval.FormulaInstance instance = FormulaEval.create(formula);
        instance.setSObjectContext(task);

        return (String)instance.evaluate();
    }

    // Reference custom lookups in formula
    public static Decimal calculateCommission(Opportunity opp) {
        String formula = 'Amount * Account.CommissionRate__c';

        FormulaEval.FormulaInstance instance = FormulaEval.create(formula);
        instance.setSObjectContext(opp);

        return (Decimal)instance.evaluate();
    }

    // Dynamic pricing engine
    public static Decimal calculateDynamicPrice(Product2 product, Map<String, Object> variables) {
        // Formula stored in custom field
        String formula = product.PricingFormula__c;
        // Example: "BasePrice__c * (1 + (Quantity__c * DiscountRate__c))"

        FormulaEval.FormulaInstance instance = FormulaEval.create(formula);
        instance.setSObjectContext(product);

        // Set additional variables
        for (String key : variables.keySet()) {
            instance.setVariable(key, variables.get(key));
        }

        return (Decimal)instance.evaluate();
    }
}

// Custom formula editor for admins
public class FormulaEditorController {
    @AuraEnabled
    public static Boolean validateFormula(String formula, String objectType) {
        try {
            FormulaEval.FormulaInstance instance = FormulaEval.create(formula);

            // Validate against object schema
            Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(objectType);
            SObject testRecord = sObjType.newSObject();

            instance.setSObjectContext(testRecord);
            instance.validate();

            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
```

**Benefits**:
- No hardcoded formula fields required
- Evaluate formulas dynamically based on business rules
- Build custom formula editors for admins
- Performance gains over formula field evaluations
- Access polymorphic relationships and lookups

**Use Cases**:
- Dynamic pricing engines
- Configurable business rules
- A/B testing different calculation methods
- Multi-tenant formula customization

## Best Practices

### Security (2025 Standards)
- **Use `with sharing`** for user-context security (enforces sharing rules)
- **Use `WITH SECURITY_ENFORCED`** in SOQL to enforce field-level security (API 62.0+)
- **Use `Security.stripInaccessible()`** to remove inaccessible fields
- **Enable MFA** for all users (mandatory 2025 requirement)
- **Follow least privilege principle** (grant minimum necessary permissions)
- **Zero Trust architecture** with Hyperforce (verify everything, trust nothing)

```apex
// Security-enforced query (API 62.0+)
List<Account> accounts = [SELECT Id, Name, Revenue__c
                          FROM Account
                          WITH SECURITY_ENFORCED];

// Strip inaccessible fields before DML
List<Account> accounts = [SELECT Id, Name, Revenue__c FROM Account];
SObjectAccessDecision decision = Security.stripInaccessible(
    AccessType.READABLE, accounts);
return decision.getRecords();

// Secure DML with stripInaccessible (prevents field-level security bypass)
public static void updateAccountsSafely(List<Account> accounts) {
    // Remove fields user cannot update
    SObjectAccessDecision decision = Security.stripInaccessible(
        AccessType.UPDATABLE, accounts);

    // Only update fields user has access to
    update decision.getRecords();
}
```

### Code Quality
- Always bulkify (design for 200+ records)
- One trigger per object with handler pattern
- 100% test coverage goal (minimum 75%)
- Avoid SOQL/DML in loops
- Use Platform Events for decoupling
- Implement proper error handling and logging
- Follow naming conventions (PascalCase for classes, camelCase for variables)

## Reference Resources
- Apex Developer Guide: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/
- Apex Reference: https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/
- Trailhead: Apex Basics & Database
