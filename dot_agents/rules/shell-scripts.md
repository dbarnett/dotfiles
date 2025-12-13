# Shell Script Guidelines

**When to read this file:** You MUST read this file when writing, debugging, or reviewing shell scripts.

---

## Shell Compatibility

**CRITICAL: Do not assume bash-specific features will work**

- **Always use ````shell` markdown fence**, not ````bash`, unless specifically requiring bash
- **User runs fish shell** - many tools (especially Cursor) generate bash code that breaks in fish
- **Avoid bashisms** - common problematic patterns:
  - ❌ Heredocs (`cat <<EOF` / `cat <<'EOF'`) - break in fish
  - ❌ Process substitution (`<(command)`) - not portable
  - ❌ Bash arrays (`arr=(a b c)` / `${arr[@]}`) - fish uses different syntax
  - ❌ `[[` conditional (`[[ -f file ]]`) - use `[` or `test` instead
  - ❌ `source` command - use `.` for POSIX compatibility (though fish supports `source`)

- **Prefer portable POSIX sh patterns:**
  - ✅ Simple `[` conditionals: `[ -f file ]`
  - ✅ Pipe chains: `command1 | command2`
  - ✅ Command substitution: `$(command)` or backticks
  - ✅ Basic variable expansion: `${var}`
  - ✅ For loops: `for item in list; do ...; done`

- **When scripting is unavoidable:**
  - Start scripts with `#!/usr/bin/env sh` for portability
  - Test in user's actual shell environment before assuming it works
  - Document if a script genuinely requires bash: `#!/usr/bin/env bash`

**Note:** Claude Code internally runs Bash tool commands in bash, but generated scripts and code suggestions should still be shell-agnostic since users may run them in their preferred shell.

---

## Error Handling in Shell Scripts

**CRITICAL: NEVER use `|| true` to hide failures**

❌ **WRONG - Hides failures:**
```shell
RESULT=$(some_command || true)
pgrep -x dunst || true
```

✅ **CORRECT - Check exit codes explicitly:**
```shell
# Pattern 1: Check with if statement
if pgrep -x dunst >/dev/null 2>&1; then
    DUNST_RUNNING=1
else
    DUNST_RUNNING=0
fi

# Pattern 2: Capture output and check status separately
CONFIG_ERRORS=$(hyprctl configerrors 2>&1)
if [ $? -ne 0 ]; then
    echo "ERROR: Command failed"
    exit 1
fi

# Pattern 3: Explicit error handling
if ! command_that_might_fail; then
    echo "ERROR: Command failed"
    ERRORS=$((ERRORS + 1))
fi
```

**Why this matters:**
- `|| true` makes every command "succeed" even when it fails
- Failures silently propagate, making debugging impossible
- Status codes contain important information about what went wrong
- Proper error handling allows scripts to report actionable diagnostics

**When checking if a process exists:**
- ✅ Redirect output: `pgrep -x process >/dev/null 2>&1`
- ✅ Check exit code: `if pgrep -x process >/dev/null 2>&1; then ...`
- ❌ NEVER: `pgrep -x process || true`

**CRITICAL: Check actual exit codes and stderr, don't assume failure reasons**

❌ **WRONG - Assumes any failure means specific thing:**
```shell
# Assumes any exit code means "not found"
if ! some_command; then
    echo "Command not found"
fi

# Assumes any failure means file doesn't exist
result=$(cat file.txt 2>&1) || echo "File doesn't exist"
```

✅ **CORRECT - Check exit codes and stderr explicitly:**
```shell
# Check exit code explicitly
if ! output=$(some_command 2>&1); then
    exit_code=$?
    if [ $exit_code -eq 127 ]; then
        echo "ERROR: Command not found"
    elif [ $exit_code -eq 1 ]; then
        echo "ERROR: Command failed: $output"
    else
        echo "ERROR: Command failed with exit code $exit_code"
    fi
fi

# Check stderr for specific error messages
if ! result=$(cat file.txt 2>&1); then
    if echo "$result" | grep -q "No such file"; then
        echo "File doesn't exist"
    elif echo "$result" | grep -q "Permission denied"; then
        echo "Permission denied"
    else
        echo "Failed to read file: $result"
    fi
fi
```

**Why this matters:**
- Exit codes carry specific meaning (127=not found, 1=general error, 2=misuse, etc.)
- stderr contains diagnostic information about what actually went wrong
- Assuming failure reasons leads to misleading error messages
- Proper diagnostics make debugging possible
