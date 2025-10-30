---
description: Create mock data fixtures for tests
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

# Create Test Fixture

## Purpose
Generate mock data files (JSON or JS) to use across multiple tests for consistent test data.

## Process

1. **Gather Information**
   - Type of data (users, products, API responses, etc.)
   - Format (JSON or JavaScript module)
   - Number of records needed
   - Required fields

2. **Create Fixture File**

   **Location:** `tests/fixtures/{data-type}.json` or `tests/fixtures/{data-type}.js`

   **JSON Fixture Example:**
   ```json
   {
     "users": [
       {
         "id": 1,
         "email": "[email protected]",
         "name": "John Doe",
         "role": "admin",
         "active": true,
         "createdAt": "2024-01-01T00:00:00Z"
       },
       {
         "id": 2,
         "email": "[email protected]",
         "name": "Jane Smith",
         "role": "user",
         "active": true,
         "createdAt": "2024-01-02T00:00:00Z"
       }
     ],
     "products": [
       {
         "id": 101,
         "name": "Laptop",
         "price": 999.99,
         "stock": 50,
         "category": "electronics"
       },
       {
         "id": 102,
         "name": "Mouse",
         "price": 29.99,
         "stock": 200,
         "category": "accessories"
       }
     ]
   }
   ```

   **JavaScript Module Fixture:**
   ```javascript
   // tests/fixtures/users.js
   export const users = [
     {
       id: 1,
       email: '[email protected]',
       name: 'John Doe',
       role: 'admin',
       active: true,
       createdAt: new Date('2024-01-01')
     },
     {
       id: 2,
       email: '[email protected]',
       name: 'Jane Smith',
       role: 'user',
       active: true,
       createdAt: new Date('2024-01-02')
     }
   ];

   export const adminUser = users.find(u => u.role === 'admin');
   export const regularUser = users.find(u => u.role === 'user');

   // Factory function for creating custom users
   export function createUser(overrides = {}) {
     return {
       id: Math.floor(Math.random() * 10000),
       email: `user${Date.now()}@example.com`,
       name: 'Test User',
       role: 'user',
       active: true,
       createdAt: new Date(),
       ...overrides
     };
   }
   ```

3. **Create API Response Fixtures**

```javascript
// tests/fixtures/api-responses.js
export const successResponse = {
  success: true,
  data: [],
  meta: {
    page: 1,
    perPage: 20,
    total: 0
  }
};

export const errorResponse = {
  success: false,
  error: {
    code: 'GENERIC_ERROR',
    message: 'An error occurred',
    details: []
  }
};

export const paginatedResponse = (data, page = 1, perPage = 20) => ({
  success: true,
  data,
  meta: {
    page,
    perPage,
    total: data.length,
    totalPages: Math.ceil(data.length / perPage)
  }
});

// Specific endpoint responses
export const mockApiResponses = {
  '/api/users': {
    method: 'GET',
    response: successResponse
  },
  '/api/users/:id': {
    method: 'GET',
    response: {
      success: true,
      data: {
        id: 1,
        email: '[email protected]',
        name: 'John Doe'
      }
    }
  },
  '/api/users/create': {
    method: 'POST',
    response: {
      success: true,
      data: {
        id: 123,
        message: 'User created successfully'
      }
    }
  }
};
```

4. **Usage Examples**

```javascript
// In unit tests
import { describe, it, expect } from 'vitest';
import { users, adminUser } from '../fixtures/users.js';
import { validateUser } from '../../src/validation.js';

describe('validateUser', () => {
  it('should validate admin user', () => {
    expect(validateUser(adminUser)).toBe(true);
  });

  it('should validate all fixture users', () => {
    users.forEach(user => {
      expect(validateUser(user)).toBe(true);
    });
  });
});
```

```javascript
// In integration tests with MSW
import { http, HttpResponse } from 'msw';
import { server } from '../mocks/server.js';
import { users } from '../fixtures/users.js';

it('should fetch users', async () => {
  server.use(
    http.get('/api/users', () => {
      return HttpResponse.json({ data: users });
    })
  );

  const response = await fetchUsers();
  expect(response.data).toEqual(users);
});
```

## Common Fixture Types

### User/Account Fixtures

```javascript
export const fixtures = {
  users: {
    admin: {
      id: 1,
      email: '[email protected]',
      role: 'admin',
      permissions: ['read', 'write', 'delete']
    },
    user: {
      id: 2,
      email: '[email protected]',
      role: 'user',
      permissions: ['read']
    },
    guest: {
      id: 3,
      email: '[email protected]',
      role: 'guest',
      permissions: []
    }
  }
};
```

### E-commerce Fixtures

```javascript
export const products = [
  {
    id: 1,
    name: 'Laptop',
    price: 999.99,
    stock: 50,
    category: 'electronics',
    tags: ['computer', 'portable'],
    rating: 4.5
  },
  {
    id: 2,
    name: 'Desk Chair',
    price: 299.99,
    stock: 25,
    category: 'furniture',
    tags: ['office', 'ergonomic'],
    rating: 4.2
  }
];

export const cart = {
  items: [
    { productId: 1, quantity: 1, price: 999.99 },
    { productId: 2, quantity: 2, price: 299.99 }
  ],
  subtotal: 1599.97,
  tax: 159.99,
  total: 1759.96
};
```

### Blog/Content Fixtures

```javascript
export const posts = [
  {
    id: 1,
    title: 'Getting Started with Testing',
    slug: 'getting-started-with-testing',
    content: 'Learn how to write effective tests...',
    author: 'John Doe',
    publishedAt: '2024-01-15',
    tags: ['testing', 'tutorial'],
    comments: 5
  },
  {
    id: 2,
    title: 'Advanced Testing Patterns',
    slug: 'advanced-testing-patterns',
    content: 'Explore advanced testing techniques...',
    author: 'Jane Smith',
    publishedAt: '2024-02-01',
    tags: ['testing', 'advanced'],
    comments: 12
  }
];
```

### Form Data Fixtures

```javascript
export const formData = {
  valid: {
    contactForm: {
      name: 'John Doe',
      email: '[email protected]',
      subject: 'Test Subject',
      message: 'This is a test message with enough content.'
    }
  },
  invalid: {
    contactForm: {
      name: '',
      email: 'invalid-email',
      subject: '',
      message: 'Short'
    }
  }
};
```

## Best Practices

1. **Keep fixtures realistic** - Use data that resembles production data
2. **Version control fixtures** - Commit fixture files to Git
3. **Don't overload fixtures** - Create separate files for different domains
4. **Use TypeScript types** - If using TS, type your fixtures
5. **Document fixture purpose** - Add comments explaining what fixtures represent
6. **Keep fixtures DRY** - Use factory functions for variations
7. **Update fixtures with schema changes** - Keep in sync with API/database schemas

## Fixture Organization

```
tests/fixtures/
├── index.js              # Re-export all fixtures
├── users.js              # User-related data
├── products.js           # Product catalog data
├── orders.js             # Order/transaction data
├── api-responses.js      # Generic API responses
├── forms.js              # Form validation data
└── mock-data/            # Complex nested data
    ├── users.json
    └── products.json
```

**Index file for easy imports:**

```javascript
// tests/fixtures/index.js
export * from './users.js';
export * from './products.js';
export * from './orders.js';
export * from './api-responses.js';
export * from './forms.js';

// Usage:
// import { users, products, successResponse } from '../fixtures';
```

## Dynamic Fixtures

For tests needing unique data:

```javascript
// tests/fixtures/factories.js
let userIdCounter = 1000;

export function createUniqueUser(overrides = {}) {
  const id = userIdCounter++;
  return {
    id,
    email: `user${id}@example.com`,
    name: `Test User ${id}`,
    createdAt: new Date().toISOString(),
    ...overrides
  };
}

export function createBatch(factory, count, overrides = {}) {
  return Array.from({ length: count }, () => factory(overrides));
}

// Usage:
// const user = createUniqueUser({ role: 'admin' });
// const users = createBatch(createUniqueUser, 10);
```

## After Creating

1. Import fixture in test files
2. Use across multiple tests for consistency
3. Update fixtures when data schemas change
4. Document any special fixture considerations
