---
description: Generate MSW handler for API endpoint
---

# Create MSW Mock Handler

## Purpose
Generate a Mock Service Worker (MSW) request handler for intercepting and mocking API calls in tests.

## Process (MSW 2.x - 2025 Best Practices)

1. **Gather API Information**
   - API endpoint URL (e.g., `/api/users`)
   - HTTP method (GET, POST, PUT, DELETE, PATCH)
   - Expected request parameters
   - Response data structure
   - Domain/feature area (for organization)
   - Status codes to mock

2. **Generate Happy Path Handler (Success Scenario First)**

   **For GET endpoint:**
   ```javascript
   import { http, HttpResponse } from 'msw';

   http.get('/api/users', () => {
     return HttpResponse.json({
       users: [
         { id: 1, name: 'John Doe', email: '[email protected]' },
         { id: 2, name: 'Jane Smith', email: '[email protected]' }
       ]
     });
   })
   ```

   **For POST endpoint:**
   ```javascript
   http.post('/api/users', async ({ request }) => {
     const body = await request.json();

     return HttpResponse.json({
       id: 123,
       ...body,
       createdAt: new Date().toISOString()
     }, { status: 201 });
   })
   ```

3. **Add to handlers.js with Domain-Based Organization**

   Update `tests/mocks/handlers.js` using 2025 pattern:

   ```javascript
   import { http, HttpResponse } from 'msw';

   // Group handlers by domain for better organization
   export const userHandlers = [
     // Existing user handlers...

     // New handler - Happy path (success scenario)
     http.get('/api/users', () => {
       return HttpResponse.json({
         users: [
           { id: 1, name: 'John Doe', email: '[email protected]' },
           { id: 2, name: 'Jane Smith', email: '[email protected]' }
         ]
       });
     }),
   ];

   export const productHandlers = [
     // Product-related handlers...
   ];

   // Combine all domain handlers
   export const handlers = [
     ...userHandlers,
     ...productHandlers,
     // Add more domains...
   ];
   ```

   **Note:** Define success scenarios as baseline. Override per test for errors:
   ```javascript
   // In your test file
   server.use(
     http.get('/api/users', () => {
       return HttpResponse.json({ error: 'Failed' }, { status: 500 });
     })
   );
   ```

## Advanced Handler Patterns

### Dynamic Responses

```javascript
http.get('/api/users/:id', ({ params }) => {
  const { id } = params;

  const users = {
    '1': { id: 1, name: 'John Doe', role: 'admin' },
    '2': { id: 2, name: 'Jane Smith', role: 'user' }
  };

  const user = users[id];

  if (!user) {
    return HttpResponse.json(
      { error: 'User not found' },
      { status: 404 }
    );
  }

  return HttpResponse.json(user);
})
```

### Query Parameters

```javascript
http.get('/api/users', ({ request }) => {
  const url = new URL(request.url);
  const page = url.searchParams.get('page') || '1';
  const limit = url.searchParams.get('limit') || '10';

  return HttpResponse.json({
    users: generateUsers(parseInt(limit)),
    pagination: {
      page: parseInt(page),
      limit: parseInt(limit),
      total: 100
    }
  });
})
```

### Request Validation

```javascript
http.post('/api/users', async ({ request }) => {
  const body = await request.json();

  if (!body.email || !body.name) {
    return HttpResponse.json(
      { error: 'Missing required fields' },
      { status: 400 }
    );
  }

  return HttpResponse.json({
    id: Date.now(),
    ...body
  }, { status: 201 });
})
```

## Best Practices (MSW 2.x - 2025)

1. **Happy paths first** - Define success scenarios as baseline in handlers.js
2. **Domain-based organization** - Group handlers by feature/domain area
3. **Runtime overrides** - Use `server.use()` for test-specific error cases
4. **Keep handlers realistic** - Return data that matches production API
5. **Use fixtures** - Import mock data from fixtures for consistency
6. **Validate requests** - Check request body/headers in handlers
7. **Document handlers** - Add comments explaining domain and purpose

## After Creating

1. Handler added to tests/mocks/handlers.js
2. Server automatically picks up new handler
3. Available in all tests that use MSW setup
4. Can be overridden per-test using server.use()
