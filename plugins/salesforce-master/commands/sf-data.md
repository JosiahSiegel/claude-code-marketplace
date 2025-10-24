---
description: Design SOQL/SOSL queries, perform CRUD operations, and manage Salesforce data
---

# Salesforce Data Operations

## Purpose
Help users design and execute SOQL/SOSL queries, perform CRUD operations, understand data model relationships, and optimize data operations for performance.

## Instructions

### Step 1: Understanding the Data Model
First, identify the objects and relationships involved:
- **Standard Objects**: Account, Contact, Lead, Opportunity, Case, etc.
- **Custom Objects**: Identified by `__c` suffix (e.g., `CustomObject__c`)
- **Relationship Types**:
  - **Lookup**: Loosely coupled (can be null)
  - **Master-Detail**: Tightly coupled (cascade delete, roll-up summaries)
  - **Hierarchical**: Self-referencing (e.g., Account.ParentId)

**Common Standard Objects Schema**:

**Account** (B2B/B2C customers):
- Id, Name, AccountNumber, Type, Industry, AnnualRevenue
- BillingStreet/City/State/PostalCode/Country
- Phone, Website, OwnerId
- ParentId (hierarchical)

**Contact** (People):
- Id, FirstName, LastName, Email, Phone, MobilePhone
- AccountId (lookup to Account)
- MailingStreet/City/State/PostalCode/Country
- Title, Department, OwnerId

**Opportunity** (Sales deals):
- Id, Name, AccountId, Amount, CloseDate, StageName
- Probability, Type, LeadSource, OwnerId
- IsClosed, IsWon

**Lead** (Prospects):
- Id, FirstName, LastName, Company, Email, Phone
- Status, LeadSource, Industry, OwnerId
- Street/City/State/PostalCode/Country

**Case** (Support tickets):
- Id, CaseNumber, Subject, Description, Status, Priority
- AccountId, ContactId, OwnerId
- Origin, Type, Reason

### Step 2: SOQL Query Design

**Basic SOQL Syntax**:
```sql
SELECT Id, Name, Email
FROM Contact
WHERE AccountId = '{accountId}'
  AND Email != null
ORDER BY LastName ASC
LIMIT 100
```

**Parent-to-Child Relationship Query** (1-to-Many):
```sql
SELECT Id, Name,
    (SELECT Id, FirstName, LastName, Email
     FROM Contacts
     WHERE Email != null)
FROM Account
WHERE Industry = 'Technology'
```

**Child-to-Parent Relationship Query** (Many-to-1):
```sql
SELECT Id, FirstName, LastName, Email,
    Account.Name,
    Account.Industry,
    Account.Owner.Name
FROM Contact
WHERE Account.Industry = 'Technology'
```

**Common SOQL Functions**:
- **Aggregate**: `COUNT()`, `SUM()`, `AVG()`, `MIN()`, `MAX()`
- **Date**: `CALENDAR_MONTH()`, `CALENDAR_YEAR()`, `DAY_IN_MONTH()`
- **String**: `toLabel()`, `FORMAT()`

**Aggregate Query Example**:
```sql
SELECT AccountId, COUNT(Id) ContactCount,
       MAX(CreatedDate) LatestContact
FROM Contact
GROUP BY AccountId
HAVING COUNT(Id) > 5
```

**Date Filtering**:
```sql
SELECT Id, Name, CloseDate
FROM Opportunity
WHERE CloseDate = THIS_MONTH
  AND StageName = 'Closed Won'

-- Date Literals: TODAY, YESTERDAY, LAST_WEEK, THIS_MONTH, LAST_90_DAYS, etc.
```

### Step 3: SOSL for Full-Text Search

**SOSL Syntax** (searches across multiple objects):
```sql
FIND {searchTerm}
IN ALL FIELDS
RETURNING Account(Id, Name), Contact(Id, Name, Email), Lead(Id, Name)
```

**Targeted SOSL**:
```sql
FIND {john smith}
IN NAME FIELDS
RETURNING Contact(Id, Name, Email WHERE MailingCity = 'San Francisco')
```

**When to Use SOSL**:
- Searching across multiple objects simultaneously
- Full-text search with fuzzy matching
- User entering search terms (like global search)

**When to Use SOQL**:
- Precise field matching
- Single object queries
- Relationship queries
- Aggregate calculations

### Step 4: CRUD Operations via API

**Create Records (Insert)**:
```json
POST /services/data/v60.0/sobjects/Account
{
  "Name": "Acme Corporation",
  "Industry": "Technology",
  "BillingCity": "San Francisco"
}
```

**Read Records (Query)**:
```
GET /services/data/v60.0/query?q=SELECT+Id,Name+FROM+Account+WHERE+Industry='Technology'
```

**Update Records (Patch)**:
```json
PATCH /services/data/v60.0/sobjects/Account/{Id}
{
  "Industry": "Manufacturing",
  "AnnualRevenue": 5000000
}
```

**Delete Records**:
```
DELETE /services/data/v60.0/sobjects/Account/{Id}
```

**Upsert (Create or Update based on External ID)**:
```json
PATCH /services/data/v60.0/sobjects/Account/ExternalIdField__c/externalIdValue
{
  "Name": "Acme Corporation",
  "Industry": "Technology"
}
```

### Step 5: Bulk Data Operations

**When to Use Bulk API**:
- Loading >2,000 records
- Updating >2,000 records
- Deleting large datasets
- Initial data migration

**Bulk API 2.0 Process**:
1. **Create Job**:
   ```json
   POST /services/data/v60.0/jobs/ingest
   {
     "object": "Account",
     "operation": "insert"
   }
   ```

2. **Upload CSV Data**:
   ```csv
   Name,Industry,BillingCity
   "Acme Corp","Technology","San Francisco"
   "Global Inc","Manufacturing","New York"
   ```

3. **Close Job**: PATCH job with state `UploadComplete`
4. **Monitor Progress**: Poll job status until `JobComplete`

### Step 6: Data Loader and SFDX
**Data Loader** (GUI tool):
- Insert, Update, Upsert, Delete, Export
- CSV-based operations
- Batch size up to 200 records
- Schedule operations

**SFDX CLI**:
```bash
# Export data
sfdx data export tree -q "SELECT Id, Name FROM Account" -d ./data

# Import data
sfdx data import tree -f ./data/Account.json

# Bulk operations
sfdx data upsert bulk -s Account -f accounts.csv -i ExternalId__c
```

### Step 7: Query Optimization

**Use Selective Queries** (indexed fields):
- Id (always indexed)
- Name, Email, Phone (auto-indexed on standard objects)
- RecordTypeId, OwnerId, CreatedDate, SystemModstamp
- Custom fields marked as Unique or External ID
- Lookup/Master-Detail relationship fields

**Filter on Indexed Fields First**:
```sql
-- GOOD (indexed field first)
SELECT Id, Name FROM Account WHERE Id IN :accountIds AND CustomField__c = 'value'

-- BAD (non-indexed field first)
SELECT Id, Name FROM Account WHERE CustomField__c = 'value' AND Id IN :accountIds
```

**Avoid Full Table Scans**:
- Always filter on indexed fields when possible
- Use `LIMIT` to reduce result set
- Avoid leading wildcards in LIKE queries (`LIKE '%value'`)

**Query Plan Tool**:
- Developer Console → Query Editor → Query Plan
- Shows if query is selective and uses indexes

### Step 8: Data Security and Sharing

**Object-Level Security** (Profiles/Permission Sets):
- Read, Create, Edit, Delete, View All, Modify All

**Field-Level Security**:
- Visible, Read-Only (can't query hidden fields without explicit permission)

**Record-Level Security (Sharing)**:
- Organization-Wide Defaults (OWD): Private, Public Read Only, Public Read/Write
- Role Hierarchy: Users see records owned by subordinates
- Sharing Rules: Extend access based on criteria
- Manual Sharing: Grant access to specific users

**Query with Sharing Context**:
```apex
// Respects user permissions
public with sharing class ContactController {
    public static List<Contact> getContacts() {
        return [SELECT Id, Name FROM Contact]; // User's accessible records only
    }
}

// Ignores user permissions (use carefully!)
public without sharing class AdminController {
    public static List<Contact> getAllContacts() {
        return [SELECT Id, Name FROM Contact]; // All records
    }
}
```

## Best Practices
- Design selective queries (filter on indexed fields)
- Use relationship queries to reduce API calls
- Implement pagination for large result sets (LIMIT + OFFSET)
- Use Bulk API for >2,000 records
- Test queries with Query Plan tool
- Respect field-level and record-level security
- Use External IDs for upsert operations
- Cache frequently queried data
- Monitor Data Storage limits (Setup → Company Information)

## Reference Resources
- SOQL/SOSL Reference: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/
- Standard Object Reference: https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/
- Data Loader: https://developer.salesforce.com/tools/data-loader
- Workbench (query tool): https://workbench.developerforce.com
