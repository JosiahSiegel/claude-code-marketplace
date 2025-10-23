---
description: Generate and display detailed coverage reports
---

# Generate Coverage Report

## Purpose
Generate comprehensive test coverage reports with detailed analysis and actionable insights.

## Process

1. **Run Tests with Coverage**
   ```bash
   vitest run --coverage
   ```

2. **Generate Multiple Formats**
   - Text summary in terminal
   - HTML report for browser viewing
   - JSON for programmatic analysis
   - LCOV for CI/CD integration

3. **Open HTML Report**
   ```bash
   open coverage/index.html  # macOS
   start coverage/index.html  # Windows
   xdg-open coverage/index.html  # Linux
   ```

4. **Analyze Report**
   - Overall coverage percentages
   - Per-file coverage breakdown
   - Uncovered lines highlighted
   - Branch coverage details

5. **Identify Priority Files**
   - Sort by coverage percentage
   - Focus on critical files with low coverage
   - Check files against thresholds

## Report Sections

**Summary:**
```
Coverage Summary:
  Statements   : 85.2% ( 1234/1448 )
  Branches     : 78.6% ( 567/721 )
  Functions    : 82.3% ( 234/284 )
  Lines        : 85.8% ( 1201/1400 )
```

**Files Needing Attention:**
- Files below threshold
- Critical code with low coverage
- Recently changed files

## After Generating

- Review coverage trends
- Identify gaps in testing
- Prioritize adding tests
- Share report with team
