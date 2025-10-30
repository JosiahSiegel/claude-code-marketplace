---
description: Add annotations and metadata to tests using Vitest 3.2+ Annotation API
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

# Test Annotation

## Purpose
Add custom messages, metadata, and attachments to tests using the Vitest 3.2+ Annotation API, making test results more informative and easier to debug.

## Overview

The Annotation API (introduced in Vitest 3.2) allows you to attach custom information to any test, visible in:
- Vitest UI
- HTML reporter
- JUnit reporter
- TAP reporter
- GitHub Actions reporter

**Use Cases:**
- Document complex test scenarios
- Attach debug information (configs, payloads)
- Link to external resources (tickets, documentation)
- Add performance metrics
- Track test metadata for CI/CD reporting

## Process

### 1. Basic Test Annotation

```javascript
import { test, expect } from 'vitest';

test('user authentication flow', async ({ task }) => {
  // Add annotation to test
  task.meta.annotation = {
    message: 'Testing OAuth2 flow with Google provider',
    attachments: []
  };

  const result = await authenticateUser(credentials);
  expect(result.token).toBeDefined();
});
```

### 2. Annotations with Attachments

```javascript
test('API integration', async ({ task }) => {
  const requestPayload = {
    userId: 123,
    action: 'purchase'
  };

  // Attach request payload for debugging
  task.meta.annotation = {
    message: 'Payment API integration test',
    attachments: [
      {
        name: 'request-payload',
        content: JSON.stringify(requestPayload, null, 2)
      }
    ]
  };

  const response = await api.post('/payment', requestPayload);
  expect(response.status).toBe(200);
});
```

### 3. Dynamic Annotations Based on Results

```javascript
test('performance test', async ({ task }) => {
  const startTime = Date.now();

  const result = await heavyOperation();

  const duration = Date.now() - startTime;

  // Add performance metrics
  task.meta.annotation = {
    message: `Completed in ${duration}ms`,
    attachments: [
      {
        name: 'metrics',
        content: JSON.stringify({
          duration,
          threshold: 1000,
          passed: duration < 1000
        })
      }
    ]
  };

  expect(result).toBeDefined();
  expect(duration).toBeLessThan(1000);
});
```

### 4. Annotations for Failed Tests

```javascript
test('payment processing', async ({ task }) => {
  const paymentData = { amount: 100, currency: 'USD' };

  try {
    const result = await processPayment(paymentData);

    task.meta.annotation = {
      message: 'Payment processed successfully',
      attachments: [
        { name: 'transaction-id', content: result.transactionId }
      ]
    };

    expect(result.success).toBe(true);
  } catch (error) {
    // Annotate failure with debug info
    task.meta.annotation = {
      message: `Payment failed: ${error.message}`,
      attachments: [
        { name: 'error-details', content: error.stack },
        { name: 'payload', content: JSON.stringify(paymentData) },
        { name: 'timestamp', content: new Date().toISOString() }
      ]
    };

    throw error;
  }
});
```

## Common Use Cases

### Linking to External Resources

```javascript
test('bug fix verification', async ({ task }) => {
  task.meta.annotation = {
    message: 'Verifies fix for production bug',
    attachments: [
      {
        name: 'jira-ticket',
        content: 'https://jira.company.com/browse/BUG-1234'
      },
      {
        name: 'related-pr',
        content: 'https://github.com/org/repo/pull/567'
      }
    ]
  };

  // Test implementation
  const result = await buggyFunction();
  expect(result).toBe(expectedValue);
});
```

### Environment Information

```javascript
test('API endpoint', async ({ task }) => {
  const apiUrl = process.env.API_URL;

  task.meta.annotation = {
    message: 'Testing against staging environment',
    attachments: [
      { name: 'environment', content: process.env.NODE_ENV },
      { name: 'api-url', content: apiUrl },
      { name: 'test-run-id', content: process.env.CI_RUN_ID || 'local' }
    ]
  };

  const response = await fetch(`${apiUrl}/health`);
  expect(response.ok).toBe(true);
});
```

### Test Data Snapshots

```javascript
test('data transformation', async ({ task }) => {
  const input = generateLargeDataset();
  const output = await transformData(input);

  task.meta.annotation = {
    message: 'Complex data transformation test',
    attachments: [
      {
        name: 'input-sample',
        content: JSON.stringify(input.slice(0, 5), null, 2)
      },
      {
        name: 'output-sample',
        content: JSON.stringify(output.slice(0, 5), null, 2)
      },
      {
        name: 'stats',
        content: JSON.stringify({
          inputSize: input.length,
          outputSize: output.length,
          transformationRate: (output.length / input.length * 100).toFixed(2) + '%'
        })
      }
    ]
  };

  expect(output).toHaveLength(expectedLength);
});
```

### Conditional Annotations

```javascript
test('feature flag test', async ({ task }) => {
  const featureEnabled = await getFeatureFlag('new-checkout');

  if (featureEnabled) {
    task.meta.annotation = {
      message: 'Testing NEW checkout flow (feature flag enabled)',
      attachments: [
        { name: 'feature-flag', content: 'new-checkout: ENABLED' }
      ]
    };

    await testNewCheckoutFlow();
  } else {
    task.meta.annotation = {
      message: 'Testing LEGACY checkout flow (feature flag disabled)',
      attachments: [
        { name: 'feature-flag', content: 'new-checkout: DISABLED' }
      ]
    };

    await testLegacyCheckoutFlow();
  }
});
```

## Integration with Reporters

### View in Vitest UI

```bash
# Run with UI to see annotations
vitest --ui
```

Annotations appear in:
- Test details panel
- Failure reports
- Test metadata section

### GitHub Actions Integration

```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm ci
      - run: npm test
        env:
          CI: true
          CI_RUN_ID: ${{ github.run_id }}
```

Annotations automatically appear in:
- GitHub Actions test summary
- PR checks
- Workflow logs

### HTML Reporter

```javascript
// vitest.config.js
export default defineConfig({
  test: {
    reporters: ['default', 'html']
  }
});
```

```bash
# Generate HTML report with annotations
vitest run --reporter=html

# Open in browser
open html/index.html
```

### JUnit Reporter for CI Systems

```javascript
// vitest.config.js
export default defineConfig({
  test: {
    reporters: ['default', 'junit'],
    outputFile: {
      junit: './test-results/junit.xml'
    }
  }
});
```

Annotations included in JUnit XML output for:
- Jenkins
- Azure DevOps
- GitLab CI
- CircleCI

## Best Practices

### 1. Be Selective with Annotations

```javascript
// ✅ Good - Annotate complex or critical tests
test('critical payment flow', async ({ task }) => {
  task.meta.annotation = {
    message: 'Critical path - payment processing',
    attachments: [{ name: 'sla', content: 'P0 - Must pass' }]
  };
});

// ❌ Avoid - Don't annotate every simple test
test('adds two numbers', ({ task }) => {
  task.meta.annotation = { message: 'Simple math test' }; // Unnecessary
  expect(1 + 1).toBe(2);
});
```

### 2. Use Attachments for Debug Info

```javascript
// ✅ Good - Attach relevant debug data
task.meta.annotation = {
  message: 'API test failed',
  attachments: [
    { name: 'request', content: JSON.stringify(req) },
    { name: 'response', content: JSON.stringify(res) },
    { name: 'headers', content: JSON.stringify(res.headers) }
  ]
};

// ❌ Avoid - Don't dump everything
task.meta.annotation = {
  attachments: [
    { name: 'data', content: JSON.stringify(entireDatabase) } // Too large
  ]
};
```

### 3. Standardize Annotation Format

```javascript
// Create helper function
function annotateTest(task, info) {
  task.meta.annotation = {
    message: `[${info.category}] ${info.description}`,
    attachments: [
      { name: 'test-id', content: info.testId },
      { name: 'component', content: info.component },
      ...(info.attachments || [])
    ]
  };
}

test('user profile', async ({ task }) => {
  annotateTest(task, {
    category: 'Integration',
    description: 'User profile update flow',
    testId: 'USR-123',
    component: 'UserProfile',
    attachments: [{ name: 'endpoint', content: '/api/users/profile' }]
  });

  // Test implementation
});
```

### 4. Use for Flaky Test Investigation

```javascript
test('potentially flaky test', async ({ task }) => {
  const attemptNumber = task.result?.retries || 0;

  task.meta.annotation = {
    message: attemptNumber > 0 ? `Retry attempt ${attemptNumber}` : 'First attempt',
    attachments: [
      { name: 'attempt', content: String(attemptNumber) },
      { name: 'timestamp', content: new Date().toISOString() },
      { name: 'environment', content: JSON.stringify(process.env) }
    ]
  };

  // Test implementation that might be flaky
  const result = await unstableOperation();
  expect(result).toBe(expected);
});
```

## Configuration

### Enable Annotation Display

```javascript
// vitest.config.js
export default defineConfig({
  test: {
    reporters: [
      'default',
      'html', // Shows annotations in HTML report
      'junit', // Includes annotations in XML
      ['json', { outputFile: './results.json' }] // Full annotation data
    ]
  }
});
```

### Custom Reporter for Annotations

```javascript
// reporters/annotation-reporter.js
export default class AnnotationReporter {
  onFinished(files, errors) {
    const annotatedTests = [];

    files.forEach(file => {
      file.tasks.forEach(task => {
        if (task.meta?.annotation) {
          annotatedTests.push({
            name: task.name,
            file: file.name,
            annotation: task.meta.annotation,
            result: task.result?.state
          });
        }
      });
    });

    // Export annotated tests
    console.log('\n=== Annotated Tests ===');
    annotatedTests.forEach(test => {
      console.log(`\n${test.file}: ${test.name}`);
      console.log(`  ${test.annotation.message}`);
      if (test.annotation.attachments?.length) {
        console.log(`  Attachments: ${test.annotation.attachments.length}`);
      }
    });
  }
}
```

## Troubleshooting

**Annotations not showing in UI:**
- Ensure using Vitest 3.2+: `npm list vitest`
- Check UI version matches: `npm list @vitest/ui`
- Restart UI if running: `vitest --ui`

**Attachments too large:**
- Limit attachment size (< 1MB recommended)
- Use summaries instead of full data
- Link to external files instead

**Missing in CI:**
- Check reporter configuration
- Verify reporter supports annotations
- Update CI integration if needed

## Examples

### Full Integration Test with Annotations

```javascript
import { test, expect, describe } from 'vitest';

describe('E-commerce checkout', () => {
  test('complete purchase flow', async ({ task }) => {
    const testData = {
      cart: [{ id: 1, price: 29.99 }],
      user: { email: '[email protected]' },
      payment: { method: 'card' }
    };

    task.meta.annotation = {
      message: 'End-to-end checkout integration test',
      attachments: [
        { name: 'test-data', content: JSON.stringify(testData, null, 2) },
        { name: 'test-id', content: 'E2E-CHECKOUT-001' },
        { name: 'priority', content: 'P0 - Critical Path' }
      ]
    };

    const startTime = Date.now();

    try {
      const result = await completeCheckout(testData);

      const duration = Date.now() - startTime;

      // Update annotation with results
      task.meta.annotation.attachments.push(
        { name: 'duration', content: `${duration}ms` },
        { name: 'order-id', content: result.orderId }
      );

      expect(result.success).toBe(true);
      expect(duration).toBeLessThan(5000);
    } catch (error) {
      // Enhance error annotation
      task.meta.annotation.message = `FAILED: ${error.message}`;
      task.meta.annotation.attachments.push(
        { name: 'error', content: error.stack },
        { name: 'timestamp', content: new Date().toISOString() }
      );

      throw error;
    }
  });
});
```

## Next Steps

- Use `/test-master:debug` to troubleshoot tests with annotations
- Use `/test-master:ci-config` to configure CI reporters
- See `skills/vitest-3-features.md` for more Vitest 3.x capabilities
