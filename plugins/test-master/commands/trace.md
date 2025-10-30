---
description: Analyze Playwright traces for E2E test failures
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

# Analyze Playwright Traces

## Purpose
View and analyze Playwright traces to debug E2E test failures with timeline, screenshots, and network activity.

## Process

1. **Run Tests with Tracing**
   ```bash
   npx playwright test --trace on
   ```

   Or configure in playwright.config.js:
   ```javascript
   use: {
     trace: 'retain-on-failure'  // Only on failures
   }
   ```

2. **Open Trace Viewer**
   ```bash
   npx playwright show-trace trace.zip
   ```

   Or from test results:
   ```bash
   npx playwright show-report
   ```

3. **Analyze Trace**

   **Timeline View:**
   - See all actions in chronological order
   - Identify slow operations
   - Find where test failed

   **Screenshots:**
   - See page state at each step
   - Visual verification of UI state
   - Before/after comparisons

   **Network Activity:**
   - View all HTTP requests
   - Check API responses
   - Identify failed requests

   **Console Logs:**
   - Browser console output
   - JavaScript errors
   - Debug logs

   **DOM Snapshots:**
   - Full page DOM at each step
   - Inspect element properties
   - Check computed styles

4. **Common Issues Found in Traces**

   **Element not found:**
   - Check DOM snapshot at failure
   - Verify selector exists
   - Check element visibility

   **Timing issues:**
   - See how long actions took
   - Identify race conditions
   - Find missing waits

   **Network errors:**
   - Check failed API calls
   - Verify response data
   - Identify timeout issues

   **JavaScript errors:**
   - View console logs
   - Find unhandled exceptions
   - Identify script errors

5. **Debug with Trace**

   Based on trace analysis:
   ```javascript
   // Issue: Element not visible yet
   // Solution: Add explicit wait
   await page.waitForSelector('.element', { state: 'visible' });

   // Issue: Network request not complete
   // Solution: Wait for response
   await page.waitForResponse('**/api/data');

   // Issue: Animation not complete
   // Solution: Wait for load state
   await page.waitForLoadState('networkidle');
   ```

## Trace Features

**Action Timeline:**
- Click, type, navigate actions
- Duration of each action
- Action results (success/failure)

**Video Recording:**
- Full video of test execution
- See exact moment of failure
- Visual debugging

**Network Tab:**
- Request/response details
- Headers and payload
- Status codes

**Source Code:**
- See test code alongside execution
- Match actions to code lines
- Step through test logic

## After Analysis

- Identify root cause of failure
- Fix test or application code
- Add missing waits or assertions
- Re-run test to verify fix
