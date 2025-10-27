---
name: agentforce-2025
description: Salesforce Agentforce AI agents and autonomous automation (2025)
---

# Agentforce: AI Agents for Salesforce (2025)

## What is Agentforce?

Agentforce is Salesforce's enterprise AI agent platform that enables autonomous, proactive applications to execute specialized tasks for employees and customers. Agentforce agents use large language models (LLMs) with the Atlas Reasoning Engine to analyze context, reason through decisions, and take action autonomously.

**Key Distinction**: Agentforce represents the evolution from Einstein Copilot (conversational assistant) to autonomous agents that can complete tasks without human prompting.

## Core Architecture

### Atlas Reasoning Engine

The Atlas Reasoning Engine is the brain of Agentforce, enabling agents to:
- **Understand**: Analyze full context of customer interactions or automated triggers
- **Decide**: Reason through decisions using LLMs and business logic
- **Act**: Execute actions autonomously across any system
- **Learn**: Improve over time based on outcomes and feedback

### Agent Components

```
┌─────────────────────────────────────────────────┐
│              Agentforce Agent                   │
├─────────────────────────────────────────────────┤
│  1. Topics (what agent handles)                 │
│  2. Actions (what agent can do)                 │
│  3. Instructions (how agent behaves)            │
│  4. Channel Integrations (where agent works)    │
│  5. Data Sources (what agent knows)             │
└─────────────────────────────────────────────────┘
```

## Building Agents with Agentforce Builder (November 2025 Beta)

### Step 1: Define Agent Purpose

Identify what the agent should accomplish:
- **Service Agent**: Handle support cases, answer FAQs, resolve issues
- **Sales Development Agent**: Qualify leads, answer product questions, book meetings
- **Personal Shopper Agent**: Recommend products, handle orders, track shipments
- **Operations Agent**: Automate approvals, process requests, manage workflows

### Step 2: Configure Agent Topics

Topics define what the agent can help with:

```apex
// Example: Service Agent Topics
Topic: Password Reset
- Intent: User wants to reset password
- Required Data: Email, Username
- Connected Action: PasswordResetFlow

Topic: Order Status
- Intent: User wants order status
- Required Data: Order Number or Email
- Connected Action: GetOrderStatus

Topic: Escalate to Human
- Intent: User needs human assistance
- Required Data: Case context
- Connected Action: CreateCase + NotifyAgent
```

### Step 3: Define Agent Actions

Actions are what the agent can execute. These can be:
- **Standard Actions**: Pre-built Salesforce actions (create/update records)
- **Flow Actions**: Custom Flow automations
- **Apex Actions**: Custom Apex invocable methods
- **MuleSoft Actions**: API integrations via MuleSoft connectors
- **External API Actions**: REST/SOAP callouts

**Example Apex Action**:
```apex
public class AgentActions {
    @InvocableMethod(label='Get Order Status' description='Retrieves order status for customer')
    public static List<OrderStatus> getOrderStatus(List<OrderRequest> requests) {
        List<OrderStatus> results = new List<OrderStatus>();

        for (OrderRequest req : requests) {
            Order order = [SELECT Id, Status, EstimatedDelivery__c
                          FROM Order
                          WHERE OrderNumber = :req.orderNumber
                          LIMIT 1];

            OrderStatus status = new OrderStatus();
            status.orderNumber = req.orderNumber;
            status.status = order.Status;
            status.estimatedDelivery = order.EstimatedDelivery__c;
            results.add(status);
        }

        return results;
    }

    public class OrderRequest {
        @InvocableVariable(required=true)
        public String orderNumber;
    }

    public class OrderStatus {
        @InvocableVariable
        public String orderNumber;
        @InvocableVariable
        public String status;
        @InvocableVariable
        public Date estimatedDelivery;
    }
}
```

### Step 4: Write Agent Instructions

Instructions guide the agent's behavior and tone:

```
You are a helpful customer service agent for Acme Corp.

Personality:
- Friendly, professional, and empathetic
- Patient with customers who are frustrated
- Proactive in offering solutions

Guidelines:
- Always greet customers by name if available
- Verify customer identity before sharing account information
- Offer alternatives if the requested action cannot be completed
- Escalate to human agent for: refunds >$500, legal issues, abusive customers
- Use simple language, avoid jargon
- Provide order numbers and case numbers in responses

Security:
- Never share: passwords, credit card numbers, SSN
- Always verify identity using: email, phone, or account number
- Log all interactions for compliance

Response Format:
- Keep responses under 3 sentences when possible
- Use bullet points for multiple items
- Include next steps or call-to-action
```

### Step 5: Connect Data Sources

Agentforce agents can access:
- **Salesforce Objects**: Standard and custom objects
- **Data Cloud**: Unified customer data from all sources
- **Knowledge Base**: Salesforce Knowledge articles
- **External Systems**: Via APIs and MuleSoft connectors

**Data Cloud Integration**:
```apex
// Query Data Cloud from Agentforce
public class AgentDataCloudActions {
    @InvocableMethod(label='Get Customer 360 View')
    public static List<Customer360> getCustomer360(List<String> customerIds) {
        // Query Data Cloud for unified customer data
        List<Customer360> results = new List<Customer360>();

        for (String customerId : customerIds) {
            // Data Cloud connector provides unified view
            DataCloudConnector.QueryRequest req = new DataCloudConnector.QueryRequest();
            req.sql = 'SELECT * FROM Unified_Customer WHERE customer_id = \'' + customerId + '\'';

            DataCloudConnector.QueryResponse res = DataCloudConnector.query(req);

            Customer360 customer = new Customer360();
            customer.customerId = customerId;
            customer.totalPurchases = (Decimal)res.data.get('total_purchases');
            customer.preferredChannel = (String)res.data.get('preferred_channel');
            customer.lifetimeValue = (Decimal)res.data.get('lifetime_value');
            results.add(customer);
        }

        return results;
    }
}
```

### Step 6: Configure Channels

Deploy agents across multiple channels:
- **Web Chat**: Embedded on website
- **Mobile App**: In Salesforce Mobile or custom apps
- **SMS/WhatsApp**: Messaging platforms
- **Slack/Teams**: Collaboration tools
- **Voice**: Phone support with voice-to-text
- **Email**: Email case management

## Agent Types and Use Cases

### 1. Service Agent (Customer Support)

**Capabilities**:
- Answer FAQs from Knowledge Base
- Retrieve order/account status
- Process returns and exchanges
- Reset passwords and unlock accounts
- Create and route cases to specialists
- Provide troubleshooting steps

**Example Flow**:
```
Customer: "Where is my order #12345?"
↓
Agent: Validates order number
↓
Agent: Queries Order object
↓
Agent: Retrieves tracking information
↓
Agent: "Your order #12345 shipped yesterday and will arrive Thursday.
       Tracking: UPS 1Z999AA10123456784. Need anything else?"
```

### 2. Sales Development Agent (SDR)

**Capabilities**:
- Qualify inbound leads
- Answer product questions
- Handle objections with sales playbooks
- Book meetings with sales reps
- Send follow-up emails
- Update lead scores based on engagement

**Example Flow**:
```
Lead: "Tell me about your enterprise plan"
↓
Agent: Retrieves product information
↓
Agent: Explains features, pricing
↓
Agent: Detects buying intent
↓
Agent: "Would you like to schedule a demo with our sales team?"
↓
Agent: Creates meeting, updates lead status to "Meeting Scheduled"
```

### 3. Personal Shopper Agent (E-commerce)

**Capabilities**:
- Recommend products based on preferences
- Answer product questions
- Check inventory and availability
- Process orders and payments
- Apply discounts and promotions
- Handle cart abandonment

### 4. Operations Agent (Internal Automation)

**Capabilities**:
- Process employee requests (PTO, equipment)
- Automate approvals based on rules
- Onboard new employees
- Generate reports and insights
- Monitor system health
- Trigger workflows based on events

## Integrating Agentforce with Platform Events

Publish events to trigger Agentforce actions:

```apex
// Publish event when order status changes
public class OrderEventPublisher {
    public static void publishOrderUpdate(Id orderId, String newStatus) {
        OrderStatusChangeEvent__e event = new OrderStatusChangeEvent__e(
            OrderId__c = orderId,
            NewStatus__c = newStatus,
            Timestamp__c = System.now()
        );

        EventBus.publish(event);

        // Agentforce subscribes to this event
        // Triggers proactive customer notification
    }
}

// Trigger
trigger OrderTrigger on Order (after update) {
    for (Order ord : Trigger.new) {
        if (ord.Status != Trigger.oldMap.get(ord.Id).Status) {
            OrderEventPublisher.publishOrderUpdate(ord.Id, ord.Status);
        }
    }
}
```

**Agentforce Flow** (subscribed to OrderStatusChangeEvent__e):
```
1. Receive event
2. Query order and customer details
3. Determine notification channel (email, SMS, push)
4. Generate personalized message using LLM
5. Send notification via preferred channel
6. Log interaction in Customer timeline
```

## Agentforce with External AI Systems

Integrate Agentforce with external AI providers:

### OpenAI GPT Integration

```apex
public class AgentOpenAIIntegration {
    @InvocableMethod(label='Generate Response with GPT-4')
    public static List<String> generateResponse(List<AIRequest> requests) {
        List<String> responses = new List<String>();

        for (AIRequest req : requests) {
            HttpRequest httpReq = new HttpRequest();
            httpReq.setEndpoint('callout:OpenAI/v1/chat/completions');
            httpReq.setMethod('POST');
            httpReq.setHeader('Content-Type', 'application/json');

            Map<String, Object> payload = new Map<String, Object>{
                'model' => 'gpt-4',
                'messages' => new List<Object>{
                    new Map<String, String>{
                        'role' => 'system',
                        'content' => req.systemPrompt
                    },
                    new Map<String, String>{
                        'role' => 'user',
                        'content' => req.userMessage
                    }
                },
                'temperature' => 0.7,
                'max_tokens' => 500
            };

            httpReq.setBody(JSON.serialize(payload));

            Http http = new Http();
            HttpResponse httpRes = http.send(httpReq);

            if (httpRes.getStatusCode() == 200) {
                Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());
                List<Object> choices = (List<Object>)result.get('choices');
                Map<String, Object> choice = (Map<String, Object>)choices[0];
                Map<String, Object> message = (Map<String, Object>)choice.get('message');
                responses.add((String)message.get('content'));
            }
        }

        return responses;
    }

    public class AIRequest {
        @InvocableVariable(required=true)
        public String systemPrompt;
        @InvocableVariable(required=true)
        public String userMessage;
    }
}
```

### Anthropic Claude Integration

```apex
public class AgentClaudeIntegration {
    @InvocableMethod(label='Generate Response with Claude')
    public static List<String> generateResponse(List<AIRequest> requests) {
        List<String> responses = new List<String>();

        for (AIRequest req : requests) {
            HttpRequest httpReq = new HttpRequest();
            httpReq.setEndpoint('callout:Anthropic/v1/messages');
            httpReq.setMethod('POST');
            httpReq.setHeader('Content-Type', 'application/json');
            httpReq.setHeader('anthropic-version', '2023-06-01');

            Map<String, Object> payload = new Map<String, Object>{
                'model' => 'claude-3-5-sonnet-20241022',
                'max_tokens' => 1024,
                'system' => req.systemPrompt,
                'messages' => new List<Object>{
                    new Map<String, String>{
                        'role' => 'user',
                        'content' => req.userMessage
                    }
                }
            };

            httpReq.setBody(JSON.serialize(payload));

            Http http = new Http();
            HttpResponse httpRes = http.send(httpReq);

            if (httpRes.getStatusCode() == 200) {
                Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());
                List<Object> content = (List<Object>)result.get('content');
                Map<String, Object> contentBlock = (Map<String, Object>)content[0];
                responses.add((String)contentBlock.get('text'));
            }
        }

        return responses;
    }
}
```

## Monitoring and Analytics

### Agent Performance Metrics

Track agent effectiveness:
- **Resolution Rate**: % of interactions resolved without escalation
- **Average Handle Time**: Time to resolve customer request
- **Customer Satisfaction**: Post-interaction survey scores
- **Containment Rate**: % of interactions handled by agent vs human
- **Action Success Rate**: % of successful action executions

**Custom Reporting Object**:
```apex
public class AgentInteractionLogger {
    public static void logInteraction(String agentName, String topic,
                                     Boolean resolved, Decimal duration) {
        AgentInteraction__c interaction = new AgentInteraction__c(
            AgentName__c = agentName,
            Topic__c = topic,
            Resolved__c = resolved,
            Duration__c = duration,
            Timestamp__c = System.now()
        );
        insert interaction;
    }
}
```

### Analytics Dashboard Queries

```sql
-- Resolution rate by agent
SELECT AgentName__c,
       COUNT(Id) as TotalInteractions,
       SUM(CASE WHEN Resolved__c = true THEN 1 ELSE 0 END) as Resolved,
       AVG(Duration__c) as AvgDuration
FROM AgentInteraction__c
WHERE CreatedDate = LAST_N_DAYS:30
GROUP BY AgentName__c

-- Top topics requiring human escalation
SELECT Topic__c,
       COUNT(Id) as Escalations
FROM AgentInteraction__c
WHERE Resolved__c = false
  AND CreatedDate = LAST_N_DAYS:30
GROUP BY Topic__c
ORDER BY COUNT(Id) DESC
LIMIT 10
```

## Best Practices

### Security and Compliance
- **Field-Level Security**: Always use WITH SECURITY_ENFORCED in SOQL
- **Data Access**: Respect sharing rules with `with sharing` keywords
- **PII Protection**: Never log sensitive data (SSN, credit cards, passwords)
- **Audit Trail**: Log all agent actions for compliance
- **Human Oversight**: Require approval for high-impact actions

### Performance Optimization
- **Batch Processing**: Group similar actions to reduce API calls
- **Caching**: Cache frequently accessed data (product catalogs, FAQs)
- **Async Execution**: Use @future or Queueable for non-critical actions
- **Rate Limiting**: Implement throttling for external API calls
- **Timeout Handling**: Set appropriate timeouts and retry logic

### User Experience
- **Response Time**: Aim for <3 second responses
- **Personalization**: Use customer data for personalized responses
- **Transparency**: Clearly identify agent vs human interactions
- **Escalation**: Provide easy path to human agent when needed
- **Feedback Loop**: Collect user feedback to improve agent

### Testing
- **Unit Tests**: Test individual actions in isolation
- **Integration Tests**: Test end-to-end agent flows
- **Load Tests**: Simulate high volume to test scalability
- **User Acceptance Tests**: Validate with real users in sandbox
- **A/B Testing**: Compare different agent configurations

## Agentforce Pricing and Licensing

- **Agentforce Service Agent**: Part of Service Cloud with AI pricing
- **Agentforce Sales Development Agent**: Part of Sales Cloud with AI pricing
- **Custom Agents**: Available with Einstein 1 Edition or add-on
- **Agent Runs**: 600 free orchestration runs per year (Enterprise+)
- **Consumption Model**: Pay per agent interaction or conversation

## Resources

- **Agentforce Platform**: https://www.salesforce.com/agentforce/
- **Agentforce Builder Documentation**: Available Q4 2025
- **Einstein 1 Studio**: https://help.salesforce.com/s/articleView?id=sf.einstein_studio.htm
- **Atlas Reasoning Engine**: Technical documentation in Winter '26 release notes
- **Agentforce Trailhead**: Search "Agentforce" on Trailhead for modules

## Migration from Einstein Copilot

If you have Einstein Copilot (now Agentforce Assistant), migration path:

```
Einstein Copilot → Agentforce Assistant
- Conversational UI remains the same
- Add autonomous triggers and workflows
- Convert Copilot Actions to Agent Actions
- Add proactive agent behaviors
- Enable multi-channel deployment
```

**Action Migration Example**:
```apex
// Einstein Copilot Action (reactive)
@InvocableMethod(label='Copilot: Get Account Info')
public static List<Account> getAccountInfo(List<Id> accountIds) {
    return [SELECT Id, Name, Industry FROM Account WHERE Id IN :accountIds];
}

// Agentforce Action (proactive + reactive)
@InvocableMethod(label='Agent: Monitor and Alert on Account Changes')
public static void monitorAccounts(List<Id> accountIds) {
    // Not only retrieve data, but also:
    // 1. Monitor for changes
    // 2. Detect anomalies (sudden revenue drop)
    // 3. Proactively alert account manager
    // 4. Suggest next best actions
}
```

Agentforce represents a paradigm shift from conversational assistants to autonomous agents that can complete complex, multi-step tasks without human intervention while maintaining trust and security.
