---
description: Scaffold a new unit test with proper boilerplate
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

# Create Unit Test

## Purpose
Generate a new unit test file with appropriate structure, imports, and boilerplate for testing functions or modules.

## Process

1. **Gather Information**
   - Ask for module/file to test (if not provided)
   - Determine test file location: tests/unit/{module}.test.js
   - Identify functions/exports to test from source file

2. **Create Test File Structure**

```javascript
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { functionName } from '../../src/{module}';

describe('{module}', () => {
  describe('functionName', () => {
    it('should handle typical case', () => {
      // Arrange
      const input = 'test input';

      // Act
      const result = functionName(input);

      // Assert
      expect(result).toBe('expected output');
    });

    it('should handle edge cases', () => {
      expect(functionName(null)).toBeNull();
      expect(functionName('')).toBe('');
    });

    it('should throw error for invalid input', () => {
      expect(() => functionName(undefined)).toThrow();
    });
  });
});
```

3. **Analyze Source File**
   - Read the module being tested
   - Identify exported functions
   - Determine function parameters and return types
   - Generate appropriate test cases

4. **Generate Test Cases**

   **For pure functions:**
   ```javascript
   describe('add', () => {
     it('should add two numbers', () => {
       expect(add(2, 3)).toBe(5);
     });

     it('should handle negative numbers', () => {
       expect(add(-2, 3)).toBe(1);
     });

     it('should handle zero', () => {
       expect(add(0, 0)).toBe(0);
     });
   });
   ```

   **For functions with side effects:**
   ```javascript
   import { vi } from 'vitest';

   describe('saveData', () => {
     let mockStorage;

     beforeEach(() => {
       mockStorage = {
         set: vi.fn()
       };
     });

     it('should save data to storage', () => {
       saveData(mockStorage, 'key', 'value');
       expect(mockStorage.set).toHaveBeenCalledWith('key', 'value');
     });
   });
   ```

   **For async functions:**
   ```javascript
   describe('fetchData', () => {
     it('should fetch data successfully', async () => {
       const data = await fetchData('endpoint');
       expect(data).toHaveProperty('id');
     });

     it('should handle errors', async () => {
       await expect(fetchData('invalid')).rejects.toThrow();
     });
   });
   ```

## Templates by Function Type

### Pure Function Test Template

```javascript
import { describe, it, expect } from 'vitest';
import { pureFn } from '../../src/utils';

describe('pureFn', () => {
  it('should return expected output for typical input', () => {
    expect(pureFn('input')).toBe('output');
  });

  it('should handle edge cases', () => {
    expect(pureFn('')).toBe('');
    expect(pureFn(null)).toBeNull();
  });
});
```

### Class Method Test Template

```javascript
import { describe, it, expect, beforeEach } from 'vitest';
import { MyClass } from '../../src/MyClass';

describe('MyClass', () => {
  let instance;

  beforeEach(() => {
    instance = new MyClass();
  });

  describe('method', () => {
    it('should work correctly', () => {
      expect(instance.method()).toBe('expected');
    });
  });
});
```

### Function with Dependencies Test Template

```javascript
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { functionWithDeps } from '../../src/module';
import * as deps from '../../src/dependencies';

// Mock dependencies
vi.mock('../../src/dependencies');

describe('functionWithDeps', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('should call dependency correctly', () => {
    deps.dependency.mockReturnValue('mocked');

    const result = functionWithDeps();

    expect(deps.dependency).toHaveBeenCalled();
    expect(result).toBe('expected based on mock');
  });
});
```

## Best Practices

**1. Use AAA Pattern (Arrange, Act, Assert)**
```javascript
it('should process data', () => {
  // Arrange - Set up test data
  const input = { id: 1 };

  // Act - Execute function
  const result = processData(input);

  // Assert - Verify result
  expect(result).toEqual({ id: 1, processed: true });
});
```

**2. Test One Thing Per Test**
```javascript
// ✅ Good - focused test
it('should validate email format', () => {
  expect(validateEmail('[email protected]')).toBe(true);
});

it('should reject invalid email', () => {
  expect(validateEmail('invalid')).toBe(false);
});

// ❌ Bad - testing multiple things
it('should validate inputs', () => {
  expect(validateEmail('[email protected]')).toBe(true);
  expect(validatePassword('pass123')).toBe(true);
  expect(validateAge(25)).toBe(true);
});
```

**3. Use Descriptive Test Names**
```javascript
// ✅ Good
it('should return empty array when no items match filter', () => {

// ❌ Bad
it('should work', () => {
```

**4. Test Edge Cases**
```javascript
describe('divide', () => {
  it('should divide two numbers', () => {
    expect(divide(10, 2)).toBe(5);
  });

  it('should handle division by zero', () => {
    expect(() => divide(10, 0)).toThrow('Division by zero');
  });

  it('should handle negative numbers', () => {
    expect(divide(-10, 2)).toBe(-5);
  });

  it('should handle decimals', () => {
    expect(divide(10, 3)).toBeCloseTo(3.33, 2);
  });
});
```

## Configuration

Ensure tests/unit directory exists and vitest.config.js is configured:

```javascript
export default {
  test: {
    include: ['tests/unit/**/*.test.js'],
    environment: 'happy-dom'
  }
}
```

## After Creating

1. Run the new test: `vitest run tests/unit/{module}.test.js`
2. Ensure it passes
3. Add more test cases as needed
4. Run with coverage to verify module is tested
