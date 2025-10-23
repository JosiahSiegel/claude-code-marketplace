---
description: Generate MSW handler for API endpoint
---

# Create MSW Mock Handler

## Purpose
Generate a Mock Service Worker (MSW) request handler for intercepting and mocking API calls in tests.

## Process

1. **Gather API Information**
   - API endpoint URL (e.g., `/api/users`)
   - HTTP method (GET, POST, PUT, DELETE, PATCH)
   - Expected request parameters
   - Response data structure
   - Status codes to mock

2. **Generate Handler**

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

3. **Add to handlers.js**

   Update `tests/mocks/handlers.js`:

   ```javascript
   import { http, HttpResponse } from 'msw';

   export const handlers = [
     // Existing handlers...

     // New handler
     http.get('/api/users', () => {
       return HttpResponse.json({
         users: [
           { id: 1, name: 'John Doe' },
           { id: 2, name: 'Jane Smith' }
         ]
       });
     }),
   ];
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

## Best Practices

1. **Keep handlers realistic** - Return data that matches production API
2. **Use fixtures** - Import mock data from fixtures for consistency
3. **Support multiple scenarios** - Create handlers for success and error cases
4. **Validate requests** - Check request body/headers in handlers
5. **Document handlers** - Add comments explaining what each handler mocks

## After Creating

1. Handler added to tests/mocks/handlers.js
2. Server automatically picks up new handler
3. Available in all tests that use MSW setup
4. Can be overridden per-test using server.use()
