---
description: Run E2E tests in headed mode with visible browser
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

# Run Tests in Headed Mode

## Purpose
Run Playwright E2E tests with visible browser windows for debugging and visual verification.

## Process

1. **Run in Headed Mode**
   ```bash
   npx playwright test --headed
   ```

   Or specific test:
   ```bash
   npx playwright test tests/e2e/login.spec.js --headed
   ```

2. **Slow Down Execution**
   ```bash
   npx playwright test --headed --slow-mo=1000
   ```

   Adds 1 second delay between actions for observation.

3. **Watch Test Execution**
   - See browser open
   - Watch actions happen in real-time
   - Observe page states
   - Notice visual issues

4. **Debug Mode**
   ```bash
   npx playwright test --debug
   ```

   Opens Inspector with:
   - Step-through execution
   - Pause/resume controls
   - Action highlighting
   - DOM inspection

## Use Cases

**Visual Debugging:**
- See what the test sees
- Identify UI issues
- Verify interactions
- Check animations

**Slow Operation Debugging:**
- Watch slow loading
- Identify bottlenecks
- See network delays

**Selector Debugging:**
- See which elements are clicked
- Verify selector accuracy
- Check element visibility

**Demo/Documentation:**
- Show test execution to team
- Create test documentation
- Validate test scenarios

## Configuration

Configure default headed mode in playwright.config.js:

```javascript
export default defineConfig({
  use: {
    headless: false,  // Always run headed
    slowMo: 500,      // Slow down by 500ms
  }
});
```

## After Running Headed

- Visual confirmation of test behavior
- Identified any UI issues
- Debugged timing problems
- Verified test accuracy
