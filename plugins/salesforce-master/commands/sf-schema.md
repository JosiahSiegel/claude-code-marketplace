---
description: Design Salesforce data models including objects, fields, relationships, and validation rules
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

# Salesforce Schema and Data Model Design

## Purpose
Guide the design and implementation of Salesforce data models including custom objects, fields, relationships, validation rules, formulas, and schema optimization for performance and scalability.

## Instructions

### Step 1: Data Model Design Principles

**Before Creating Objects, Consider**:
- Can you use standard objects (Account, Contact, etc.)?
- What are the entities and their relationships?
- What is the cardinality (1:1, 1:M, M:N)?
- Who needs access to this data (sharing model)?
- What are the business rules and validations?
- How will data be queried and reported?
- What is the expected data volume?

**Standard vs Custom Objects**:
- **Use Standard**: Leverages platform features, integrations, mobile
- **Use Custom**: Unique business entities not covered by standard objects

### Step 2: Custom Object Creation

**Via Setup UI**:
1. Setup → Object Manager → Create → Custom Object
2. **Required Fields**:
   - **Label**: User-facing name (e.g., "Invoice")
   - **Plural Label**: "Invoices"
   - **Object Name**: API name (e.g., `Invoice__c`)
   - **Record Name**: Auto-number, text, etc.
   - **Deployment Status**: In Development / Deployed

3. **Optional Settings**:
   - Allow Reports, Activities, Bulk API, Streaming API
   - Track Field History
   - Enable Search
   - Sharing Model (OWD)

**Via SFDX**:
```xml
<!-- objects/Invoice__c/Invoice__c.object-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Invoice</label>
    <pluralLabel>Invoices</pluralLabel>
    <nameField>
        <label>Invoice Number</label>
        <type>AutoNumber</type>
        <displayFormat>INV-{0000}</displayFormat>
    </nameField>
    <deploymentStatus>Deployed</deploymentStatus>
    <sharingModel>ReadWrite</sharingModel>
    <enableActivities>true</enableActivities>
    <enableReports>true</enableReports>
    <enableSearch>true</enableSearch>
</CustomObject>
```

### Step 3: Field Types and When to Use Them

**Common Field Types**:

| Field Type | Use Case | Examples |
|------------|----------|----------|
| Text | Short text (255 chars) | Name, Email, Phone |
| Text Area (Long) | Large text (up to 131,072 chars) | Description, Notes |
| Number | Numeric values | Quantity, Count |
| Currency | Money values | Amount, Price |
| Percent | Percentages | Discount %, Tax Rate |
| Date | Date only | Birth Date, Due Date |
| Date/Time | Date and time | Created Date, Last Login |
| Checkbox | Boolean (true/false) | Is Active, Is Approved |
| Picklist | Single selection from list | Status, Type, Category |
| Multi-Select Picklist | Multiple selections | Skills, Interests |
| Email | Email addresses (validated) | Email Address |
| Phone | Phone numbers (formatted) | Phone, Mobile |
| URL | Web addresses | Website, Profile URL |
| Geolocation | Lat/Long coordinates | Office Location |
| Auto-Number | Auto-incrementing ID | Invoice #, Case # |
| Formula | Calculated field | Full Name, Days Open |
| Roll-Up Summary | Aggregated child data | Total Amount, Count |
| Lookup | Reference to another object | Account, Owner |
| Master-Detail | Tight coupling to parent | Invoice Line Items |

**Field Creation Example**:
```xml
<!-- objects/Invoice__c/fields/Amount__c.field-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Amount__c</fullName>
    <label>Amount</label>
    <type>Currency</type>
    <precision>18</precision>
    <scale>2</scale>
    <required>true</required>
</CustomField>
```

### Step 4: Relationship Design

**Lookup Relationship** (Loosely coupled):
- Child can exist without parent
- No cascade delete
- No roll-up summaries
- Independent sharing

**Use Cases**: Account → Contact (Contact can exist without Account)

**Master-Detail Relationship** (Tightly coupled):
- Child cannot exist without parent
- Cascade delete (deleting parent deletes children)
- Roll-up summaries available
- Inherits parent's sharing
- Cannot reparent (move to different parent) unless configured

**Use Cases**: Order → Order Line Items

**Hierarchical Relationship** (Self-referencing):
- Only on User and custom objects
- Used for reporting hierarchies

**Use Cases**: Account.ParentId (Account hierarchy), User.ManagerId

**Many-to-Many Relationships** (Junction Object):
- Create intermediate object with 2 master-detail relationships
- Example: Student ←→ Enrollment ←→ Course

**Relationship Field Example**:
```xml
<!-- Lookup Relationship -->
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Account__c</fullName>
    <label>Account</label>
    <type>Lookup</type>
    <referenceTo>Account</referenceTo>
    <relationshipLabel>Invoices</relationshipLabel>
    <relationshipName>Invoices</relationshipName>
</CustomField>

<!-- Master-Detail Relationship -->
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Invoice__c</fullName>
    <label>Invoice</label>
    <type>MasterDetail</type>
    <referenceTo>Invoice__c</referenceTo>
    <relationshipLabel>Line Items</relationshipLabel>
    <relationshipName>Line_Items</relationshipName>
    <reparentableMasterDetail>false</reparentableMasterDetail>
    <writeRequiresMasterRead>false</writeRequiresMasterRead>
</CustomField>
```

### Step 5: Formula Fields

**Formula Field Syntax**:
```
// Text formula - Full Name
FirstName & " " & LastName

// Number formula - Days Since Created
TODAY() - DATEVALUE(CreatedDate)

// Currency formula - Discount Amount
Amount__c * (Discount_Percent__c / 100)

// Conditional formula - Status Icon
IF(Amount__c > 10000, "🔴", IF(Amount__c > 5000, "🟡", "🟢"))

// Cross-object formula (Account name from Contact)
Account.Name

// Date formula - Due Date (30 days from created)
CreatedDate + 30
```

**Common Functions**:
- **Text**: `LEFT()`, `RIGHT()`, `MID()`, `SUBSTITUTE()`, `UPPER()`, `LOWER()`, `TRIM()`
- **Math**: `ROUND()`, `CEILING()`, `FLOOR()`, `ABS()`, `MAX()`, `MIN()`
- **Date**: `TODAY()`, `NOW()`, `YEAR()`, `MONTH()`, `DAY()`, `DATE()`
- **Logical**: `IF()`, `AND()`, `OR()`, `NOT()`, `ISBLANK()`, `ISNULL()`

**Formula Field Limitations**:
- Max 3,900 characters
- Cannot reference Long Text Area, Multi-Select Picklist
- Cannot be used in roll-up summaries (with exceptions)
- Compile size limit (~5,000 characters compiled)

### Step 6: Roll-Up Summary Fields

**Available on Master-Detail Parent Objects**:
```xml
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Total_Amount__c</fullName>
    <label>Total Amount</label>
    <summarizedField>InvoiceLineItem__c.Amount__c</summarizedField>
    <summaryForeignKey>InvoiceLineItem__c.Invoice__c</summaryForeignKey>
    <summaryOperation>sum</summaryOperation>
    <type>Summary</type>
</CustomField>
```

**Operations**:
- **COUNT**: Count of child records
- **SUM**: Sum of field values
- **MIN**: Minimum value
- **MAX**: Maximum value

**Filters**:
- Only summarize child records matching criteria
- Example: `SUM(Amount) WHERE Status = 'Closed'`

**Limitations**:
- Only on master-detail relationships
- Can't filter on formula fields (with exceptions)
- Maximum 25 roll-up summary fields per object

### Step 7: Validation Rules

**Validation Rule Structure**:
```
// Error Condition (when TRUE, show error)
Amount__c < 0

// Error Message
Amount must be greater than or equal to zero.

// Error Location
Field (shows on specific field) or Top of Page
```

**Common Validation Patterns**:

**Required Field Conditionally**:
```
// Email required if Contact Type is 'Customer'
AND(
    ISPICKVAL(Type__c, "Customer"),
    ISBLANK(Email__c)
)
```

**Date Range Validation**:
```
// End Date must be after Start Date
End_Date__c < Start_Date__c
```

**Numeric Range**:
```
// Discount must be between 0 and 100
OR(
    Discount_Percent__c < 0,
    Discount_Percent__c > 100
)
```

**Field Dependency**:
```
// If Status is Closed, Close Date is required
AND(
    ISPICKVAL(Status__c, "Closed"),
    ISBLANK(Close_Date__c)
)
```

**Prevent Changes After Approval**:
```
// Can't edit if approved (unless admin)
AND(
    ISCHANGED(Amount__c),
    ISPICKVAL(Approval_Status__c, "Approved"),
    $Profile.Name <> "System Administrator"
)
```

### Step 8: Schema Optimization

**Indexing**:
- **Auto-Indexed Fields**: Id, Name, OwnerId, RecordTypeId, CreatedDate, SystemModstamp, Master-Detail fields
- **Custom Index Candidates**: Fields used in WHERE clauses frequently
- **Request Custom Index**: Contact Salesforce Support for high-volume queries

**Query Performance**:
- Filter on indexed fields first
- Use selective queries (returns <10% of records)
- Avoid full table scans (queries without WHERE on indexed fields)
- Limit result sets with LIMIT clause

**Data Skew**:
- **Ownership Skew**: Single user owns >10,000 records
- **Lookup Skew**: Single parent has >10,000 children
- **Solution**: Implement sharing rules, defer sharing calculations

**Object Limits**:
- Fields per object: 500 custom fields (Enterprise), 800 (Unlimited)
- Relationships per object: 40 master-detail, unlimited lookups
- Validation rules: No hard limit, but impacts performance
- Formula complexity: 5,000 compiled characters

**Best Practices**:
- Use external IDs for integration (indexed, unique)
- Implement record types instead of multiple objects
- Use field sets for dynamic field rendering
- Archive old data to reduce storage
- Use big objects for high-volume event data (>1M records)
- Monitor data storage (Setup → Company Information)

### Step 9: Schema Documentation

**Entity Relationship Diagram (ERD)**:
- Use Schema Builder (Setup → Schema Builder)
- Visualize objects and relationships
- Drag-and-drop schema design

**Field Dependencies**:
- Document controlling/dependent picklists
- Setup → Object Manager → [Object] → Fields → [Picklist] → Field Dependencies

**Data Dictionary**:
- Export: Setup → Object Manager → [Object] → Download
- Includes all fields, types, formulas, help text

## Best Practices
- Design data model before implementation
- Use standard objects when possible
- Choose relationships carefully (lookup vs master-detail)
- Limit formula complexity for performance
- Implement validation rules for data quality
- Use external IDs for integration
- Index frequently queried fields
- Document field purpose in help text
- Use field sets for flexibility
- Monitor object and field limits
- Plan for data archival (over time)
- Test with production-like data volumes
- Use record types for different processes
- Implement naming conventions

## Reference Resources
- Schema Builder: Setup → Schema Builder
- Object Reference: https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/
- Formula Reference: https://help.salesforce.com/s/articleView?id=sf.customize_functions.htm
- Data Model Trailhead: https://trailhead.salesforce.com/content/learn/modules/data_modeling
