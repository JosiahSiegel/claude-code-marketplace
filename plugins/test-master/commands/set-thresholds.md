---
description: Update coverage thresholds in configuration
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

# Set Coverage Thresholds

## Purpose
Update coverage thresholds in vitest.config.js to enforce minimum test coverage standards.

## Process

1. **Current Thresholds**
   Read vitest.config.js and display current thresholds:
   ```
   Current thresholds:
   - Lines: 70%
   - Functions: 70%
   - Branches: 65%
   - Statements: 70%
   ```

2. **Suggest New Thresholds**
   Based on current coverage:
   ```
   Current coverage: 85%
   Suggested threshold: 80% (5% buffer)
   ```

3. **Ask for New Values**
   ```
   Enter new thresholds:
   ? Lines (70%): › 80
   ? Functions (70%): › 80
   ? Branches (65%): › 75
   ? Statements (70%): › 80
   ```

4. **Per-File Thresholds**
   ```
   Add per-file thresholds for critical files? (yes/no) › yes

   ? File pattern: › src/security/**/*.js
   ? Lines: › 95
   ? Functions: › 100
   ```

5. **Update Configuration**
   ```javascript
   export default {
     test: {
       coverage: {
         thresholds: {
           lines: 80,
           functions: 80,
           branches: 75,
           statements: 80,
           'src/security/**/*.js': {
             lines: 95,
             functions: 100
           }
         }
       }
     }
   };
   ```

6. **Verify**
   ```bash
   npm run test:coverage
   ```

## Best Practices

- Set thresholds 5-10% below current coverage
- Higher thresholds for critical code
- Gradually increase over time
- Don't chase 100% coverage

## After Setting

- Thresholds updated in vitest.config.js
- Tests run to verify compliance
- Team notified of new standards
