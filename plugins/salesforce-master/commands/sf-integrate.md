---
description: Autonomously wire up any source to Salesforce or Salesforce to any target with integration patterns
---

# Salesforce Integration

## Purpose
Guide integration between Salesforce and external systems, whether Salesforce is the source or target. Implement standard integration patterns including real-time sync, batch processing, event-driven architecture, and ETL/ELT workflows.

## Instructions

### Step 1: Identify Integration Pattern
Determine the integration architecture based on requirements:

**Pattern Selection Matrix**:
| Pattern | Use Case | Frequency | Volume | Latency |
|---------|----------|-----------|--------|---------|
| REST API (Real-time) | CRUD operations | On-demand | <2K records | Immediate |
| Bulk API | Data migration, ETL | Batch | >2K records | Minutes |
| Streaming API | Real-time notifications | Event-driven | N/A | Seconds |
| Platform Events | Pub/Sub, decoupling | Event-driven | <100K/day | Near real-time |
| Change Data Capture | Data sync, replication | Event-driven | Unlimited | <1 minute |
| Outbound Messages | Workflow-triggered | Event-driven | <1K/hour | Immediate |
| Apex Callouts | External API calls | On-demand | 100/transaction | Immediate |

### Step 2: External System as Source → Salesforce as Target

**Scenario**: Load data from external system into Salesforce

**Option A: REST API Integration** (Real-time, <2K records):
1. **Authentication**: Set up Connected App with OAuth 2.0
2. **Endpoint Design**:
   ```
   POST https://{instance}.salesforce.com/services/data/v62.0/sobjects/{Object}
   Authorization: Bearer {access_token}
   Content-Type: application/json

   {
     "Name": "Record Name",
     "CustomField__c": "value"
   }
   ```
3. **Error Handling**: Implement retry logic for 429 (rate limit) and 503 (unavailable)
4. **Idempotency**: Use External ID fields for upsert operations

**Option B: Bulk API Integration** (Batch, >2K records):
1. **Create Bulk Job**:
   ```json
   POST /services/data/v62.0/jobs/ingest
   {
     "object": "Account",
     "operation": "upsert",
     "externalIdFieldName": "ExternalId__c"
   }
   ```
2. **Upload CSV Data**: PUT CSV file to job
3. **Monitor Job**: Poll status until complete
4. **Process Results**: Download success/failure results

**Option C: Middleware/iPaaS** (MuleSoft, Dell Boomi, Informatica):
- Use pre-built Salesforce connectors
- Configure scheduled batch jobs
- Implement error handling and retry logic
- Monitor with built-in dashboards

**Implementation Checklist**:
- [ ] Create External ID field on target Salesforce object
- [ ] Map source fields to Salesforce fields
- [ ] Handle data type conversions (dates, picklists, lookups)
- [ ] Implement duplicate detection (matching rules)
- [ ] Set up error logging and notifications
- [ ] Validate data quality before insert
- [ ] Configure sharing and record ownership

### Step 3: Salesforce as Source → External System as Target

**Scenario**: Send Salesforce data to external system

**Option A: Platform Events** (Event-driven architecture):
1. **Create Platform Event**:
   ```apex
   // AccountChangeEvent__e custom platform event
   public class AccountEventPublisher {
       public static void publishAccountChange(Id accountId, String changeType) {
           AccountChangeEvent__e event = new AccountChangeEvent__e(
               AccountId__c = accountId,
               ChangeType__c = changeType,
               Timestamp__c = System.now()
           );
           EventBus.publish(event);
       }
   }
   ```

2. **External Subscriber** (via CometD):
   ```javascript
   // Node.js subscriber
   const cometd = require('cometd');
   const client = new cometd.CometD();

   client.configure({
       url: 'https://{instance}.salesforce.com/cometd/62.0',
       requestHeaders: { Authorization: `Bearer ${accessToken}` }
   });

   client.subscribe('/event/AccountChangeEvent__e', (message) => {
       // Process event and send to external system
       sendToExternalSystem(message.data.payload);
   });
   ```

**Option E: Agentforce Integration** (2025 - AI Agents):
```apex
// Publish events for AI agent consumption
public class AgentEventPublisher {
    public static void publishAgentAction(String action, Map<String, Object> context) {
        AgentActionEvent__e event = new AgentActionEvent__e(
            Action__c = action,
            Context__c = JSON.serialize(context),
            Timestamp__c = System.now()
        );
        EventBus.publish(event);
    }
}
```

```javascript
// AI Agent subscribes and processes events
client.subscribe('/event/AgentActionEvent__e', async (message) => {
    const { action, context } = message.data.payload;
    // Process with AI (OpenAI, Anthropic Claude, etc.)
    const result = await executeAIAction(action, JSON.parse(context));
    // Send results back to Salesforce
    updateSalesforce(result);
});
```

**Option F: Data Cloud Integration** (2025 - Real-time Unified Data):
```apex
// Query Data Cloud for unified customer profile
public class DataCloudIntegration {
    public static Map<String, Object> getUnifiedProfile(String customerId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:DataCloud/v1/profile/' + customerId);
        req.setMethod('GET');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            return (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        }
        return null;
    }

    // Activate segment members to external system
    public static void syncSegmentToExternalSystem(String segmentName) {
        // Get segment members from Data Cloud
        List<Contact> members = [
            SELECT Id, Email, External_Id__c
            FROM Contact
            WHERE Id IN (
                SELECT ContactId__c FROM DataCloudSegmentMember__c
                WHERE SegmentName__c = :segmentName
            )
        ];

        // Send to external marketing platform
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:MarketingPlatform/api/segments');
        req.setMethod('POST');
        req.setBody(JSON.serialize(members));

        Http http = new Http();
        http.send(req);
    }
}
```

**Option B: Change Data Capture** (Automatic change notifications):
1. **Enable CDC**: Setup → Change Data Capture → Select objects
2. **Subscribe to Channel**: `/data/{ObjectName}ChangeEvent`
3. **Process Changes**: Receive create, update, delete, undelete events
4. **Benefits**: No custom code, captures all changes, includes old/new values

**Option C: Outbound Messages** (Workflow-triggered):
1. **Create Workflow Rule**: Setup → Workflow Rules
2. **Add Outbound Message Action**: Specify endpoint URL
3. **WSDL Definition**: Salesforce generates WSDL for external system
4. **SOAP Endpoint**: External system receives SOAP message
5. **Acknowledge**: Must return `Ack` response

**Option D: Scheduled Apex + REST Callout**:
```apex
global class AccountSyncScheduled implements Schedulable {
    global void execute(SchedulableContext sc) {
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE LastModifiedDate = TODAY];

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://external-system.com/api/accounts');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(accounts));

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            // Success
        } else {
            // Error handling
        }
    }
}
```

### Step 4: Bidirectional Sync

**Conflict Resolution Strategies**:
- **Last Write Wins**: Timestamp-based (use SystemModstamp)
- **Source of Truth**: Salesforce or external system always wins
- **Manual Resolution**: Flag conflicts for user review
- **Merge Strategy**: Combine non-conflicting fields

**Implementation Pattern**:
1. **External ID Fields**: Both systems maintain reference IDs
2. **Sync Timestamps**: Track last sync time per record
3. **Change Tracking**: Detect changes since last sync
4. **Delta Sync**: Only sync changed records
5. **Conflict Detection**: Compare timestamps/versions
6. **Error Queue**: Store failed syncs for retry

**Example Architecture**:
```
External System ←→ Middleware/Queue ←→ Salesforce
                        ↓
                  Conflict Database
                  Error Log Database
```

### Step 5: Authentication and Security

**OAuth 2.0 Flows**:

**Web Server Flow** (User-based):
```
1. Redirect to: /services/oauth2/authorize?response_type=code&client_id={id}&redirect_uri={uri}
2. User authorizes
3. Exchange code for token: POST /services/oauth2/token
```

**JWT Bearer Flow** (Server-to-server):
```
1. Generate JWT signed with private key
2. POST /services/oauth2/token with grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer
3. Receive access token
```

**Named Credentials** (Salesforce → External):
- Setup → Named Credentials
- Centralized authentication management
- Use in Apex callouts: `Callout:NamedCredential/endpoint`

### Step 6: Common Integration Scenarios (2025)

**Scenario 1: ERP → Salesforce (Accounts, Products)**
- Nightly batch via Bulk API
- Use External ID (ERP_Id__c) for upsert
- Map ERP fields to Account/Product2 objects
- Handle price book entries for products

**Scenario 2: Salesforce → Data Warehouse (Analytics) via Data Cloud**
- Change Data Capture for real-time replication
- Data Cloud Zero Copy integration (Snowflake, Databricks)
- No data movement - query in place
- Enable historical tracking with Type 2 SCD

**Scenario 3: Salesforce → Marketing Automation (Marketo, Pardot) via Data Cloud**
- Real-time segment activation from Data Cloud
- Platform Events for engagement tracking
- Bidirectional sync for campaign responses
- Use calculated insights for targeting

**Scenario 4: E-commerce → Salesforce (Orders, Customers)**
- Real-time order creation via REST API
- Customer matching via email/External ID
- Inventory sync from Salesforce → E-commerce
- Order fulfillment status updates (bidirectional)

**Scenario 5: Support System → Salesforce (Cases) with Agentforce**
- Inbound: Create cases via REST API or Email-to-Case
- Agentforce AI agent handles L1 support
- Escalation to human agents for complex cases
- Sync case comments and AI conversation history bidirectionally

**Scenario 6: Multi-Cloud Integration with Hyperforce** (2025)
- AWS PrivateLink / Azure Private Link for secure connectivity
- Salesforce Hyperforce → Your VPC without public internet
- Lower latency, higher security
- Unified monitoring with CloudWatch/Azure Monitor

### Step 7: Error Handling and Monitoring

**Error Handling Best Practices**:
- Log all integration attempts (timestamp, payload, response)
- Implement exponential backoff for retries
- Use dead letter queue for permanent failures
- Alert on consecutive failures
- Validate payloads before sending

**Monitoring and Observability**:
- **Event Monitoring**: Track API usage, performance
- **Debug Logs**: Analyze Apex callout issues
- **Platform Events Metrics**: Monitor event volume, subscribers
- **External Monitoring**: Use tools like Datadog, New Relic
- **Health Checks**: Scheduled connectivity tests

**Logging Pattern**:
```apex
public class IntegrationLogger {
    public static void log(String integrationName, String payload, String response, Boolean success) {
        IntegrationLog__c log = new IntegrationLog__c(
            Integration__c = integrationName,
            Payload__c = payload,
            Response__c = response,
            Success__c = success,
            Timestamp__c = System.now()
        );
        insert log;
    }
}
```

### Step 8: Performance Optimization

**Reduce API Calls**:
- Use composite APIs (`/composite/`, `/composite/batch`, `/composite/tree`)
- Batch related operations together
- Cache frequently accessed data

**Parallel Processing**:
- Use @future or Queueable for async callouts
- Implement fan-out pattern for parallel calls
- Process in chunks (200 records per batch)

**Connection Pooling**:
- Reuse HTTP connections
- Configure timeout settings
- Implement circuit breaker pattern

## Best Practices
- Always use External ID fields for correlation
- Implement idempotent operations
- Log all integration activity
- Monitor API limits and usage
- Use Named Credentials for security
- Validate data before integration
- Handle partial success scenarios
- Test with production-like volumes
- Implement graceful degradation
- Document field mappings
- Use middleware for complex integrations
- Version your APIs explicitly

## Reference Resources
- Integration Patterns: https://developer.salesforce.com/docs/atlas.en-us.integration_patterns_and_practices.meta/integration_patterns_and_practices/
- Platform Events Guide: https://developer.salesforce.com/docs/atlas.en-us.platform_events.meta/platform_events/
- Change Data Capture: https://developer.salesforce.com/docs/atlas.en-us.change_data_capture.meta/change_data_capture/
- API Limits: https://developer.salesforce.com/docs/atlas.en-us.salesforce_app_limits_cheatsheet.meta/salesforce_app_limits_cheatsheet/
