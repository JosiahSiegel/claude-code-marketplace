---
description: Scaffold a new integration test with MSW setup
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

# Create Integration Test

## Purpose
Generate an integration test file that verifies multiple modules working together, typically with API mocking via MSW.

## Process

1. **Gather Information**
   - Feature/workflow to test
   - API endpoints involved
   - Multiple modules that interact
   - Expected data flow

2. **Create Test File Structure**

```javascript
import { describe, it, expect, beforeAll, afterEach, afterAll } from 'vitest';
import { server } from '../mocks/server';
import { http, HttpResponse } from 'msw';
import { featureWorkflow } from '../../src/features/{feature}';

// Start MSW server before tests
beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

describe('{feature} Integration', () => {
  it('should complete full workflow successfully', async () => {
    // Arrange - Mock API responses
    server.use(
      http.get('/api/data', () => {
        return HttpResponse.json({ id: 1, name: 'Test' });
      })
    );

    // Act - Execute workflow
    const result = await featureWorkflow();

    // Assert - Verify integration worked
    expect(result).toHaveProperty('success', true);
    expect(result.data).toEqual({ id: 1, name: 'Test' });
  });

  it('should handle API errors gracefully', async () => {
    // Mock error response
    server.use(
      http.get('/api/data', () => {
        return HttpResponse.json(
          { error: 'Not found' },
          { status: 404 }
        );
      })
    );

    // Workflow should handle error
    const result = await featureWorkflow();
    expect(result.success).toBe(false);
    expect(result.error).toBeDefined();
  });
});
```

3. **Verify MSW Setup**
   - Ensure tests/mocks/server.js exists
   - Ensure tests/mocks/handlers.js has base handlers
   - Verify tests/setup.js initializes MSW

4. **Generate Test Scenarios**

   **Multi-step workflow:**
   ```javascript
   it('should complete user registration workflow', async () => {
     // Step 1: Validate input
     const validation = await validateUserInput({
       email: '[email protected]',
       password: 'secure123'
     });
     expect(validation.valid).toBe(true);

     // Step 2: Create user (API call)
     server.use(
       http.post('/api/users', () => {
         return HttpResponse.json({ id: 123, email: '[email protected]' });
       })
     );

     const user = await createUser('[email protected]', 'secure123');
     expect(user.id).toBe(123);

     // Step 3: Send welcome email
     const emailResult = await sendWelcomeEmail(user.email);
     expect(emailResult.sent).toBe(true);
   });
   ```

   **Data flow between modules:**
   ```javascript
   it('should process and save data through multiple layers', async () => {
     const rawData = { input: 'raw data' };

     // Module 1: Parse data
     const parsed = parseData(rawData);
     expect(parsed).toHaveProperty('formatted', true);

     // Module 2: Validate parsed data
     const validated = validateData(parsed);
     expect(validated.errors).toHaveLength(0);

     // Module 3: Save to API
     server.use(
       http.post('/api/save', async ({ request }) => {
         const body = await request.json();
         expect(body).toEqual(validated);
         return HttpResponse.json({ saved: true, id: 456 });
       })
     );

     const result = await saveData(validated);
     expect(result.saved).toBe(true);
   });
   ```

## MSW Handler Patterns

**Override default handlers per test:**

```javascript
it('should handle specific API response', async () => {
  // This overrides default handler just for this test
  server.use(
    http.get('/api/special', () => {
      return HttpResponse.json({ special: 'data' });
    })
  );

  const result = await callSpecialEndpoint();
  expect(result.special).toBe('data');
});
```

**Test error scenarios:**

```javascript
it('should handle network errors', async () => {
  server.use(
    http.get('/api/data', () => {
      return HttpResponse.error();
    })
  );

  await expect(fetchData()).rejects.toThrow('Network error');
});

it('should handle 500 errors', async () => {
  server.use(
    http.get('/api/data', () => {
      return HttpResponse.json(
        { error: 'Internal server error' },
        { status: 500 }
      );
    })
  );

  const result = await fetchData();
  expect(result.error).toBe('Server error');
});
```

**Verify request data:**

```javascript
it('should send correct request payload', async () => {
  let receivedPayload;

  server.use(
    http.post('/api/submit', async ({ request }) => {
      receivedPayload = await request.json();
      return HttpResponse.json({ success: true });
    })
  );

  await submitForm({ name: 'Test', value: 123 });

  expect(receivedPayload).toEqual({
    name: 'Test',
    value: 123
  });
});
```

## Testing State Management

**For applications with state:**

```javascript
import { createStore } from '../../src/store';

describe('Store Integration', () => {
  let store;

  beforeEach(() => {
    store = createStore();
  });

  it('should update state through multiple actions', async () => {
    // Initial state
    expect(store.getState().user).toBeNull();

    // Action 1: Login (with API)
    server.use(
      http.post('/api/login', () => {
        return HttpResponse.json({ token: 'abc123' });
      })
    );

    await store.dispatch('login', { email: '[email protected]' });
    expect(store.getState().user).toBeDefined();

    // Action 2: Fetch user data
    server.use(
      http.get('/api/user', () => {
        return HttpResponse.json({ id: 1, name: 'Test User' });
      })
    );

    await store.dispatch('fetchUserData');
    expect(store.getState().user.name).toBe('Test User');
  });
});
```

## Best Practices

1. **Test realistic workflows** - Not just individual functions
2. **Mock external dependencies** - Use MSW for APIs
3. **Test error paths** - Not just happy path
4. **Verify data flows** - Check data passes correctly between modules
5. **Test state changes** - Verify application state updates correctly
6. **Use realistic data** - Test with data similar to production
7. **Clean up after tests** - Reset handlers with afterEach()

## Configuration

Ensure vitest.config.js includes integration tests:

```javascript
export default {
  test: {
    include: ['tests/integration/**/*.test.js'],
    environment: 'happy-dom',
    setupFiles: ['./tests/setup.js'],
    testTimeout: 10000 // Longer timeout for integration tests
  }
}
```

## After Creating

1. Run: `vitest run tests/integration/{feature}.test.js`
2. Verify MSW intercepts API calls correctly
3. Check test covers main workflow and error cases
4. Add more scenarios as needed
