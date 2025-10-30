---
description: Verify multi-file project structure and cross-file references after creation
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

# Verify Structure

## Purpose
After creating files in a multi-file project, verify that all file paths, references, and dependencies are correct before considering the project complete.

## When to Use
- After completing multi-file website/application creation
- Before delivering a project to the user
- When troubleshooting broken references
- As a final check before committing code

## Instructions

### Verification Checklist

Perform these verification checks systematically:

#### ✓ File Path Verification
```
□ Check all file paths are correct
  - CSS links: <link href="styles.css">
  - JS scripts: <script src="script.js">
  - Images: <img src="image.png">
  - Relative paths match actual file structure
```

#### ✓ Reference Loading Verification
```
□ Ensure CSS/JS references load properly
  - HTML files can find the CSS file
  - JavaScript imports resolve correctly
  - No 404 errors for missing files
  - Correct syntax in link/script tags
```

#### ✓ Navigation Verification (for websites)
```
□ Test navigation between pages
  - All navigation links point to correct files
  - Links use correct relative paths
  - No broken navigation (links to non-existent pages)
  - Back/forward navigation works logically
```

#### ✓ Cross-File Reference Verification
```
□ Validate cross-file dependencies work
  - Components import correctly
  - Modules can access exported functions
  - Shared utilities are accessible
  - API calls reference correct endpoints
```

#### ✓ Consistency Verification
```
□ Check consistency across files
  - Naming conventions are consistent
  - Styling is uniform (if using shared CSS)
  - Code structure follows same patterns
  - Documentation style matches across files
```

## Example Verification Process

For a portfolio website with styles.css, index.html, about.html, projects.html, contact.html:

```
✓ Verification checklist:
  [✓] All HTML files have <link rel="stylesheet" href="styles.css">
  [✓] styles.css exists and has content
  [✓] Navigation links:
      - index.html links to about.html, projects.html, contact.html ✓
      - All other pages link back to index.html ✓
  [✓] All pages use consistent styling from styles.css ✓
  [✓] No broken links or missing file references ✓

Result: Project structure verified, ready to use!
```

## What to Do If Verification Fails

**If you find issues:**
1. Document what's broken
2. Fix the issues systematically
3. Re-run verification
4. Don't consider the project complete until verification passes

**Common Issues:**
- Typos in file paths (`styles.css` vs `style.css`)
- Incorrect relative paths
- Missing files that are referenced
- Inconsistent naming between link and actual file

## Output Format

Provide clear verification results to the user:

```
✅ Project Structure Verified

All checks passed:
- File paths correct
- References loading properly
- Navigation working
- Dependencies resolved
- Consistency maintained

Project ready to use!
```

Or if issues found:

```
⚠️ Verification Issues Found

Issues detected:
1. about.html links to "style.css" but file is named "styles.css"
2. projects.html missing navigation back to index.html

Fixing issues now...
```

## Benefits
- Catch errors before they become problems
- Ensure professional, working deliverables
- Build confidence in multi-file projects
- Reduce back-and-forth with users about broken links
