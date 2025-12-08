# AGENTS.md - General Directives for AI Coding Assistants

**Last Updated:** 2025-12-05
**Location:** `~/AGENTS.md`

---

## ⚠️ DOTFILES REPOSITORY NOTICE

**If you are working in the dotfiles repository (usually `~/.dotfiles/` or a repo associated with remote dbarnett/dotfiles), you MUST also read `AGENTS.dotfiles.md`.**

That file contains dotfiles-specific instructions, current configuration status, and known issues.

**If you are NOT in the dotfiles repository, ignore this notice.**

---

This file contains general preferences and conventions for AI coding assistants (Claude Code, Cursor, Gemini CLI, etc.) across all projects.

---

## 📋 How to Use This File

### In Project-Specific Contexts

You MUST ensure each project/repo includes some self-contained reference to the guidelines mentioned here.
Since many AI tools only read files within the project workspace, you have three options:

1. **Symlink** (recommended):
   ```shell
   ln -s ~/AGENTS.md .
   ```

2. **Hard link** (if symlinks aren't supported):
   ```shell
   ln ~/AGENTS.md .
   ```

3. **Copy** (last resort):
   ```shell
   cp ~/AGENTS.md .
   ```
   **⚠️ If manually copied:** Add this header to your project's `AGENTS.md`:
   ```
   <!-- Copied from ~/AGENTS.md on YYYY-MM-DD -->
   <!-- TODO: Verify daily this is up-to-date with ~/AGENTS.md -->
   ```

### Project-Specific Overrides

- Create `AGENTS.local.md` in your project for project-specific directives
- The `AGENTS.local.md` should be considered an extension of this file
- Convention: Either track `AGENTS.md` (symlink/copy) + gitignore `AGENTS.local.md`, OR gitignore both
- Recommended: Check AGENTS.md into version control, gitignore AGENTS.local.md

**What to include in project-specific docs:**
- Concrete examples of good/bad patterns from your actual codebase
- Language-specific testing conventions with real test examples
- Tool-specific rules (e.g., `.cursor/rules/` for Cursor IDE)
- Project architecture patterns and anti-patterns
- Known issues and workarounds specific to this project

---

## 🐚 Version Control: Jujutsu (jj)

All my projects use **Jujutsu** ([jj-vcs.dev](https://jj-vcs.dev/)) instead of direct git commands.

### Key Concepts

Jujutsu flips traditional git workflows:

- **Continuous snapshots**: Changes are automatically snapshotted from your working directory (anything not in `.gitignore`)
- **Change-centric**: You work with "changes" (stable change IDs) rather than commits (which are transient)
- **No explicit staging**: Working directory changes automatically become part of the current change
- **Amending is automatic**: `jj commit` creates a new change on top; modifications to current change happen automatically
- **Bookmarks not branches**: Use bookmarks to point to specific changes (like git branches, but moveable)
- **Immutability**: Changes become immutable after pushing to remote

### Essential Commands Cheatsheet

```shell
# Check status of current change
jj status

# View current change with file statistics
jj show --stat

# View change history with statistics
jj log --stat

# View compact change graph
jj log

# Create new change on top of current (stops updating current change)
jj new

# Create new change with description
jj new -m "Description of what I'm working on"

# Describe/update current change description
jj describe

# Amend/modify current change (though this happens automatically)
jj squash  # squash current into parent

# View diff of current change
jj diff

# View diff with statistics
jj diff --stat

# Move between changes
jj edit <change-id>  # make a specific change current
jj prev             # move to parent change
jj next             # move to child change

# Bookmarks (like git branches)
jj bookmark create <name>     # create bookmark at current change
jj bookmark set <name>        # move bookmark to current change
jj bookmark list              # list all bookmarks

# Push to remote
jj git push                   # push current bookmark
jj git push --all             # push all bookmarks
jj git push --change @        # push current change (creates branch)

# Pull from remote
jj git fetch                  # fetch from all remotes
jj git fetch --all-remotes    # fetch from all configured remotes

# Abandon changes (like git reset)
jj abandon                    # abandon current empty change
jj abandon <change-id>        # abandon specific change

# Undo last operation
jj undo

# Restore files from a change
jj restore --from <change-id>
```

### Common Workflows

**Starting new work:**
```shell
jj new -m "Implement feature X"
# Make changes, they auto-snapshot to current change
jj show --stat  # review what's changed
```

**Switching contexts:**
```shell
jj new -m "Quick bugfix"
# Work on bugfix
jj new  # start another change on top, or...
jj edit <change-id>  # jump to different change
```

**Preparing for review:**
```shell
jj log --stat  # review all changes in lineage
jj describe  # polish change description
jj git push  # push bookmark to remote
```

**Checking what's happening:**
```shell
jj status         # what files changed in current change
jj show --stat    # current change summary
jj log --stat     # history with file stats
jj log -r ::@     # changes from root to current
```

---

## 📁 Necessary conventions for changes in any project

Any time you're **branching off from main/master** or **starting a series of changes** in any repo
or project, whether it's code or config or documents you're planning to edit, it's important to
capture the intent in notes and set up a helper script to help verify the work is on track with the
intent and requirements.

NOTE: This also applies if you're in the middle of nontrivial changes and notice this guidance
later... it's never too late to get organized!

For any such work, create these files in your project:

### 1. `THIS_GIT_BRANCH.md`

**Purpose:** Document scope, intentions, TODOs, and notes for the current branch/change lineage.

**Lifecycle:**
- ✅ Track in version control
- ✅ Maintain throughout development
- ⚠️ **Must be cleaned up before publishing/merging**

**Template:**
```markdown
# Branch: <bookmark-name or change description>

**Created:** YYYY-MM-DD
**Last Updated:** YYYY-MM-DD
**Change ID:** <jj change-id>

## Scope

What changes are in scope for this branch/lineage?

## Out of Scope

What explicitly will NOT be done here?

## TODO

- [ ] Task 1
- [ ] Task 2

## Notes

- Note 1
- Note 2

## Cleanup Checklist (before merge)

- [ ] All TODOs completed or moved elsewhere
- [ ] Remove THIS_GIT_BRANCH.md
- [ ] Remove check_this_branch.sh
- [ ] Clean up any other branch-specific tooling
```

### 2. `check_this_branch.sh`

**Purpose:** Automated checks for files touched in this branch/lineage.

**Lifecycle:**
- ✅ Track in version control
- ✅ Expand as checks become relevant
- ⚠️ **Must be removed before publishing/merging**

**Initial Template:**
```bash
#!/usr/bin/env sh
# Branch-specific checks - DO NOT COMMIT TO MAIN

set -e

echo "=== Branch Checks for <bookmark-name> ==="
echo "No checks implemented yet."
echo "TODO: Add checks once there's something interesting to validate"
echo ""
echo "Examples of future checks:"
echo "  - Run tests for touched modules"
echo "  - Validate documentation links"
echo "  - Check code formatting"
echo "  - Validate config files build correctly"
echo "  - Verify ASCII art alignment"
exit 0
```

**Evolved Template (once there are real checks):**
```bash
#!/usr/bin/env sh
# Branch-specific checks - DO NOT COMMIT TO MAIN

set -e

ERRORS=0
WARNINGS=0

echo "=== Branch Checks for <bookmark-name> ==="
echo ""

# CRITICAL: Check that this script and THIS_GIT_BRANCH.md will be removed
echo "🔍 Checking branch metadata cleanup..."
if jj diff --git -r @ | grep -q "^+.*check_this_branch.sh" || \
   jj diff --git -r @ | grep -q "^+.*THIS_GIT_BRANCH.md"; then
    echo "⚠️  WARNING: Branch metadata files are being added in current change"
fi

CHANGED_FILES=$(jj diff --git -r @ --name-only 2>/dev/null || jj show --stat --no-graph | grep '|' | awk '{print $1}')
if echo "$CHANGED_FILES" | grep -q "check_this_branch.sh" || \
   echo "$CHANGED_FILES" | grep -q "THIS_GIT_BRANCH.md"; then
    echo "❌ ERROR: THIS CHANGE INCLUDES BRANCH METADATA FILES"
    echo ""
    echo "   This change is NOT READY FOR CODE REVIEW until:"
    echo "   - THIS_GIT_BRANCH.md is removed/excluded"
    echo "   - check_this_branch.sh is removed/excluded"
    echo ""
    echo "   Use: jj restore THIS_GIT_BRANCH.md check_this_branch.sh"
    echo "   Or create these files in a separate change that won't be published"
    echo ""
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Branch metadata files excluded from change"
fi
echo ""

# CRITICAL: Check for FIXME comments (must be resolved before publishing)
echo "🔍 Scanning for FIXME comments (blocking)..."
FIXME_COUNT=0
for file in $CHANGED_FILES; do
    if [ -f "$file" ]; then
        if grep -n "FIXME" "$file" 2>/dev/null; then
            FIXME_COUNT=$((FIXME_COUNT + 1))
        fi
    fi
done

if [ $FIXME_COUNT -gt 0 ]; then
    echo ""
    echo "❌ ERROR: Found FIXME comments in $FIXME_COUNT file(s)"
    echo "   FIXME comments MUST be resolved before publishing to version control"
    echo "   Either fix them or convert to TODO if they're acceptable to defer"
    echo ""
    ERRORS=$((ERRORS + 1))
else
    echo "✅ No FIXME comments found"
fi
echo ""

# INFORMATIONAL: List TODO comments for awareness
echo "📋 TODO comments in changed files (informational)..."
TODO_COUNT=0
for file in $CHANGED_FILES; do
    if [ -f "$file" ]; then
        # Suppress known out-of-scope TODOs here:
        # Example: | grep -v "TODO.*out-of-scope-pattern"
        if grep -n "TODO" "$file" 2>/dev/null | grep -v "FIXME"; then
            TODO_COUNT=$((TODO_COUNT + 1))
        fi
    fi
done

if [ $TODO_COUNT -eq 0 ]; then
    echo "   (none found)"
fi
echo ""

# Example: Check documentation links
if echo "$CHANGED_FILES" | grep -q '\.md$'; then
    echo "→ Checking markdown links..."
    # Add your link checker here
    echo "   (not implemented)"
fi

# Example: Run relevant tests
if echo "$CHANGED_FILES" | grep -q 'src/auth/'; then
    echo "→ Running auth tests..."
    # pytest tests/test_auth*.py
    echo "   (not implemented)"
fi

# Example: Validate configs
if echo "$CHANGED_FILES" | grep -q 'config/'; then
    echo "→ Validating config builds..."
    # ./scripts/build_config.sh --dry-run
    echo "   (not implemented)"
fi

# Example: Check ASCII art alignment
if echo "$CHANGED_FILES" | grep -q 'docs/diagrams/'; then
    echo "→ Validating ASCII diagram alignment..."
    # Custom validation script
    echo "   (not implemented)"
fi

echo ""
echo "=== Summary ==="
if [ $ERRORS -gt 0 ]; then
    echo "❌ $ERRORS error(s) found - NOT READY FOR REVIEW"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo "⚠️  $WARNINGS warning(s) found - review recommended"
    exit 0
else
    echo "✅ All checks passed"
    exit 0
fi
```

**Usage:**
```shell
# Run manually before pushing
./check_this_branch.sh

# Or set up as pre-push hook
```

---

## 🎯 General Coding Preferences

### Shell Compatibility

**CRITICAL: Do not assume bash-specific features will work**

- **Always use ````shell` markdown fence**, not ````bash`, unless specifically requiring bash
- **I use fish shell** - many tools (especially Cursor) generate bash code that breaks in fish
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

### File Editing
- Clean up trailing whitespace (except `.md` files)
- Ensure newline at end of file
- Preserve existing indentation style (tabs vs spaces)

### Code Comments: FIXME vs TODO

**CRITICAL DISTINCTION:**

- **`FIXME`** - MUST be resolved **BEFORE** publishing to version control
  - Use for broken code, temporary hacks, security issues, data corruption risks
  - Treat as blocking issues that make code not production-ready
  - `check_this_branch.sh` will fail if any FIXME comments remain
  - Either fix the issue or downgrade to TODO if it's acceptable to defer

- **`TODO`** - Can be published, represents future work
  - Use for enhancements, optimizations, refactoring ideas
  - `check_this_branch.sh` will list these for awareness but not fail
  - Add to TODO list in THIS_GIT_BRANCH.md if in scope
  - Suppress known out-of-scope TODOs in check_this_branch.sh:
    ```shell
    grep -n "TODO" "$file" | grep -v "TODO.*out-of-scope-pattern"
    ```

### Documentation
- When code changes, update related docs immediately
- Add "Last Updated" timestamps to docs
- Keep docs concise and scannable

### Testing

**Core Principles:**
- **One test = one thing** - Each test should verify a single behavior
- **Use parameterized tests** for variations of the same test logic
- **Functional tests spanning multiple components** → separate test file/directory

**Test Doubles: Avoid Overmocking**

**CRITICAL: Test real behavior, not mocks**

- **Prefer real implementations** over mocks whenever practical
  - Use real objects, real methods, real integrations
  - Only mock external dependencies (APIs, databases, file systems, time)
  - Mocking internal code masks real bugs and makes tests brittle

- **Use appropriate test doubles:**
  - **Stub** - Provides canned responses to calls (for dependencies)
  - **Fake** - Working implementation with shortcuts (in-memory DB, fake API)
  - **Spy** - Records calls made to it for verification
  - **Mock** - Pre-programmed with expectations and verifies them
  - **Dummy** - Passed around but never used (satisfies parameters)

- **Test behaviors, not implementation details:**
  - ✅ Test public APIs and observable outcomes
  - ❌ Don't mock/verify internal method calls
  - ✅ Verify state changes or side effects
  - ❌ Don't verify the exact sequence of internal operations

**Project-Specific Examples:**

These guidelines should be reflected in your project's documentation with concrete examples:

- **AGENTS.local.md** - Project-specific testing conventions
- **.cursor/rules/** - IDE-specific test generation rules
- **AGENTS.md** (project version) - Extended testing examples

**Template for project documentation:**
```markdown
## Testing Examples

### ✅ Good: Testing real behavior
<!-- Insert real example from your codebase -->
def test_user_registration():
    user_service = UserService(real_db_connection)
    user = user_service.register("user@example.com")
    assert user_service.find_by_email("user@example.com") == user

### ❌ Bad: Overmocking internals
<!-- Insert hypothetical bad example in your language -->
def test_user_registration():
    mock_validator = Mock()
    mock_hasher = Mock()
    user_service = UserService(mock_db, mock_validator, mock_hasher)
    # Testing implementation details, not behavior
```

**When examples become outdated:**
- Fix bad code immediately when discovered
- Update docs to reference new positive examples
- Keep one historical bad example as documentation (clearly marked)

### Error Handling
- Don't guess error causes from message text
- Only state what's explicitly known from error metadata

---

## 🔧 Tool-Specific Notes

### Memory and Context Management

**General principle:** Each tool should use its native memory mechanisms primarily.

- **Use your tool's native memory** - Cursor has user memory, Claude Code has memories, etc.
- **This file contains shared conventions** - things relevant across multiple tools
- **Don't overthink cross-tool setup** - it's fine to help other agents work on the same code, but don't spend energy creating elaborate rules you won't actively use yourself

### Claude Code
- Use symbolic code navigation tools when available
- Check memories at session start for codebase context
- Memories store codebase architecture, patterns, and known issues

### Cursor
- Cursor has its own user memory mechanism - rely on that
- Use `.cursor/rules/` for Cursor-specific code generation preferences
- This file should set up reasonable context for Cursor without duplicating its memory

### Gemini CLI
- (Add Gemini-specific preferences as you discover them)

---

## 📝 Conventions Reference

### Emoji Tags for Grepping
Use in notes and commit messages:
- 🐛 Bugs
- 📚 Documentation
- ⚡ Performance
- ✨ New features
- 🔧 Configuration
- 🧪 Tests
- 🔒 Security

### Change Descriptions (jj describe)
```
<emoji> <Short summary (50 chars)>

<Detailed explanation of what and why>

- Specific change 1
- Specific change 2

Fixes: #issue-number (if applicable)
```

---

## ⚠️ Important Reminders

1. **Always use `jj` commands**, not `git` directly (except `jj git push/fetch`)
2. **Check `jj status` and `jj show --stat`** before creating new changes
3. **Use ````shell` not ````bash`** in markdown unless bash-specific features required
4. **Avoid bashisms** (heredocs, process substitution, etc.) - I use fish shell
5. **Clean up `THIS_GIT_BRANCH.md` and `check_this_branch.sh`** before merging
6. **FIXME = blocking, TODO = deferrable** - check_this_branch.sh enforces this
7. **Avoid overmocking in tests** - test real behavior with appropriate test doubles
8. **Update project docs with concrete examples** when implementing these guidelines
9. **Update this file's timestamp** when making changes
10. **Verify project `AGENTS.md` is current** if manually copied (not symlinked)

---

**End of AGENTS.md** - See project-specific `AGENTS.local.md` for overrides
