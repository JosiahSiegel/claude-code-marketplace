---
description: Work with Salesforce REST/SOAP/Bulk APIs with authentication and best practices
---

# Salesforce API Integration

## Purpose
Help users work with Salesforce APIs including REST, SOAP, Bulk, Streaming, and Metadata APIs. Provide authentication setup, endpoint configuration, request construction, and error handling.

## Instructions

### Step 1: Identify API Requirements
- Determine which API type is needed:
  - **REST API**: Real-time CRUD operations, queries, standard objects
  - **SOAP API**: Legacy integrations, complex transactions
  - **Bulk API**: Large data volumes (>2000 records), asynchronous processing
  - **Streaming API**: Real-time event notifications, platform events
  - **Metadata API**: Deploy/retrieve metadata (objects, classes, etc.)
- Identify authentication method needed (OAuth 2.0, JWT, Session ID, Connected App)

### Step 2: Authentication Setup
For **OAuth 2.0 Web Server Flow**:
- Guide user to create Connected App in Salesforce Setup
- Required scopes: `api`, `refresh_token`, `offline_access`
- Obtain authorization code from: `https://login.salesforce.com/services/oauth2/authorize`
- Exchange for access token: `POST https://login.salesforce.com/services/oauth2/token`

For **JWT Bearer Flow** (server-to-server):
- Create Connected App with certificate
- Generate JWT token signed with private key
- Exchange JWT for access token

### Step 3: API Request Construction
**REST API Pattern**:
```
GET/POST/PATCH/DELETE https://{instance}.salesforce.com/services/data/v{version}/{resource}
Headers:
  Authorization: Bearer {access_token}
  Content-Type: application/json
```

**Common Endpoints**:
- Query: `GET /services/data/v60.0/query?q={SOQL}`
- Create: `POST /services/data/v60.0/sobjects/{ObjectName}`
- Update: `PATCH /services/data/v60.0/sobjects/{ObjectName}/{Id}`
- Delete: `DELETE /services/data/v60.0/sobjects/{ObjectName}/{Id}`
- Describe: `GET /services/data/v60.0/sobjects/{ObjectName}/describe`

**Bulk API 2.0 Pattern**:
1. Create job: `POST /services/data/v60.0/jobs/ingest`
2. Upload CSV data: `PUT /services/data/v60.0/jobs/ingest/{jobId}/batches`
3. Close job: `PATCH /services/data/v60.0/jobs/ingest/{jobId}` (state: UploadComplete)
4. Monitor: `GET /services/data/v60.0/jobs/ingest/{jobId}`

### Step 4: Error Handling and Limits
- **API Limits**: Check daily API call limits in Setup → Company Information
- **Rate Limiting**: Implement exponential backoff for 429 responses
- **Error Codes**:
  - `400 Bad Request`: Invalid request syntax
  - `401 Unauthorized`: Invalid/expired token
  - `403 Forbidden`: Insufficient permissions
  - `404 Not Found`: Invalid endpoint or record
  - `500 Internal Server Error`: Salesforce platform issue

### Step 5: Best Practices
- Use composite APIs to reduce API calls (`/composite/`, `/composite/batch`, `/composite/tree`)
- Implement bulk operations for >200 records
- Cache describe calls and metadata
- Use field-level security and sharing rules
- Monitor API usage with Event Monitoring
- Version endpoints explicitly (e.g., v60.0)

## Reference Resources
- Always fetch latest API reference: https://developer.salesforce.com/docs/apis
- API Explorer: https://workbench.developerforce.com
- Postman Collections: Salesforce Developers GitHub

## Common Use Cases
1. **CRUD Operations**: Use REST API with proper authentication
2. **Bulk Data Load**: Use Bulk API 2.0 for >2000 records
3. **Real-time Sync**: Use Streaming API or Platform Events
4. **Metadata Deployment**: Use Metadata API or SFDX
5. **Complex Queries**: Use SOQL via REST API query endpoint
