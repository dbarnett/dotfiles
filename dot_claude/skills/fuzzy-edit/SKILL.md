---
name: fuzzy-edit
description: This skill should be used when Edit tool fails with "old_string not found", "string not found", or indentation mismatch errors. Also use when editing files with tab indentation (Python, Go, Makefiles, TypeScript) or when the Edit tool has failed multiple times on the same edit. Provides the agents-fuzzy-edit-args utility to fix Edit arguments by re-reading actual files.
version: 1.0.0
---

# Fuzzy Edit - Fix Edit Tool Arguments

## Purpose

The Read tool sometimes shows incorrect indentation (tabs as spaces or vice versa), causing Edit tool to fail because old_string doesn't match the actual file. This skill provides a utility that re-reads the actual file, finds the correct old_string with proper indentation, and outputs corrected arguments for Edit tool.

## When to Use

Use this skill when:
- Edit tool fails with "old_string not found" or match errors
- Working with files that use tabs for indentation (common in Python, Go, Makefiles)
- Previously had Edit failures on a file
- Uncertain if Read tool is showing correct indentation

## Workflow

### Standard Edit Workflow (with fuzzy-edit)

1. **Read the file** - Note line numbers and content to edit
2. **Run the utility** - Get corrected Edit arguments:
   ```shell
   agents-fuzzy-edit-args --file /path/to/file --old 'text from Read' --new 'replacement'
   ```
3. **Parse output** - Extract corrected OLD_STRING and NEW_STRING from output
4. **Use Edit tool** - Call Edit with corrected arguments for user approval

### Example

```shell
# Step 1: Read file shows (possibly wrong indentation):
# 10    def calculate(x):
# 11        return x * 2

# Step 2: Get corrected arguments
agents-fuzzy-edit-args \
  --file /tmp/script.py \
  --old 'def calculate(x):
    return x * 2' \
  --new 'def calculate(x, y):
    return x * y'

# Output:
# OLD_STRING="\tdef calculate(x):\n\t\treturn x * 2"
# NEW_STRING="\tdef calculate(x, y):\n\treturn x * y"
# Match confidence: 88.3%

# Step 3: Use corrected values with Edit tool
Edit(
  file_path="/tmp/script.py",
  old_string="\tdef calculate(x):\n\t\treturn x * 2",
  new_string="\tdef calculate(x, y):\n\treturn x * y"
)
```

## Utility Script

### Location

The utility is installed at `~/.local/bin/agents-fuzzy-edit-args` (which is in PATH).

Call it directly by name - no path needed:

```shell
agents-fuzzy-edit-args --file PATH --old 'approximate old' --new 'replacement'
```

**Parameters:**
- `--file PATH` - File to edit (required)
- `--old TEXT` - Approximate old_string from Read tool (required)
- `--new TEXT` - New replacement text (required)
- `--json` - Output JSON format instead of shell format (optional)

**Output (default shell format):**
```
OLD_STRING="corrected text with proper tabs/spaces"
NEW_STRING="replacement with matched indentation"
```

**Output (--json format):**
```json
{
  "old_string": "corrected text",
  "new_string": "replacement text"
}
```

**Exit codes:**
- 0 = Success, corrected args in stdout
- 1 = No match found or error

### How It Works

1. **Fuzzy matching** - Finds closest match to old_string (≥80% similarity threshold)
2. **Extracts exact text** - Returns actual bytes from file with real indentation
3. **Fixes new_string** - Applies same indentation style to replacement
4. **User approval** - Corrected args used with Edit tool for interactive approval

The utility normalizes whitespace for comparison (tabs→spaces) but preserves exact indentation from the actual file in the output.

## Benefits Over Manual Debugging

**Old workflow (don't do this):**
1. Read file
2. Try Edit
3. Edit fails with "old_string not found"
4. Run `cat -A` to check indentation
5. Try Edit again with adjusted indentation
6. Still fails
7. Write custom perl/sed script to debug
8. Give up or waste significant time

**New workflow (use this):**
1. Read file
2. Run `agents-fuzzy-edit-args` to get corrected args
3. Use corrected args with Edit tool
4. Edit succeeds on first try ✓

## Important Notes

- **This is NOT invoked via Skill tool** - Always call via Bash tool
- **Read-only operation** - The utility never modifies files, only analyzes
- **Safe to run unconditionally** - No side effects, purely informational
- **User approval still required** - Edit tool provides interactive approval
- **Handles multi-line edits** - Works with any size old_string/new_string
- **Preserves indentation style** - Detects and maintains tabs vs spaces

## Common Errors

### "Could not find fuzzy match"

**Cause:** The old_string differs too much from file content (< 80% similarity).

**Solutions:**
- Verify editing the correct file
- Check if content was already changed
- Ensure old_string is approximately correct
- Try a smaller, more unique old_string

### "File not found"

**Cause:** File path doesn't exist.

**Solutions:**
- Verify file path is correct
- Use absolute path, not relative
- Check file hasn't been moved/deleted

## Advanced Usage

### JSON Output for Parsing

When programmatic parsing is needed:

```bash
result=$(agents-fuzzy-edit-args --file path --old 'text' --new 'text' --json)
old_string=$(echo "$result" | jq -r '.old_string')
new_string=$(echo "$result" | jq -r '.new_string')
```

### Match Confidence

The utility outputs match confidence on stderr:
```
Match confidence: 88.3%
```

Higher is better. Typical values:
- **95-100%** - Nearly exact match, just whitespace differences
- **85-95%** - Good match, some minor differences
- **80-85%** - Acceptable match, verify correctness
- **< 80%** - No match returned (threshold not met)

## Best Practices

1. **Use proactively** - Don't wait for Edit to fail, use on tab-indented files
2. **Verify output** - Check the diff in Edit tool approval UI
3. **Keep old_string approximate** - The utility handles minor differences
4. **Let utility fix indentation** - Don't manually adjust tabs/spaces
5. **Trust the fuzzy matcher** - It's designed to handle Read tool bugs

## Integration Pattern

When editing files with potential indentation issues:

```
1. Read file to understand content
2. Identify what to change
3. Run agents-fuzzy-edit-args to get corrected params
4. Parse output (OLD_STRING=... NEW_STRING=...)
5. Call Edit tool with corrected values
6. User reviews and approves in Edit UI
```

This pattern ensures Edit succeeds on first attempt while maintaining user approval workflow.
