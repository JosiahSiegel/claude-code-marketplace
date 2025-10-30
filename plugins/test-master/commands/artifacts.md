---
description: Manage test artifacts (traces, screenshots, videos)
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

# Manage Test Artifacts

## Purpose
Configure and manage test artifacts including traces, screenshots, and videos for debugging test failures.

## Process

1. **Configure Artifact Generation**

   **Playwright Configuration:**
   ```javascript
   export default {
     use: {
       screenshot: 'only-on-failure',
       video: 'retain-on-failure',
       trace: 'retain-on-failure'
     }
   };
   ```

   **Options:**
   - `'on'` - Always capture
   - `'off'` - Never capture
   - `'retain-on-failure'` - Only on test failure
   - `'on-first-retry'` - On retry attempts

2. **Artifact Locations**
   ```
   playwright-report/      # HTML report
   test-results/           # Screenshots, videos, traces
     └── test-name/
         ├── screenshot.png
         ├── video.webm
         └── trace.zip
   ```

3. **View Artifacts**

   **Screenshots:**
   ```bash
   open test-results/*/screenshot.png
   ```

   **Videos:**
   ```bash
   open test-results/*/video.webm
   ```

   **Traces:**
   ```bash
   npx playwright show-trace test-results/*/trace.zip
   ```

4. **CI Artifact Upload**

   **GitHub Actions:**
   ```yaml
   - name: Upload artifacts
     if: failure()
     uses: actions/upload-artifact@v3
     with:
       name: test-results
       path: test-results/
   ```

5. **Clean Up Artifacts**
   ```bash
   # Remove old artifacts
   rm -rf test-results/ playwright-report/

   # Add to .gitignore
   test-results/
   playwright-report/
   ```

## Artifact Storage

**Vitest Coverage:**
- Location: `coverage/`
- Format: HTML, JSON, LCOV
- Keep for analysis

**Playwright:**
- Screenshots: PNG
- Videos: WebM
- Traces: ZIP
- Keep only on failure (saves space)

## After Configuration

- Artifacts generated on failure
- Stored in appropriate directories
- Uploaded to CI for review
- Old artifacts cleaned up
