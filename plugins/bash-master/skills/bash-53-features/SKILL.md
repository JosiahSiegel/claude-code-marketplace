---
name: bash-53-features
description: |
  Bash 5.3 new features and modern patterns (2025).
  PROACTIVELY activate for: (1) Bash 5.3 specific features (BASH_TRAPSIG, in-shell command substitution, ${|} REPLY syntax), (2) checking bash version compatibility, (3) migrating scripts to take advantage of 5.3 additions, (4) C23 conformance changes in bash 5.3, (5) new shopt and bind options, (6) trap handling improvements, (7) wait -p enhancements, (8) READLINE_ARGUMENT and history expansion changes.
  Provides: complete 5.3 feature reference, version-detection snippets, compatibility shims for older bash, migration recipes, and POSIX.1-2024 alignment notes.
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

# Bash 5.3 Features (2025)

## Overview

Bash 5.3 (released July 2025) introduces significant new features that improve performance, readability, and functionality.

## Key New Features

### 1. In-Shell Command Substitution

**New: ${ command; } syntax** - "nofork comsub" - Executes without forking a subshell (runs in current shell context):

```bash
# (Bash < 5.3) - Creates subshell
var=$(cmds...)

# (Bash 5.3+) - Bash code runs in the current shell. Stdout is redirected to a memfd. For external commands there is no advantage.
var=${ cmds...; }
```
**When to use:**
- For running "native" bash code in the current shell environment - capturing and expanding output.
- Useful for builtins that only write a result to stdout and cannot perform direct assignments. E.g. `

**When not to use:**
- Single external command invocations where no side-effects to the shell environment need to be propagated.
- the shell will fork and directly exec wc in both cases below
- No shell state to isolate means the `${ ...; }` is pointless.
- No performance advantage. memfd creation is likely slightly slower. Bash falls back to temp files if memfds are unsupported.
- Syntax is not backwards compatible.

**Bad Example:**
```bash
#!/usr/bin/env bash

# normal comsub
count=0
for file in *.txt; do
    lines=$(wc -l < "$file")  # forks and execs wc
    ((count += lines))
done

# pointless use of ${ ; }
count=0
for file in *.txt; do
    lines=${ wc -l < "$file"; }  # identical
    ((count += lines))
done
```

2 x `clone()` and 2 x `execve()` each.
```bash
 $ ( for c in 'printf %s\\n {0..9} | x=$(wc -l)' 'printf %s\\n {0..9} | x=${ wc -l; }'; do strace --seccomp-bpf -cDDqqqfe t=%process,pipe2,memfd_create bash -O lastpipe -c "$c"; echo; done )
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
 84.26    0.000091          45         2           clone
  8.33    0.000009           2         4         1 wait4
  7.41    0.000008           4         2           pipe2
  0.00    0.000000           0         2           execve
------ ----------- ----------- --------- --------- ----------------
100.00    0.000108          10        10         1 total


% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
 57.79    0.000167          83         2           execve
 33.91    0.000098          49         2           clone
  4.84    0.000014           4         3         1 wait4
  1.73    0.000005           5         1           pipe2
  1.73    0.000005           5         1           memfd_create
------ ----------- ----------- --------- --------- ----------------
100.00    0.000289          32         9         1 total
```

** Advanced I/O **
Example 1: stealing the output fd

Since there's no subshell, nothing stops us from repurposing the output fd we're expected to be writing to.
```bash
( bash -x /proc/self/fd/9 9<<\_EOF )
function f {
        typeset x y z=moo
        local -p ${ exec 3<&1; } ${| exec <&3-; } 1<&0
        ksh -c "exec <##(())" # lseek()
        cat
}
f
_EOF
+ f
+ typeset x y z=moo
++ exec
++ exec
+ local -p
+ ksh -c 'exec <##(())'
+ cat
declare -- x
declare -- y
declare -- z="moo"
```

Note: bash does ruin the fun by calling `memfd_create` with `MFD_NOEXEC_SEAL`, which means it can never be `exec`'d, and since the seal is sealed on creation this is irreversable.

Example 2: pipe -> memfd zero-copy splice

```bash
 $ time ( echo; bash /proc/self/fd/9 9<<\_EOF 8<<\_EOF )
shopt -s lastpipe
{
        pipesz -n 1
        pipesz -gn 3 3<&1 1<&2;
        head -c "$(( 4 * 2 ** 31 ))" </dev/urandom
} | len=${ python3 /proc/self/fd/8 "${| ${ exec {REPLY}<&1; }; }"; } fd=$_ || exit # Inner assignment to `REPLY` falls through to ${|; }
printf 'bytes copied: %d\n' "$len"
lsfd -p "$BASHPID" -Q "FD==${fd}" -o +flags,pos,size
exec {fd}<&-
_EOF
from os import (splice, lseek, fsencode, isatty, SEEK_SET)
from sys import (stdout, argv, exit)
s = 0
try: stdout.buffer.write(fsencode(str(sum(iter(lambda: splice(0, int(argv[1]), 2 ** 31), 0))) + ("\n" * isatty(1))))
except: s = 1
lseek(int(argv[1]), 0, SEEK_SET)
exit(s)
_EOF

fd 3    1048576 0
bytes copied: 8589934592
COMMAND     PID   USER ASSOC  XMODE TYPE SOURCE MNTID     INODE NAME                      FLAGS POS       SIZE
bash    1029883 ormaaj    10 rw-D--  REG    0:1     0 139515462 /memfd:anonopen  rdwr,largefile   0 8589934592

real    0m20.290s
user    0m1.605s
sys     0m23.344s
```

The end result is a seekable read/write `$fd` containing everything that was in the pipe, with the total read bytes captured into `$len`. Bash has the seek position rewound to zero so the shell is free to use it as it wants. 

### 2. REPLY Variable Command Substitution

**New: ${| command; } syntax** - Expands the value of REPLY:

```bash
# Runs command, result goes to $REPLY automatically
printf %s\\n "${|(( REPLY = complex_calculation * 42))}"

# Multiple commands using a locally scoped variable.
printf 'Got: %s\n' "${| typeset local_var=processing; printf -v REPLY '%s: %s' "$local_var" "$((42 * 2))"; }"
```

**Use Cases:**
- Avoid variable naming conflicts
- Clean syntax for temporary values
- Standardized result variable

### 3. Enhanced `read` Builtin

**New: -E option** - Uses readline with programmable completion:

```bash
# Interactive input with tab completion
read -E -p "Enter filename: " filename
# User can now tab-complete file paths!

# With custom completion
read -E -p "Select environment: " env
# Enables full readline features (history, editing)
```

**Benefits:**
- Better UX for interactive scripts
- Built-in path completion
- Command history support

### 4. Enhanced `source` Builtin

**New: -p PATH option** - Custom search path for sourcing:

```bash
# OLD way
source /opt/myapp/lib/helpers.sh

# NEW way - Search custom path
source -p /opt/myapp/lib:/usr/local/lib helpers.sh

# Respects CUSTOM_PATH instead of current directory
CUSTOM_PATH=/app/modules:/shared/lib
source -p "$CUSTOM_PATH" database.sh
```

**Benefits:**
- Modular library organization
- Avoid hard-coded paths
- Environment-specific sourcing

### 5. Enhanced `compgen` Builtin

**New: Variable output option** - Store completions in indexed array:

```bash
# OLD way - Output to stdout
completions=$(compgen -f)

# NEW way - Assigns directly to array variable
compgen -V completions_var -f
# Results now in completions_var
```

**Benefits:**
- Cleaner completion handling
- No extra subshells
- Better performance

### 6. GLOBSORT Variable

**New: Control glob sorting behavior**:

```bash
# Default: alphabetical sort
echo *.txt

# Sort by modification time (newest first)
GLOBSORT="-mtime"
echo *.txt

# Sort by size
GLOBSORT="size"
echo *.txt

# Reverse alphabetical
GLOBSORT="reverse"
echo *.txt
```

**Options:**
- `name` - Alphabetical (default)
- `reverse` - Reverse alphabetical
- `size` - By file size
- `mtime` - By modification time
- `-mtime` - Reverse modification time

### 7. BASH_TRAPSIG Variable

**New: Signal number variable in traps**:

```bash
#!/usr/bin/env bash
set -euo pipefail

# BASH_TRAPSIG contains the signal number being handled
handle_signal() {
    echo "Caught signal: $BASH_TRAPSIG" >&2
    case "$BASH_TRAPSIG" in
        15) echo "SIGTERM (15) received, shutting down gracefully" ;;
        2)  echo "SIGINT (2) received, cleaning up" ;;
        *)  echo "Signal $BASH_TRAPSIG received" ;;
    esac
}

trap handle_signal SIGTERM SIGINT SIGHUP
```

**Benefits:**
- Reusable signal handlers
- Dynamic signal-specific behavior
- Better logging and debugging

### 8. Floating-Point Arithmetic

**New: `fltexpr` loadable builtin**:

```bash
# Enable floating-point support
enable -f /usr/lib/bash/fltexpr fltexpr

# Perform calculations
fltexpr 'result = 42.5 * 1.5'
echo "$result"  # 63.75

# Complex expressions
printf 'Area: %f\\n' "${| fltexpr 'REPLY = 3.14159 * 5 * 5'; }"
echo "Area: $pi_area"
```

**Use Cases:**
- Scientific calculations
- Financial computations
- Avoid external tools (bc, awk)

## Performance Improvements

### Avoid Subshells

```bash
# ❌ OLD (Bash < 5.3) - Multiple subshells
for i in {1..1000}; do
    result=$(echo "$i * 2" | bc)
    process "$result"
done

# ✅ NEW (Bash 5.3+) - No subshells
for i in {1..1000}; do
    result=${ echo $((i * 2)); }
    process "$result"
done
```

**Performance Gain:** ~40% faster in benchmarks

### Efficient File Processing

```bash
#!/usr/bin/env bash

# Process large file efficiently
process_log() {
    local line_count=0
    local error_count=0

    while IFS= read -r line; do
        ((line_count++))

        # Bash 5.3: No subshell for grep
        if ${ grep -q "ERROR" <<< "$line"; }; then
            ((error_count++))
        fi
    done < "$1"

    echo "Processed $line_count lines, found $error_count errors"
}

process_log /var/log/app.log
```

## Migration Guide

### Check Bash Version

```bash
#!/usr/bin/env bash

# Require Bash 5.3+
if ((BASH_VERSINFO[0] < 5 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] < 3))); then
    echo "Error: Bash 5.3+ required (found $BASH_VERSION)" >&2
    exit 1
fi
```

### Feature Detection

```bash
# Test for 5.3 features
has_bash_53_features() {
    # Try using ${ } syntax
    if eval 'test=${ echo "yes"; }' 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

if has_bash_53_features; then
    echo "Bash 5.3 features available"
else
    echo "Using legacy mode"
fi
```

### Gradual Adoption

```bash
#!/usr/bin/env bash
set -euo pipefail

# Support both old and new bash
if ((BASH_VERSINFO[0] > 5 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] >= 3))); then
    # Bash 5.3+ path
    result=${ compute_value; }
else
    # Legacy path
    result=$(compute_value)
fi
```

## Best Practices (2025)

1. **Use ${ } for performance-critical loops**
   ```bash
   for item in "${large_array[@]}"; do
       processed=${ transform "$item"; }
   done
   ```

2. **Use ${| } for clean temporary values**
   ```bash
   ${| calculate_hash "$file"; }
   if [[ "$REPLY" == "$expected_hash" ]]; then
       echo "Valid"
   fi
   ```

3. **Enable readline for interactive scripts**
   ```bash
   read -E -p "Config file: " config
   ```

4. **Use source -p for modular libraries**
   ```bash
   source -p "$LIB_PATH" database.sh logging.sh
   ```

5. **Document version requirements**
   ```bash
   # Requires: Bash 5.3+ for performance features
   ```

## Compatibility Notes

### Bash 5.3 Availability (2025)

**Note:** Bash 5.3 (released July 2025) is the latest stable version. There is no Bash 5.4 as of October 2025.

- **Linux**: Ubuntu 24.04+, Fedora 40+, Arch (current)
- **macOS**: Homebrew (`brew install bash`)
- **Windows**: WSL2 with Ubuntu 24.04+
- **Containers**: `bash:5.3` official image

### C23 Conformance

Bash 5.3 updated to C23 language standard. **Note:** K&R style C compilers are no longer supported.

### Fallback Pattern

```bash
#!/usr/bin/env bash
set -euo pipefail

# Detect bash version
readonly BASH_53_PLUS=$((BASH_VERSINFO[0] > 5 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] >= 3)))

process_items() {
    local item
    for item in "$@"; do
        if ((BASH_53_PLUS)); then
            result=${ transform "$item"; }  # Fast path
        else
            result=$(transform "$item")      # Compatible path
        fi
        echo "$result"
    done
}
```

## Resources

- [Bash 5.3 Release Notes](https://lists.gnu.org/archive/html/bash-announce/2025-07/msg00000.html)
- [Bash Manual - Command Substitution](https://www.gnu.org/software/bash/manual/html_node/Command-Substitution.html)
- [ShellCheck Bash 5.3 Support](https://github.com/koalaman/shellcheck/releases)

---

**Bash 5.3 provides significant performance and usability improvements. Adopt these features gradually while maintaining backwards compatibility for older systems.**
