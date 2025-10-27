---
name: data-cloud-2025
description: Salesforce Data Cloud integration patterns and architecture (2025)
---

# Salesforce Data Cloud Integration Patterns (2025)

## What is Salesforce Data Cloud?

Salesforce Data Cloud is a real-time customer data platform (CDP) that unifies data from any source to create a complete, actionable view of every customer. It powers AI, automation, and analytics across the entire Customer 360 platform.

**Key Capabilities**:
- **Data Ingestion**: Connect 200+ sources (Salesforce, external systems, data lakes)
- **Data Harmonization**: Map disparate data to unified data model
- **Identity Resolution**: Match and merge customer records across sources
- **Real-Time Activation**: Trigger actions based on streaming data
- **Zero Copy Architecture**: Query data in place without moving it
- **AI/ML Ready**: Powers Einstein, Agentforce, and predictive models

## Data Cloud Architecture

```
┌──────────────────────────────────────────────────────────┐
│                    Data Sources                          │
├──────────────────────────────────────────────────────────┤
│  Salesforce CRM │ External Apps │ Data Warehouses │ APIs │
└────────┬─────────────────┬──────────────┬───────────┬────┘
         │                 │              │           │
    ┌────▼─────────────────▼──────────────▼───────────▼────┐
    │         Data Cloud Connectors & Ingestion            │
    │  ├─ Real-time Streaming (Change Data Capture)        │
    │  ├─ Batch Import (scheduled/on-demand)               │
    │  └─ Zero Copy (Snowflake, Databricks, BigQuery)      │
    └────────────────────────┬─────────────────────────────┘
                             │
    ┌────────────────────────▼─────────────────────────────┐
    │            Data Model & Harmonization                │
    │  ├─ Map to Common Data Model (DMO objects)           │
    │  ├─ Identity Resolution (match & merge)              │
    │  └─ Data Transformation (calculated insights)        │
    └────────────────────────┬─────────────────────────────┘
                             │
    ┌────────────────────────▼─────────────────────────────┐
    │         Unified Customer Profile (360° View)         │
    │  ├─ Demographics, Transactions, Behavior, Events     │
    │  └─ Real-time Profile API for instant access         │
    └────────────────────────┬─────────────────────────────┘
                             │
    ┌────────────────────────▼─────────────────────────────┐
    │              Activation & Actions                    │
    │  ├─ Salesforce Flow (real-time automation)           │
    │  ├─ Marketing Cloud (segmentation/journeys)          │
    │  ├─ Agentforce (AI agents)                           │
    │  ├─ Einstein AI (predictions/recommendations)        │
    │  └─ External Systems (reverse ETL)                   │
    └──────────────────────────────────────────────────────┘
```

## Data Ingestion Patterns

### Pattern 1: Real-Time Streaming with Change Data Capture

**Use Case**: Keep Data Cloud synchronized with Salesforce objects in real-time

```apex
// Enable Change Data Capture for objects
// Setup → Change Data Capture → Select: Account, Contact, Opportunity

// Data Cloud automatically subscribes to CDC channels
// No code needed - configure in Data Cloud UI

// Optional: Custom streaming logic
public class DataCloudStreamHandler {
    public static void publishCustomEvent(Id recordId, String changeType) {
        // Publish custom platform event for Data Cloud
        DataCloudChangeEvent__e event = new DataCloudChangeEvent__e(
            RecordId__c = recordId,
            ObjectType__c = 'Custom_Object__c',
            ChangeType__c = changeType,
            Timestamp__c = System.now(),
            PayloadJson__c = JSON.serialize(getRecordData(recordId))
        );

        EventBus.publish(event);
    }

    private static Map<String, Object> getRecordData(Id recordId) {
        // Retrieve and return record data
        String objectType = recordId.getSObjectType().getDescribe().getName();
        String query = 'SELECT FIELDS(ALL) FROM ' + objectType +
                      ' WHERE Id = :recordId LIMIT 1';
        SObject record = Database.query(query);
        return (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(record));
    }
}
```

### Pattern 2: Batch Import from External Systems

**Use Case**: Import data from ERP, e-commerce, or other business systems

**Data Cloud Configuration**:
```
1. Create Data Source (Setup → Data Cloud → Data Sources)
   - Type: Amazon S3, SFTP, Azure Blob, Google Cloud Storage
   - Authentication: API key, OAuth, IAM role
   - Schedule: Hourly, Daily, Weekly

2. Map to Data Model Objects (DMO)
   - Source Field → DMO Field mapping
   - Data type conversions
   - Formula fields and transformations

3. Configure Identity Resolution
   - Match rules (email, customer ID, phone)
   - Reconciliation rules (which source wins)
```

**API-Based Batch Import**:
```python
# Python example: Push data to Data Cloud via API
import requests
import pandas as pd

def upload_to_data_cloud(csv_file, object_name, access_token, instance_url):
    """Upload CSV to Data Cloud via Bulk API"""

    # Step 1: Create ingestion job
    job_url = f"{instance_url}/services/data/v62.0/jobs/ingest"
    job_payload = {
        "object": object_name,
        "operation": "upsert",
        "externalIdFieldName": "ExternalId__c"
    }

    response = requests.post(
        job_url,
        headers={
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json"
        },
        json=job_payload
    )

    job_id = response.json()["id"]

    # Step 2: Upload CSV data
    with open(csv_file, 'rb') as f:
        csv_data = f.read()

    upload_url = f"{job_url}/{job_id}/batches"
    requests.put(
        upload_url,
        headers={
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "text/csv"
        },
        data=csv_data
    )

    # Step 3: Close job
    close_url = f"{job_url}/{job_id}"
    requests.patch(
        close_url,
        headers={
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json"
        },
        json={"state": "UploadComplete"}
    )

    return job_id
```

### Pattern 3: Zero Copy Integration (Snowflake, Databricks)

**Use Case**: Access data warehouse data without copying to Salesforce

**Benefits**:
- No data duplication (single source of truth)
- No data transfer costs
- Real-time access to warehouse data
- Maintain data governance in warehouse

**Snowflake Zero Copy Setup**:
```sql
-- In Snowflake: Grant access to Salesforce
GRANT USAGE ON DATABASE customer_data TO ROLE salesforce_role;
GRANT USAGE ON SCHEMA customer_data.public TO ROLE salesforce_role;
GRANT SELECT ON TABLE customer_data.public.orders TO ROLE salesforce_role;

-- Create secure share
CREATE SHARE salesforce_data_share;
GRANT USAGE ON DATABASE customer_data TO SHARE salesforce_data_share;
ALTER SHARE salesforce_data_share ADD ACCOUNTS = 'SALESFORCE_ORG_ID';
```

**Data Cloud Configuration**:
```
1. Add Zero Copy Connector (Data Cloud → Data Sources)
   - Type: Snowflake Zero Copy
   - Connection: Account URL, username, private key
   - Database/Schema selection

2. Create Data Stream (virtual tables)
   - Select Snowflake tables to expose
   - Map to DMO or keep as is
   - Configure refresh (real-time or scheduled)

3. Query in Salesforce
   - Use SOQL-like syntax to query Snowflake data
   - Join with Salesforce data
   - No data movement required
```

**Query Zero Copy Data**:
```apex
// Query Snowflake data from Apex (via Data Cloud)
public class DataCloudZeroCopyQuery {
    public static List<Map<String, Object>> querySnowflakeOrders(String customerId) {
        // Data Cloud Query API
        String query = 'SELECT order_id, total_amount, order_date ' +
                      'FROM snowflake_orders ' +
                      'WHERE customer_id = \'' + customerId + '\' ' +
                      'ORDER BY order_date DESC LIMIT 10';

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:DataCloud/v1/query');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(new Map<String, String>{'query' => query}));

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            return (List<Map<String, Object>>)result.get('data');
        }

        return new List<Map<String, Object>>();
    }
}
```

## Identity Resolution

### Matching Rules

**Configure identity resolution to create unified profiles**:

```
Match Rules Configuration:
├─ Primary Match (exact match on email)
│  └─ IF email matches THEN merge profiles
├─ Secondary Match (fuzzy match on name + phone)
│  └─ IF firstName + lastName similar AND phone matches THEN merge
└─ Tertiary Match (external ID)
   └─ IF ExternalCustomerId matches THEN merge

Reconciliation Rules (conflict resolution):
├─ Most Recent: Use most recently updated value
├─ Source Priority: Salesforce > ERP > Website
└─ Field-Level Rules: Email from Salesforce, Revenue from ERP
```

**Custom Matching Logic**:
```apex
// Custom matching for complex scenarios
public class DataCloudMatchingService {
    public static Boolean shouldMatch(Map<String, Object> profile1,
                                     Map<String, Object> profile2) {
        // Custom matching logic beyond standard rules

        String email1 = (String)profile1.get('email');
        String email2 = (String)profile2.get('email');

        // Exact email match
        if (email1 != null && email1.equalsIgnoreCase(email2)) {
            return true;
        }

        // Fuzzy name + address match
        String name1 = (String)profile1.get('fullName');
        String name2 = (String)profile2.get('fullName');
        String address1 = (String)profile1.get('address');
        String address2 = (String)profile2.get('address');

        if (isNameSimilar(name1, name2) && isSameAddress(address1, address2)) {
            return true;
        }

        return false;
    }

    private static Boolean isNameSimilar(String name1, String name2) {
        // Implement Levenshtein distance or phonetic matching
        return calculateSimilarity(name1, name2) > 0.85;
    }
}
```

## Real-Time Activation Patterns

### Pattern 1: Flow Automation Based on Data Cloud Events

**Use Case**: Trigger Flow when customer behavior detected in Data Cloud

```
Data Cloud Calculated Insight: "High-Value Customer at Risk"
- Logic: Purchase frequency decreased by 50% in last 30 days
- Trigger: When insight calculated
↓
Platform Event: HighValueCustomerRisk__e
↓
Salesforce Flow: "Retain High-Value Customer"
- Create Task for Account Manager
- Send personalized offer via Marketing Cloud
- Add to "At-Risk" campaign
- Log activity timeline
```

**Apex Implementation**:
```apex
// Subscribe to Data Cloud insights
trigger DataCloudInsightTrigger on HighValueCustomerRisk__e (after insert) {
    List<Task> tasks = new List<Task>();

    for (HighValueCustomerRisk__e event : Trigger.new) {
        // Create retention task
        Task task = new Task(
            Subject = 'Urgent: High-value customer at risk',
            Description = 'Customer ' + event.CustomerName__c +
                         ' shows declining engagement. Take action.',
            WhatId = event.AccountId__c,
            Priority = 'High',
            Status = 'Open',
            ActivityDate = Date.today().addDays(1)
        );
        tasks.add(task);

        // Trigger retention campaign
        RetentionCampaignService.addToRetentionCampaign(
            event.CustomerId__c,
            event.RiskScore__c
        );
    }

    if (!tasks.isEmpty()) {
        insert tasks;
    }
}
```

### Pattern 2: Agentforce with Data Cloud

**Use Case**: AI agent uses Data Cloud for complete customer context

```apex
// Agentforce action: Get unified customer view
public class AgentforceDataCloudActions {
    @InvocableMethod(label='Get Customer 360 Profile')
    public static List<CustomerProfile> getCustomer360(List<String> customerIds) {
        List<CustomerProfile> profiles = new List<CustomerProfile>();

        for (String customerId : customerIds) {
            // Query Data Cloud unified profile
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:DataCloud/v1/profile/' + customerId);
            req.setMethod('GET');

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                Map<String, Object> data = (Map<String, Object>)
                    JSON.deserializeUntyped(res.getBody());

                CustomerProfile profile = new CustomerProfile();
                profile.customerId = customerId;

                // Demographics
                profile.name = (String)data.get('name');
                profile.email = (String)data.get('email');
                profile.segment = (String)data.get('segment');

                // Behavioral
                profile.totalPurchases = (Decimal)data.get('total_purchases');
                profile.avgOrderValue = (Decimal)data.get('avg_order_value');
                profile.lastPurchaseDate = Date.valueOf((String)data.get('last_purchase_date'));
                profile.preferredChannel = (String)data.get('preferred_channel');

                // Engagement
                profile.emailEngagement = (Decimal)data.get('email_engagement_score');
                profile.websiteVisits = (Integer)data.get('website_visits_30d');
                profile.supportCases = (Integer)data.get('support_cases_90d');

                // Predictive
                profile.churnRisk = (Decimal)data.get('churn_risk_score');
                profile.lifetimeValue = (Decimal)data.get('predicted_lifetime_value');
                profile.nextBestAction = (String)data.get('next_best_action');

                profiles.add(profile);
            }
        }

        return profiles;
    }

    public class CustomerProfile {
        @InvocableVariable public String customerId;
        @InvocableVariable public String name;
        @InvocableVariable public String email;
        @InvocableVariable public String segment;
        @InvocableVariable public Decimal totalPurchases;
        @InvocableVariable public Decimal avgOrderValue;
        @InvocableVariable public Date lastPurchaseDate;
        @InvocableVariable public String preferredChannel;
        @InvocableVariable public Decimal emailEngagement;
        @InvocableVariable public Integer websiteVisits;
        @InvocableVariable public Integer supportCases;
        @InvocableVariable public Decimal churnRisk;
        @InvocableVariable public Decimal lifetimeValue;
        @InvocableVariable public String nextBestAction;
    }
}
```

### Pattern 3: Reverse ETL (Data Cloud → External Systems)

**Use Case**: Push enriched Data Cloud data back to external systems

**Configuration**:
```
Data Cloud → Data Actions → Create Data Action
- Target: External API endpoint
- Trigger: Segment membership change, insight calculated
- Payload: Customer profile fields
- Authentication: Named Credential
- Schedule: Real-time or batch
```

**Apex Outbound Sync**:
```apex
public class DataCloudReverseETL {
    @InvocableMethod(label='Sync Enriched Profile to External System')
    public static void syncToExternalSystem(List<String> customerIds) {
        for (String customerId : customerIds) {
            // Get enriched profile from Data Cloud
            Map<String, Object> profile = DataCloudService.getProfile(customerId);

            // Transform for external system
            Map<String, Object> payload = new Map<String, Object>{
                'customer_id' => customerId,
                'segment' => profile.get('segment'),
                'lifetime_value' => profile.get('ltv'),
                'churn_risk' => profile.get('churn_risk'),
                'next_best_product' => profile.get('next_best_product')
            };

            // Send to external system
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:ExternalCRM/api/customers/' + customerId);
            req.setMethod('PUT');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(payload));

            Http http = new Http();
            HttpResponse res = http.send(req);

            // Log result
            DataCloudSyncLog__c log = new DataCloudSyncLog__c(
                CustomerId__c = customerId,
                Direction__c = 'Outbound',
                Success__c = res.getStatusCode() == 200,
                Timestamp__c = System.now()
            );
            insert log;
        }
    }
}
```

## Calculated Insights and Segmentation

### Create Calculated Insights

**Use Case**: Define metrics and KPIs on unified data

```sql
-- Example: Customer Lifetime Value
CREATE CALCULATED INSIGHT customer_lifetime_value AS
SELECT
    customer_id,
    SUM(order_total) as total_revenue,
    COUNT(order_id) as total_orders,
    AVG(order_total) as avg_order_value,
    DATEDIFF(day, first_order_date, CURRENT_DATE) as customer_age_days,
    SUM(order_total) / NULLIF(DATEDIFF(day, first_order_date, CURRENT_DATE), 0) * 365 as annual_revenue,
    (SUM(order_total) / NULLIF(DATEDIFF(day, first_order_date, CURRENT_DATE), 0) * 365) * 5 as predicted_ltv_5yr
FROM unified_orders
GROUP BY customer_id, first_order_date
```

### Dynamic Segmentation

**Use Case**: Create segments that update in real-time

```sql
-- Segment: High-Value Active Customers
CREATE SEGMENT high_value_active_customers AS
SELECT customer_id
FROM customer_360_profile
WHERE
    predicted_ltv_5yr > 10000
    AND last_purchase_date >= CURRENT_DATE - INTERVAL '30' DAY
    AND email_engagement_score > 0.7
    AND churn_risk_score < 0.3
```

**Use in Salesforce**:
```apex
// Query segment membership
List<Contact> highValueContacts = [
    SELECT Id, Name, Email
    FROM Contact
    WHERE Id IN (
        SELECT ContactId__c
        FROM DataCloudSegmentMember__c
        WHERE SegmentName__c = 'high_value_active_customers'
    )
];
```

## Data Cloud SQL (ANSI SQL Support)

Query Data Cloud using standard SQL:

```sql
-- Complex analytical query across multiple sources
SELECT
    c.customer_id,
    c.name,
    c.segment,
    COUNT(DISTINCT o.order_id) as total_orders,
    SUM(o.order_total) as revenue,
    AVG(s.satisfaction_score) as avg_satisfaction,
    MAX(o.order_date) as last_order_date
FROM
    unified_customer c
    INNER JOIN unified_orders o ON c.customer_id = o.customer_id
    LEFT JOIN support_interactions s ON c.customer_id = s.customer_id
WHERE
    o.order_date >= CURRENT_DATE - INTERVAL '90' DAY
GROUP BY
    c.customer_id, c.name, c.segment
HAVING
    COUNT(DISTINCT o.order_id) >= 3
ORDER BY
    revenue DESC
LIMIT 100
```

## Authentication Patterns

### OAuth 2.0 JWT Bearer Flow (Server-to-Server)

```python
# External system → Data Cloud authentication
import jwt
import time
import requests

def get_data_cloud_access_token(client_id, private_key, username, instance_url):
    """Get access token for Data Cloud API"""

    # Create JWT
    payload = {
        'iss': client_id,
        'sub': username,
        'aud': instance_url,
        'exp': int(time.time()) + 180  # 3 minutes
    }

    encoded_jwt = jwt.encode(payload, private_key, algorithm='RS256')

    # Exchange JWT for access token
    token_url = f"{instance_url}/services/oauth2/token"
    response = requests.post(token_url, data={
        'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion': encoded_jwt
    })

    return response.json()['access_token']
```

## Best Practices

### Performance
- **Use Zero Copy** for large datasets (>10M records)
- **Batch imports** outside business hours
- **Index frequently queried fields** in Data Cloud
- **Limit real-time triggers** to critical events
- **Cache unified profiles** when possible

### Security
- **Field-level security** applies to Data Cloud queries from Salesforce
- **Data masking** for PII in non-production environments
- **Encryption at rest** and in transit (TLS 1.2+)
- **Audit logging** for all data access
- **Role-based access control** (RBAC) for Data Cloud users

### Data Quality
- **Data validation** before ingestion
- **Deduplication rules** at source and in Data Cloud
- **Data lineage tracking** (know source of each field)
- **Quality scores** for unified profiles
- **Regular data audits** and cleansing

## Resources

- **Data Cloud Documentation**: https://developer.salesforce.com/docs/data/data-cloud-int/guide
- **Zero Copy Partner Network**: https://www.salesforce.com/data/zero-copy/
- **Data Cloud Pricing**: Part of Customer 360 platform, usage-based pricing
- **Trailhead**: "Data Cloud Basics" and "Data Cloud for Developers"
