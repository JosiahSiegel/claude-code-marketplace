---
description: Debug MSW request handling and mock interceptions
---

# Debug MSW

## Purpose
Debug Mock Service Worker setup to diagnose why API mocks aren't working correctly.

## Process

1. **Enable MSW Debugging**
   ```bash
   DEBUG=msw:* npm test
   ```

2. **Check MSW Setup**
   - Verify server.listen() is called in beforeAll
   - Check server.resetHandlers() in afterEach
   - Ensure server.close() in afterAll
   - Confirm handlers are exported correctly

3. **Common Issues**

   **Handlers not intercepting:**
   - Check URL patterns match exactly
   - Verify MSW server is started
   - Ensure using correct HTTP method

   **Wrong response:**
   - Check handler order (first match wins)
   - Verify response structure
   - Check for test-specific overrides

4. **Debug Output**
   ```javascript
   server.events.on('request:start', ({ request }) => {
     console.log('MSW intercepted:', request.method, request.url);
   });
   ```

5. **Test Handler Directly**
   ```javascript
   import { handlers } from '../mocks/handlers';

   // Check handler exists
   console.log('Handlers:', handlers.length);
   ```

## After Debugging

- Identify root cause
- Fix handler configuration
- Verify requests are intercepted
- Ensure correct responses returned
