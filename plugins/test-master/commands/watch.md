---
description: Start Vitest watch mode for continuous testing
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

# Watch Mode

## Purpose
Run tests continuously during development, re-running tests when files change.

## Process

1. **Start Watch Mode**
   ```bash
   # Watch all tests
   vitest watch

   # Watch specific directory
   vitest watch tests/unit

   # Watch with coverage
   vitest watch --coverage
   ```

2. **Interactive Commands**
   Once watch mode is running, use these keys:
   - `a` - Run all tests
   - `f` - Run only failed tests
   - `u` - Update snapshots
   - `p` - Filter by test name pattern
   - `t` - Filter by test file pattern
   - `q` - Quit watch mode

3. **Monitor File Changes**
   - Vitest automatically detects file changes
   - Re-runs affected tests only (smart re-running)
   - Shows results instantly in terminal

4. **Development Workflow**
   - Write failing test first (TDD)
   - Implement feature while watch mode runs
   - See instant feedback on changes
   - Refactor with confidence

## Configuration

Optimize watch mode in vitest.config.js:

```javascript
export default {
  test: {
    watch: {
      // Ignore node_modules (default)
      ignore: ['**/node_modules/**', '**/dist/**']
    },
    // Reporter optimized for watch mode
    reporter: 'verbose',
    // Update snapshots on change
    snapshotUpdateCommand: 'u'
  }
}
```

## Best Practices

**1. Focus on Relevant Tests**
```bash
# Watch only files matching pattern
vitest watch src/components
```

**2. Use Test Filtering**
- Press `p` then type file pattern
- Press `t` then type test name pattern
- Focus on specific feature being developed

**3. Quick Feedback Loop**
- Keep tests fast (<100ms per test)
- Use `test.only()` to focus on single test temporarily
- Mock expensive operations (API calls, file I/O)

**4. TDD Workflow**
```
1. Write failing test
2. Watch mode shows red (failure)
3. Implement minimal code to pass
4. Watch mode shows green (success)
5. Refactor while staying green
```

## UI Mode (Alternative)

For visual test running:

```bash
# Start Vitest UI
vitest --ui

# Opens browser with visual test runner
# - See test file tree
# - Click to run individual tests
# - View detailed error messages
# - See code coverage visually
```

## Troubleshooting

- **Too many re-runs:** Check ignore patterns in config
- **Tests not re-running:** Ensure file watchers aren't at OS limit
- **Slow watch mode:** Reduce test scope or improve test performance
- **Memory leaks:** Restart watch mode periodically for long sessions
