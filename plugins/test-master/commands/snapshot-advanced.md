---
description: Advanced snapshot testing patterns with Vitest 4.0 - inline, file, and custom snapshots
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

---

# Advanced Snapshot Testing

## Purpose
Master advanced snapshot testing patterns including inline snapshots, file snapshots, custom serializers, and snapshot management strategies.

## Overview

**Snapshot Types:**
- **File Snapshots** - Stored in `__snapshots__/` directory (default)
- **Inline Snapshots** - Embedded directly in test code
- **Image Snapshots** - Visual regression testing (see `/test-master:visual-regression`)
- **Custom Snapshots** - Using custom serializers for complex data

## Snapshot Testing Patterns

### 1. File Snapshots (Default)

```javascript
import { expect, test } from 'vitest';

test('should match component output', () => {
  const result = renderComponent({ title: 'Hello', count: 42 });

  // Stored in __snapshots__/test-file.test.js.snap
  expect(result).toMatchSnapshot();
});

test('should match named snapshot', () => {
  const config = generateConfig();

  // Named snapshot for clarity
  expect(config).toMatchSnapshot('production-config');
});
```

### 2. Inline Snapshots (Vitest 3.0+)

```javascript
import { expect, test } from 'vitest';

test('should match inline snapshot', () => {
  const user = {
    id: 123,
    name: 'Alice',
    role: 'admin'
  };

  // Snapshot written directly into test file
  expect(user).toMatchInlineSnapshot(`
    {
      "id": 123,
      "name": "Alice",
      "role": "admin",
    }
  `);
});

test('should update inline snapshot', () => {
  const data = processData();

  // Run with -u flag to update
  expect(data).toMatchInlineSnapshot();
});
```

**Benefits of Inline Snapshots:**
- ✅ Easier to review in PR diffs
- ✅ No separate snapshot file to manage
- ✅ Better for small, focused data structures
- ❌ Can clutter test files if snapshots are large

**When to Use Inline:**
- Small objects/arrays (< 20 lines)
- Critical data structures that change frequently
- When snapshot context is important for understanding test

### 3. Snapshot Properties

```javascript
test('should match partial snapshot', () => {
  const response = {
    id: 'random-uuid',
    timestamp: Date.now(),
    data: { message: 'Success' }
  };

  // Match specific properties, ignore dynamic values
  expect(response).toMatchSnapshot({
    id: expect.any(String),
    timestamp: expect.any(Number),
    data: { message: 'Success' }
  });
});

test('should match array with asymmetric matchers', () => {
  const users = fetchUsers();

  expect(users).toMatchSnapshot([
    {
      id: expect.any(Number),
      name: expect.any(String),
      createdAt: expect.any(String)
    }
  ]);
});
```

### 4. Custom Serializers

```javascript
// test/setup.js
import { expect } from 'vitest';

// Custom serializer for Date objects
expect.addSnapshotSerializer({
  test: (val) => val instanceof Date,
  serialize: (val) => `Date<${val.toISOString().split('T')[0]}>`,
});

// Custom serializer for React elements
expect.addSnapshotSerializer({
  test: (val) => val && val.$$typeof === Symbol.for('react.element'),
  serialize: (val, config, indentation, depth, refs, printer) => {
    return printer(
      {
        type: val.type,
        props: val.props,
      },
      config,
      indentation,
      depth,
      refs
    );
  },
});
```

**Using Custom Serializers:**

```javascript
test('should use custom Date serializer', () => {
  const event = {
    name: 'Meeting',
    date: new Date('2025-01-15')
  };

  // Snapshot shows: Date<2025-01-15> instead of full ISO string
  expect(event).toMatchSnapshot();
});
```

### 5. Multi-Snapshot Tests

```javascript
test('should match multiple snapshots', () => {
  const config = loadConfig();

  // Match different parts separately
  expect(config.database).toMatchSnapshot('database-config');
  expect(config.api).toMatchSnapshot('api-config');
  expect(config.cache).toMatchSnapshot('cache-config');
});
```

### 6. Snapshot Testing DOM Elements

```javascript
import { expect, test } from 'vitest';

test('should match DOM structure', () => {
  const element = document.createElement('div');
  element.className = 'card';
  element.innerHTML = `
    <h2>Title</h2>
    <p>Content goes here</p>
    <button>Action</button>
  `;

  // Use innerHTML for clean snapshot
  expect(element.innerHTML).toMatchSnapshot();
});

test('should match serialized DOM', () => {
  const component = renderComponent();

  // Using custom serializer for better formatting
  expect(component.outerHTML).toMatchSnapshot();
});
```

### 7. Snapshot Testing with Mocks

```javascript
import { expect, test, vi } from 'vitest';

test('should match mocked API response', () => {
  const mockFetch = vi.fn().mockResolvedValue({
    ok: true,
    json: async () => ({
      users: [
        { id: 1, name: 'Alice' },
        { id: 2, name: 'Bob' }
      ]
    })
  });

  const result = await fetchUsers(mockFetch);

  expect(result).toMatchSnapshot();
});
```

### 8. Error Snapshots

```javascript
test('should match error structure', () => {
  expect(() => {
    throw new Error('Invalid input: Expected number, got string');
  }).toThrowErrorMatchingSnapshot();
});

test('should match error with custom serializer', () => {
  try {
    validateData(invalidData);
  } catch (error) {
    expect({
      message: error.message,
      code: error.code,
      // Omit stack trace (too dynamic)
    }).toMatchSnapshot();
  }
});
```

## Snapshot Management

### Updating Snapshots

```bash
# Update all snapshots
vitest run -u

# Update snapshots in watch mode
vitest
# Press 'u' to update all
# Press 'i' to update interactively

# Update specific test file
vitest run path/to/test.js -u

# Update only failing snapshots
vitest run -u --reporter=verbose
```

### Interactive Snapshot Update

```bash
# Start watch mode
vitest

# When snapshot fails:
# Press 'i' - Interactive mode
# Press 'u' - Update this snapshot
# Press 's' - Skip this snapshot
# Press 'q' - Quit interactive mode
```

### Reviewing Snapshot Changes

```bash
# View snapshot diff
git diff tests/__snapshots__/

# Review before committing
git add -p tests/__snapshots__/
```

## Best Practices

### 1. Keep Snapshots Small and Focused

```javascript
// ❌ Bad - Too much in one snapshot
test('should match entire app state', () => {
  const state = store.getState(); // Huge object
  expect(state).toMatchSnapshot();
});

// ✅ Good - Focused snapshots
test('should match user slice', () => {
  const userState = store.getState().user;
  expect(userState).toMatchSnapshot();
});

test('should match cart slice', () => {
  const cartState = store.getState().cart;
  expect(cartState).toMatchSnapshot();
});
```

### 2. Use Inline Snapshots for Small Data

```javascript
// ✅ Good - Small object, inline snapshot
test('should return user DTO', () => {
  const dto = mapToUserDTO(user);

  expect(dto).toMatchInlineSnapshot(`
    {
      "id": 123,
      "displayName": "Alice",
      "avatarUrl": "/avatars/alice.jpg",
    }
  `);
});
```

### 3. Ignore Dynamic Values

```javascript
test('should handle dynamic values', () => {
  const response = {
    id: crypto.randomUUID(),
    timestamp: Date.now(),
    data: { message: 'Hello' }
  };

  // Use property matchers for dynamic values
  expect(response).toMatchSnapshot({
    id: expect.stringMatching(/^[a-f0-9-]{36}$/),
    timestamp: expect.any(Number),
    data: { message: 'Hello' }
  });
});
```

### 4. Name Snapshots Descriptively

```javascript
// ❌ Bad - Generic names
expect(result).toMatchSnapshot(); // snapshot 1
expect(result2).toMatchSnapshot(); // snapshot 2

// ✅ Good - Descriptive names
expect(result).toMatchSnapshot('success-response');
expect(result2).toMatchSnapshot('error-response');
```

### 5. Avoid Snapshots for Simple Assertions

```javascript
// ❌ Bad - Snapshot overkill
test('should return sum', () => {
  expect(add(2, 3)).toMatchInlineSnapshot('5');
});

// ✅ Good - Direct assertion
test('should return sum', () => {
  expect(add(2, 3)).toBe(5);
});
```

### 6. Use Snapshots for Complex Structures

```javascript
// ✅ Good - Complex object, hard to assert manually
test('should generate correct GraphQL query', () => {
  const query = buildQuery({
    type: 'user',
    fields: ['id', 'name', 'posts'],
    filters: { role: 'admin' }
  });

  expect(query).toMatchSnapshot();
});
```

## Common Patterns

### Testing API Responses

```javascript
test('should match API response structure', async () => {
  const response = await fetch('/api/products');
  const data = await response.json();

  // Snapshot the structure, not exact values
  expect(data).toMatchSnapshot({
    products: expect.arrayContaining([
      {
        id: expect.any(Number),
        name: expect.any(String),
        price: expect.any(Number),
        inStock: expect.any(Boolean)
      }
    ]),
    total: expect.any(Number)
  });
});
```

### Testing Transformed Data

```javascript
test('should match transformed dataset', () => {
  const rawData = loadRawData();
  const transformed = transformData(rawData);

  // Snapshot after transformation
  expect(transformed).toMatchSnapshot();
});
```

### Testing Generated Code

```javascript
test('should generate correct SQL query', () => {
  const query = queryBuilder
    .select('users')
    .where({ active: true })
    .orderBy('created_at')
    .limit(10)
    .build();

  expect(query).toMatchInlineSnapshot(`
    "SELECT * FROM users WHERE active = true ORDER BY created_at LIMIT 10"
  `);
});
```

### Testing Configuration Objects

```javascript
test('should generate production config', () => {
  const config = generateConfig('production');

  // Omit environment-specific values
  expect({
    ...config,
    apiKey: '[REDACTED]',
    timestamp: '[TIMESTAMP]'
  }).toMatchSnapshot('production-config');
});
```

## Troubleshooting

### Snapshots Failing on CI

**Problem:** Snapshots pass locally but fail on CI

**Solutions:**
```javascript
// 1. Normalize line endings
expect(content.replace(/\r\n/g, '\n')).toMatchSnapshot();

// 2. Use custom serializers to hide environment-specific data
expect.addSnapshotSerializer({
  test: (val) => typeof val === 'string' && val.includes(process.cwd()),
  serialize: (val) => val.replace(process.cwd(), '[PROJECT_ROOT]')
});

// 3. Sort arrays to avoid order issues
expect(items.sort((a, b) => a.id - b.id)).toMatchSnapshot();
```

### Large Snapshot Files

**Problem:** Snapshot files become huge and hard to review

**Solutions:**
```javascript
// 1. Break into smaller snapshots
test('config parts', () => {
  expect(config.auth).toMatchSnapshot('auth');
  expect(config.database).toMatchSnapshot('database');
});

// 2. Snapshot only critical parts
test('essential config', () => {
  const { auth, database } = config;
  expect({ auth, database }).toMatchSnapshot();
});

// 3. Use inline snapshots for visibility
test('small config', () => {
  expect(config.features).toMatchInlineSnapshot(`
    {
      "darkMode": true,
      "betaFeatures": false,
    }
  `);
});
```

### Dynamic Values Breaking Snapshots

**Problem:** Timestamps, IDs, random values change every run

**Solutions:**
```javascript
// 1. Mock dynamic values
vi.spyOn(Date, 'now').mockReturnValue(1640000000000);
vi.spyOn(crypto, 'randomUUID').mockReturnValue('fixed-uuid');

// 2. Use property matchers
expect(data).toMatchSnapshot({
  id: expect.any(String),
  createdAt: expect.any(Number)
});

// 3. Custom serializers
expect.addSnapshotSerializer({
  test: (val) => typeof val === 'number' && val > 1000000000000,
  serialize: () => '"[TIMESTAMP]"'
});
```

## Snapshot Testing Anti-Patterns

### ❌ Snapshot Everything

```javascript
// Bad - Lazy testing
test('app works', () => {
  expect(app.render()).toMatchSnapshot();
});
```

### ❌ Giant Snapshots

```javascript
// Bad - Unmaintainable
test('entire database', () => {
  expect(database.dump()).toMatchSnapshot(); // 10,000 lines
});
```

### ❌ Testing Implementation

```javascript
// Bad - Brittle
test('internal state', () => {
  expect(component._internalState).toMatchSnapshot();
});
```

### ❌ Ignoring Snapshot Failures

```javascript
// Bad - Blindly updating
// DON'T just press 'u' without reviewing changes!
```

## Best Practices Summary

1. **Review snapshot changes** - Always inspect diffs before updating
2. **Keep snapshots focused** - One concept per snapshot
3. **Use inline for small data** - Better PR review experience
4. **Name snapshots clearly** - Descriptive names help future developers
5. **Handle dynamic values** - Use property matchers or mocks
6. **Commit snapshots** - Version control is essential
7. **Don't over-snapshot** - Use when structure matters, not just values
8. **Update carefully** - Understand why snapshot changed before accepting

## Next Steps

- Use `/test-master:update-snapshots` to interactively update snapshots
- Use `/test-master:visual-regression` for visual/UI snapshot testing
- Use `/test-master:coverage` to ensure snapshot tests add value
- Use `/test-master:debug` to investigate snapshot test failures
