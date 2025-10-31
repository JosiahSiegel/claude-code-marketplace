# ADO Master Plugin Changelog

## [1.5.0] - 2025-10-31

### Added - Windows/Git Bash Compatibility

- **New Skill: `ado-windows-git-bash-compatibility`** - Comprehensive Windows/Git Bash path handling for Azure Pipelines
  - Complete MINGW/MSYS path conversion mastery
  - `MSYS_NO_PATHCONV` usage patterns and best practices
  - `cygpath` manual conversion examples (Unix/Windows/Mixed formats)
  - Shell detection using `$(Agent.OS)`, `uname -s`, and `$OSTYPE`
  - Cross-platform script patterns for Windows/Linux/macOS agents
  - Windows agent diagnostics and troubleshooting scripts
  - Azure DevOps CLI path handling on Windows
  - Common failure patterns with solutions (backslash escape, argument conversion, Docker volumes)
  - Platform-specific step conditions and reusable templates
  - Git configuration for Windows agents
  - `System.PreferGitFromPath` usage guidance
  - Quick reference card for Windows scenarios

### Enhanced - Cross-Platform Support

- **ado-expert.md agent**: Added Windows/Git Bash compatibility expertise section
  - Path conversion mastery subsection
  - Shell detection code examples
  - Cross-platform script patterns
  - Common Windows issues and solutions
  - Best practices for Windows agents

- **ado-pipeline-create.md command**: Added Windows Agent & Git Bash Compatibility section
  - Common Windows issues with YAML examples (backslash escape, path conversion, Docker mounts)
  - Cross-platform script pattern template
  - Platform detection with matrix strategy
  - Git configuration for Windows agents
  - Quick reference table for troubleshooting

- **ado-cli.md command**: Added Windows Agent Path Handling section
  - Azure DevOps CLI path issues and solutions
  - Cross-platform CLI script patterns
  - Repository operations with proper path handling
  - File path parameter examples
  - Quick reference for Windows scenarios

- **README.md**: Updated with v1.5.0 Windows compatibility features
  - New skill prominently featured
  - Windows compatibility enhancements listed
  - Cross-platform compatibility added to key principles

- **plugin.json**: Enhanced with Windows/Git Bash capabilities
  - Updated description with Windows path handling
  - Added keywords: windows, git-bash, mingw, cross-platform
  - Comprehensive feature list including MSYS_NO_PATHCONV, cygpath, shell detection

### Technical Details

**New Content:**
- 1 comprehensive skill (ado-windows-git-bash-compatibility.md): ~550 lines
- Enhanced agent expertise: +40 lines
- Enhanced pipeline creation guidance: +135 lines
- Enhanced CLI guidance: +90 lines
- Updated README and plugin.json

**Windows Compatibility Coverage:**
- ✅ MINGW/MSYS automatic path conversion explained
- ✅ `MSYS_NO_PATHCONV=1` usage patterns
- ✅ `MSYS2_ARG_CONV_EXCL` selective exclusion
- ✅ `cygpath` manual conversion (Unix/Windows/Mixed)
- ✅ Shell detection: `$(Agent.OS)`, `uname -s`, `$OSTYPE`
- ✅ Cross-platform script templates
- ✅ Platform-specific conditions
- ✅ Azure DevOps CLI path handling
- ✅ Git configuration for Windows
- ✅ Docker volume mount fixes
- ✅ Diagnostic scripts for troubleshooting
- ✅ Common error patterns with solutions

**Why This Matters:**
- Azure Pipelines frequently run on Windows agents
- Teams use Git Bash for scripting consistency
- MINGW path conversion causes cryptic failures
- No comprehensive guidance existed before
- Saves hours of debugging time

**Real-World Problems Solved:**
1. `System.DefaultWorkingDirectory` backslash escaping failures
2. Docker volume mount path conversion breaking containers
3. Azure DevOps CLI argument path conversion
4. Unquoted paths with spaces causing "Access denied"
5. `/d` and `/s` arguments incorrectly converted to Windows paths
6. Colon-separated path lists breaking in MINGW

### Improved

- **Cross-Platform Compatibility**: All commands now include Windows-specific guidance
- **Troubleshooting**: Diagnostic scripts for identifying path issues
- **Examples**: Platform detection patterns in all pipeline examples
- **Documentation**: Consistent Windows/Git Bash notes throughout plugin

### Keywords Added

- windows
- git-bash
- mingw
- cross-platform

---

## [1.4.0] - 2025-10-30

### Added - New Commands

- **`/ado-workload-identity`** - Configure workload identity federation (OIDC) for passwordless Azure authentication
  - Complete setup and migration guidance
  - Automatic and manual configuration workflows
  - Service principal to OIDC migration patterns
  - Least privilege and security best practices
  - Troubleshooting and debugging guidance
  - 2025 Microsoft security standard implementation

- **`/ado-pipeline-analytics`** - Analyze pipeline performance, track metrics, and identify optimization opportunities
  - Success rate tracking and trend analysis
  - Duration metrics and bottleneck identification
  - Cost analysis and parallel job consumption
  - Agent utilization monitoring
  - Automated analytics dashboards with YAML examples
  - Azure DevOps CLI integration for metrics
  - Alerting and notification setup

- **`/ado-quality-gates`** - Implement quality gates and code quality enforcement
  - SonarQube and SonarCloud integration
  - Code coverage threshold enforcement
  - Multi-language linting (JavaScript, Python, C#, Go)
  - Security quality gate integration
  - Branch policy and environment gate configuration
  - Custom quality validation logic
  - Quality metrics dashboard and reporting

### Enhanced

- **plugin.json & marketplace.json**: Updated to version 1.4.0 with aligned descriptions
  - Added workload identity and analytics capabilities to descriptions
  - Added new keywords: oidc, workload-identity, analytics, performance
  - Comprehensive feature coverage in description

- **README.md**: Expanded with new command documentation
  - Added v1.4.0 features section
  - Included usage examples for new commands
  - Updated command list with three new additions

### Improved

- **Content Portability**: Removed all user-specific paths and personal information
  - Generic placeholder names (your-org, your-project, my-app)
  - No hardcoded machine paths or hostnames
  - Portable examples across all documentation

- **Link Optimization**: Converted absolute URLs to relative markdown links
  - Improved readability and maintainability
  - Consistent linking patterns throughout

### Fixed

- **Version Alignment**: Ensured plugin.json and marketplace.json versions match exactly
  - Both files now at version 1.4.0
  - Synchronized descriptions and feature lists

### Technical Details

**File Count:**
- Commands: 11 total (+3 new)
- Skills: 3 (unchanged)
- Agents: 1 (unchanged)

**New Features Coverage:**
- Workload identity federation (OIDC) - Microsoft 2025 security standard
- Pipeline performance analytics - Cost tracking and optimization
- Quality gates - Code quality enforcement with SonarQube

**Documentation Quality:**
- All new commands include complete YAML examples
- Troubleshooting sections for common issues
- Best practices and recommended configurations
- Integration patterns with existing Azure DevOps features

---

## [1.3.0] - 2025 (Previous Release)

### Added

- Microsoft Security DevOps (MSDO) extension integration
- Pipeline template management command (`/ado-templates`)
- Agent v4 with .NET 8 and ARM64 support documentation
- Sprint 261-262 features: OAuth migration to Entra ID, GitHub Copilot integration
- Continuous Access Evaluation (CAE) security features
- Updated OS images: Ubuntu-24.04, Windows-2025, macOS-15

### Enhanced

- Security scanning with MSDO (replaces deprecated CredScan)
- Defender for DevOps skill with comprehensive guidance
- Sprint 254-262 feature documentation

---

## Production Readiness Assessment

**Status: PRODUCTION READY** ✅

### Completeness
- ✅ All 11 commands fully documented
- ✅ Comprehensive YAML examples in all commands
- ✅ Skills cover 2025 features (Sprints 254-262) + Windows compatibility
- ✅ Agent provides expert-level guidance with cross-platform expertise

### Portability
- ✅ No user-specific paths (C:\Users, /home/)
- ✅ No personal information
- ✅ Generic placeholder names throughout
- ✅ Cross-platform compatible examples (Windows/Linux/macOS)

### Version Integrity
- ✅ plugin.json version: 1.5.0
- ✅ Versions aligned and synchronized

### Feature Coverage
- ✅ Windows/Git Bash path handling - MINGW/MSYS expertise (NEW v1.5.0)
- ✅ Cross-platform pipeline scripts - Windows/Linux/macOS (NEW v1.5.0)
- ✅ Workload identity (OIDC) - 2025 security standard
- ✅ Pipeline analytics - Performance and cost tracking
- ✅ Quality gates - Code quality enforcement
- ✅ Microsoft Security DevOps integration
- ✅ Agent v4 with ARM64 support
- ✅ Latest Sprint 254-262 features
- ✅ Template management and reusability

### Documentation Quality
- ✅ Comprehensive usage examples
- ✅ Troubleshooting guidance (including Windows-specific)
- ✅ Best practices included
- ✅ Clear command descriptions
- ✅ Windows path guidelines in all files
- ✅ Cross-platform script patterns throughout

### Security Features
- ✅ Workload identity federation (passwordless auth)
- ✅ Microsoft Security DevOps (MSDO)
- ✅ Continuous Access Evaluation (CAE)
- ✅ Secrets management with Azure Key Vault
- ✅ Comprehensive security scanning

### Performance Features
- ✅ Pipeline analytics and monitoring
- ✅ Cost optimization guidance
- ✅ Caching and parallelization patterns
- ✅ Agent optimization strategies

### Quality Features
- ✅ Quality gates with SonarQube
- ✅ Code coverage enforcement
- ✅ Multi-language linting
- ✅ Security quality integration

### Windows Compatibility Features (NEW v1.5.0)
- ✅ MINGW/MSYS path conversion expertise
- ✅ MSYS_NO_PATHCONV usage patterns
- ✅ Shell detection (Agent.OS, uname, OSTYPE)
- ✅ Cross-platform script templates
- ✅ Azure DevOps CLI on Windows guidance
- ✅ Git Bash troubleshooting and diagnostics
- ✅ Docker volume mount path fixes
- ✅ Windows agent configuration best practices

---

## Improvement Summary

**Total Changes:**
- 3 new commands created
- 2 existing files updated (README, plugin.json)
- 1 marketplace.json updated
- Version bumped from 1.3.0 to 1.4.0
- 100% portable content (no user-specific paths)

**Impact:**
- 27% command increase (8 → 11 commands)
- Comprehensive 2025 Azure DevOps coverage
- Microsoft security best practices implemented
- Performance monitoring and optimization enabled
- Code quality enforcement capabilities added

**Lines of Documentation Added:**
- ado-workload-identity.md: ~700 lines
- ado-pipeline-analytics.md: ~600 lines
- ado-quality-gates.md: ~500 lines
- Total: ~1,800 lines of production-ready documentation

---

## Next Steps for Users

1. **Try the new commands:**
   ```bash
   /ado-workload-identity  # Set up passwordless authentication
   /ado-pipeline-analytics # Monitor pipeline performance
   /ado-quality-gates      # Enforce code quality
   ```

2. **Migrate to workload identity:**
   - Eliminate service principal secrets
   - Implement 2025 security standards
   - Reduce credential management overhead

3. **Monitor pipeline performance:**
   - Track success rates and trends
   - Identify bottlenecks
   - Optimize costs

4. **Enforce quality standards:**
   - Set up SonarQube integration
   - Configure coverage thresholds
   - Automate quality checks

---

**Plugin Maintainer:** Josiah Siegel
**Last Updated:** 2025-10-31
**Status:** Production Ready
**Version:** 1.5.0
