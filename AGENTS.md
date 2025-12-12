# AGENTS.md - General Directives for AI Coding Assistants

**Last Updated:** 2025-12-09
**Location:** `~/AGENTS.md`

---

## ⚠️ DOTFILES REPOSITORY NOTICE

**If you are working in the dotfiles repository (usually `~/.dotfiles/` or a repo associated with remote dbarnett/dotfiles), you MUST also read `AGENTS.dotfiles.md`.**

That file contains dotfiles-specific instructions, current configuration status, and known issues.

**If you are NOT in the dotfiles repository, ignore this notice.**

---

This file contains general preferences and conventions for AI coding assistants (Claude Code, Cursor, Gemini CLI, etc.) across all projects.

## 📑 Quick Navigation

**Essential sections to read:**
- **📋 How to Use This File** - Setting up project-level AGENTS.md files
- **🐚 Version Control: Jujutsu (jj)** - VCS commands and workflows
- **📁 Branch Metadata** - THIS_BRANCH.md and check_this_branch.sh usage
- **🎯 General Coding Preferences** - Shell scripts, error handling, testing

**See also:**
- `~/AGENTS.TOOLS.local.md` - Tool/MCP server configurations (if exists)
- Project `.cursor/rules/` - IDE-specific coding rules
- Project `AGENTS.local.md` - Machine-specific overrides

---

## 📋 How to Use This File

### In Project-Specific Contexts

You MUST ensure each project/repo includes some self-contained reference to the guidelines mentioned here.
Since many AI tools only read files within the project workspace, you have two main approaches:

#### Option A: Private AGENTS.md (Personal Projects)

Use a **private symlink or hard link** for personal/private repositories:

```shell
# Symlink (recommended)
ln -s ~/AGENTS.md .

# Hard link (if symlinks aren't supported)
ln ~/AGENTS.md .
```

**Then add to `.git/info/exclude`** (NOT `.gitignore`) to keep it private:
```
AGENTS.md
AGENTS.local.md
```

**Why `.git/info/exclude`:**
- Keeps exclusions local to your repository copy
- Avoids cluttering public `.gitignore` with personal config
- Other contributors won't see your personal AGENTS files

#### Option B: Public AGENTS.md (Shared/Open-Source Projects)

Create a **public `AGENTS.md`** with portable conventions for all contributors.

**IMPORTANT:** Design this from scratch - do NOT copy from `~/AGENTS.md` which contains personal preferences. `~/AGENTS.md` will generally be referenced indirectly via `AGENTS.local.md` in this case.

**Public AGENTS.md should include:**
- Project-specific coding conventions
- Testing patterns with examples from the codebase
- Architecture guidelines
- Contribution workflow
- Language-specific preferences relevant to this project

**Required directive at the top:**
```markdown
# Project AGENTS.md

**IMPORTANT:** If `AGENTS.local.md` exists in this repository, you MUST read it
and treat its contents as an extension of this file. The local file may contain
machine-specific or contributor-specific preferences.
```

**For your personal project-specific overrides:**

Create `AGENTS.local.md` and add to `.gitignore`:
```
AGENTS.local.md
```

This is where YOU can put personal preferences specific to this project that shouldn't be shared with other contributors.

### Project-Specific Overrides

- **`AGENTS.local.md`** - Machine-specific or personal preferences (always gitignored)
- **`AGENTS.md`** (public version) - Portable conventions for all contributors
- **Agents MUST read `AGENTS.local.md` if it exists** - treat as extension of AGENTS.md
- When creating public AGENTS.md, include directive to read AGENTS.local.md if present

**What to include in project-specific docs:**
- Concrete examples of good/bad patterns from your actual codebase
- Language-specific testing conventions with real test examples
- Tool-specific rules (e.g., `.cursor/rules/` for Cursor IDE)
- Project architecture patterns and anti-patterns
- Known issues and workarounds specific to this project

### Tool & MCP Server Documentation

**For tool/MCP configuration details:**
- Create `~/AGENTS.TOOLS.local.md` for global tool usage notes and MCP server specifics
- Reference it from project `AGENTS.local.md` files where relevant
- Keep `AGENTS.TOOLS.local.md` untracked and private
- In public/shared AGENTS.md files, only mention which tools/MCPs you use, not how

**Why keep details in local files instead of AGENTS.md:**
- **Platform-dependent:** Different machines may have different agents/MCPs installed
- **Version resilience:** Agents update their config formats; local files don't need repo syncing
- **Privacy:** Avoid committing API patterns, authentication details, access specifics
- **Machine-specific:** Each system can document its actual configuration state

**What to document in AGENTS.TOOLS.local.md:**
- Where MCP servers are configured (file paths, JSON keys)
- How to check for newly installed but undocumented servers
- MCP server usage patterns and caveats
- Tool-specific quirks and best practices
- Known issues and workarounds
- Authentication/access patterns

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

## 📁 Branch Metadata: THIS_BRANCH.md and check_this_branch.sh

Any time you're **branching off from main/master** or **starting a series of changes** in any repo
or project, whether it's code or config or documents you're planning to edit, it's important to
capture the intent in notes and set up a helper script to help verify the work is on track with the
intent and requirements.

**NOTE:** This also applies if you're in the middle of nontrivial changes and notice this guidance
later... it's never too late to get organized!

For any such work, create these files in your project:

### 1. THIS_BRANCH.md (formerly THIS_GIT_BRANCH.md)

**File naming convention:**
- Preferred: `THIS_BRANCH.md`
- Legacy: `THIS_GIT_BRANCH.md` (still supported)
- **If both exist:** `THIS_BRANCH.md` takes precedence
- **If only `THIS_GIT_BRANCH.md` exists:** Treat it the same as `THIS_BRANCH.md`

**Purpose:** Document scope, intentions, TODOs, and notes for the current branch/change lineage.

**Lifecycle:**
- ✅ Create in first change of branch/bookmark
- ✅ Track in version control throughout development
- ✅ Refine continuously as work progresses
- ✅ Update when scope changes or files added
- ⚠️ **Must be excluded/removed before publishing to main**

**THIS_BRANCH.md MUST contain:**
1. **Scope and out-of-scope** - What is/isn't being done
2. **Self-contained instructions for check_this_branch.sh:**
   - When to run it (e.g., "before each `jj new`", "before pushing")
   - How to interpret output
   - What to do when it fails
3. **File list management:**
   - Which files/patterns are checked
   - Instructions: "If we start working on files outside `foo/`, add them to CHECK_FILES in check_this_branch.sh"
4. **Consolidation guidance:**
   - Which checks should migrate to permanent project tests
   - Specific files/locations for permanent checks (e.g., "SVG validation → add to `scripts/validate-svgs.sh`")
   - Migration TODOs throughout branch work, not just at end

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

## How to Use check_this_branch.sh

**When to run:**
- Before each `jj new` (creating new change)
- Before `jj describe` (updating change description)
- Before `jj git push` (pushing bookmark)
- After adding new files to the branch

**What it checks:**
- FIXME comments (blocking - MUST fix before publishing)
- TODO comments (informational only)
- [Add project-specific checks here as they're added]

**If it fails:**
1. Read error messages carefully
2. Fix FIXME comments or convert to TODO
3. Re-run until it passes
4. DO NOT push if check fails

**Updating the file list:**
- Current scope: Files in `<pattern>` (e.g., `posts/`, `public/images/posts/`)
- If you start editing files outside this pattern, add them to CHECK_FILES in check_this_branch.sh
- Keep CHECK_FILES as a static list - do NOT use dynamic VCS queries

## TODO

- [ ] Task 1
- [ ] Task 2
- [ ] Migrate <check-name> to permanent test: `tests/test_<name>.sh` (do this during branch work, not just at end)

## Consolidation Plan

**Checks to migrate to permanent project infrastructure:**
- [ ] SVG validation → Create `scripts/validate-svgs.sh`
- [ ] Link checking → Add to existing `scripts/check-links.sh`
- [ ] [Add more as branch work progresses]

**Migration should happen:**
- Throughout branch work when checks stabilize
- Before publishing, ensure all useful checks have permanent homes
- Document in project README/CONTRIBUTING if needed

## Notes

- Note 1
- Note 2

## Cleanup Checklist (before publish)

- [ ] All in-scope TODOs completed or moved elsewhere
- [ ] Useful checks migrated to permanent project infrastructure
- [ ] Remove/exclude THIS_BRANCH.md from final change(s)
- [ ] Remove/exclude check_this_branch.sh from final change(s)
- [ ] Clean up any other branch-specific tooling
```

### 2. check_this_branch.sh

**Purpose:** Automated checks for files touched in this branch/lineage.

**Lifecycle:**
- ✅ Create in first change of branch/bookmark
- ✅ Track in version control throughout development
- ✅ Expand as new checks become relevant
- ✅ Refine and simplify as checks migrate to permanent infrastructure
- ⚠️ **Must be excluded/removed before publishing to main**

**CRITICAL PRINCIPLES:**

1. **Use STATIC file lists, NOT dynamic VCS queries**
   - ✅ CORRECT: `CHECK_FILES="posts/*.md public/images/*.svg"`
   - ❌ WRONG: `CHECK_FILES=$(jj diff --name-only)` or `git ls-files`
   - **Why:** Static lists are explicit, maintainable, and branch-specific
   - **Why not dynamic:** Overcomplicated, error-prone, defeats the purpose of branch-specific checks

2. **Check files relevant to THIS branch only**
   - Don't scan the entire codebase
   - Use glob patterns when appropriate: `public/images/posts/*.svg`
   - Update CHECK_FILES when scope expands (document this in THIS_BRANCH.md)

3. **Start simple, evolve as needed**
   - Initial: Just FIXME/TODO scanning
   - Add checks as branch work reveals needs
   - Migrate useful checks to permanent infrastructure

4. **Consolidate throughout branch work, not just at end**
   - When a check stabilizes → migrate to permanent test/script
   - Simplify check_this_branch.sh as checks move out
   - Goal: End with trivial script, not masterpiece to delete

**BEST PRACTICES FOR OUTPUT:**

These patterns make check_this_branch.sh more useful for both humans and AI assistants:

1. **Always show current change metadata at the start**
   - Display current + parent change IDs, descriptions, empty status
   - Show position relative to main (e.g., "main+3")
   - Include bookmark/branch name if set
   - **Why:** Helps AI detect when user switched changes between interactions
   - **Why:** Provides immediate context about what's being checked

```shell
# Extract jj metadata
echo "=== Branch Checks for <Project> ==="
echo ""
echo "Current: $CURRENT_CHANGE_ID (empty): Fix typo in docs"
echo "Parent:  $PARENT_CHANGE_ID: Implement feature X"
echo "Branch:  feature-x"
echo "Ahead:   main+3"
echo ""
```

2. **Display timing information at the end**
   - Use millisecond precision for performance awareness
   - Helps identify slow checks that need optimization
   - **Why:** Self-contained performance context AI can notice and act on
   - **Why:** User feedback loop for keeping checks fast

```shell
# Start timing
START_TIME=$(python3 -c 'import time; print(int(time.time() * 1000))')

# ... run checks ...

# End timing
END_TIME=$(python3 -c 'import time; print(int(time.time() * 1000))')
ELAPSED_MS=$((END_TIME - START_TIME))
printf "Checks finished after %d.%03d seconds\n" $((ELAPSED_MS / 1000)) $((ELAPSED_MS % 1000))
```

3. **Consolidate related checks to reduce noise**
   - Group formatting checks (whitespace, tabs, line endings)
   - Combine similar validations (multiple linters for same files)
   - Show single ✅/❌ for grouped checks when all pass/fail
   - Show details only when needed

```shell
# ❌ NOISY - separate output for each
echo "🔍 Checking trailing whitespace..."
echo "✅ No trailing whitespace"
echo "🔍 Checking tabs..."
echo "✅ No tabs"

# ✅ QUIET - consolidated
echo "🔍 Checking formatting (whitespace, tabs)..."
echo "✅ No formatting issues"
```

4. **Include actionable context in output**
   - Explain what checks mean: "(informational only)", "(blocking)"
   - Provide interpretation guidance: "(warnings above are known issue, can be ignored)"
   - Note future improvements: "(will have automated tests when extracted to library)"
   - Give remediation hints: "Fix FIXME comments or convert to TODO"

```shell
echo "📋 TODO comments in branch files (informational only)..."
echo "📝 Testing notes:"
echo "   • phrTables.js: Validated via runSmokeTests() after manual push"
echo "   • Future library extractions will have automated tests here"
```

5. **Use clear visual hierarchy**
   - Use emoji/symbols consistently: 🔍 (running), ✅ (pass), ❌ (fail), ⚠️ (warning)
   - Section headers with ===
   - Indent supporting details
   - Separate sections with blank lines

6. **Handle missing tools gracefully**
   - Check if tool exists before running: `command -v tool >/dev/null 2>&1`
   - Explain when skipping: "(markdownlint not installed, skipping)"
   - Don't fail on optional checks

7. **Provide clear exit context**
   - Summarize results before exit
   - Remind about publication blockers
   - Give specific commands to run next
   - Use appropriate exit codes (0 = success, 1 = error)

```shell
echo "=== Summary ==="
echo "✅ All checks passed"
echo ""
echo "Checks finished after 5.234 seconds"
echo ""
echo "⚠️  REMINDER: This branch is NOT READY FOR PR until:"
echo "   - THIS_BRANCH.md is removed"
echo "   - check_this_branch.sh is removed"
echo ""
echo "   Use: rm THIS_BRANCH.md check_this_branch.sh"
echo "   Then: jj squash (to squash deletion into parent changes)"
```

**Initial Template:**
```bash
#!/usr/bin/env sh
# Branch-specific checks - DO NOT COMMIT TO MAIN

set -e

echo "=== Branch Checks for <bookmark-name> ==="
echo ""
echo "No checks implemented yet."
echo "As you develop, add checks specific to files in this branch."
echo ""
echo "Examples you might add later:"
echo "  - FIXME/TODO scanning in branch-specific files"
echo "  - Run tests for specific modules touched in this branch"
echo "  - Validate SVG syntax for graphics added in this branch"
echo "  - Check markdown links in docs modified here"
echo ""
echo "Remember:"
echo "  - Use STATIC file lists (CHECK_FILES variable)"
echo "  - Don't use dynamic VCS queries"
echo "  - Migrate stable checks to permanent project infrastructure"
echo ""
exit 0
```

**Evolved Template (with static file lists and real checks):**

```bash
#!/usr/bin/env sh
# Branch-specific checks - DO NOT COMMIT TO MAIN

set -e

ERRORS=0
WARNINGS=0

echo "=== Branch Checks for <bookmark-name> ==="
echo ""

# STATIC FILE LIST - Update this when branch scope changes
# DO NOT use dynamic VCS queries like $(jj diff --name-only)
# See THIS_BRANCH.md for instructions on updating this list
# You can use shell globs if all files match a pattern, e.g.:
#   CHECK_FILES=$(echo posts/*.md public/images/posts/*.svg src/components/*.tsx)
# Or list files explicitly:
CHECK_FILES="
posts/my-new-post.md
public/images/posts/diagram-1.svg
public/images/posts/diagram-2.svg
src/components/NewFeature.tsx
"

# CRITICAL: Verify branch metadata files won't be published
echo "🔍 Checking branch metadata cleanup..."
METADATA_IN_CHANGE=0
for file in THIS_BRANCH.md THIS_GIT_BRANCH.md check_this_branch.sh; do
    if jj diff --git -r @ | grep -q "^+.*$file"; then
        echo "⚠️  WARNING: $file is being added in current change"
        METADATA_IN_CHANGE=1
    fi
done

if [ $METADATA_IN_CHANGE -eq 1 ]; then
    echo "❌ ERROR: THIS CHANGE INCLUDES BRANCH METADATA FILES"
    echo ""
    echo "   This change is NOT READY FOR PUBLICATION until:"
    echo "   - THIS_BRANCH.md is removed/excluded"
    echo "   - check_this_branch.sh is removed/excluded"
    echo ""
    echo "   Use: jj restore THIS_BRANCH.md check_this_branch.sh"
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
FIXME_DETAILS=""
for file in $CHECK_FILES; do
    if [ -f "$file" ]; then
        # For markdown files, exclude FIXME in code blocks
        if echo "$file" | grep -q '\.md$'; then
            MATCHES=$(awk '
                /^```/ { in_code = !in_code; next }
                !in_code && /FIXME/ { print NR ":" $0 }
            ' "$file")
        else
            MATCHES=$(grep -n "FIXME" "$file" 2>/dev/null || true)
        fi

        if [ -n "$MATCHES" ]; then
            FIXME_COUNT=$((FIXME_COUNT + 1))
            FIXME_DETAILS="$FIXME_DETAILS
  $file:
$MATCHES
"
        fi
    fi
done

if [ $FIXME_COUNT -gt 0 ]; then
    echo "❌ ERROR: Found FIXME comments in $FIXME_COUNT file(s)"
    echo "$FIXME_DETAILS"
    echo ""
    echo "   FIXME comments MUST be resolved before publishing"
    echo "   Either fix them or convert to TODO if acceptable to defer"
    echo ""
    ERRORS=$((ERRORS + 1))
else
    echo "✅ No FIXME comments found"
fi
echo ""

# INFORMATIONAL: List TODO comments for awareness
echo "📋 TODO comments in branch files (informational)..."
TODO_COUNT=0
for file in $CHECK_FILES; do
    if [ -f "$file" ]; then
        # Suppress known out-of-scope TODOs:
        # Example: | grep -v "TODO.*out-of-scope-pattern"
        MATCHES=$(grep -n "TODO" "$file" 2>/dev/null | grep -v "FIXME" || true)
        if [ -n "$MATCHES" ]; then
            echo "  $file:"
            echo "$MATCHES"
            TODO_COUNT=$((TODO_COUNT + 1))
        fi
    fi
done

if [ $TODO_COUNT -eq 0 ]; then
    echo "   (none found)"
fi
echo ""

# PROJECT-SPECIFIC CHECKS - Add checks relevant to this branch
# When a check stabilizes, migrate it to permanent project infrastructure

# Example: Validate SVG syntax (if working on SVGs in this branch)
SVG_FILES=$(echo "$CHECK_FILES" | grep '\.svg$' || true)
if [ -n "$SVG_FILES" ]; then
    echo "🖼️  Validating SVG syntax..."
    if command -v xmllint >/dev/null 2>&1; then
        for svg in $SVG_FILES; do
            if [ -f "$svg" ]; then
                if ! xmllint --noout "$svg" 2>&1; then
                    echo "❌ ERROR: Invalid SVG syntax in $svg"
                    ERRORS=$((ERRORS + 1))
                fi
            fi
        done
        echo "✅ SVG validation passed"
    else
        echo "⚠️  xmllint not installed, skipping SVG validation"
        WARNINGS=$((WARNINGS + 1))
    fi
    echo ""
    echo "NOTE: Once SVG validation stabilizes, migrate to scripts/validate-svgs.sh"
    echo ""
fi

# Example: Check markdown links (if working on docs in this branch)
MD_FILES=$(echo "$CHECK_FILES" | grep '\.md$' || true)
if [ -n "$MD_FILES" ]; then
    echo "🔗 Checking markdown links..."
    echo "   (not implemented yet)"
    echo ""
    echo "NOTE: When implemented, migrate to scripts/check-links.sh or CI"
    echo ""
fi

echo ""
echo "=== Summary ==="
if [ $ERRORS -gt 0 ]; then
    echo "❌ $ERRORS error(s) found - NOT READY FOR PUBLICATION"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo "⚠️  $WARNINGS warning(s) found - review recommended"
    exit 0
else
    echo "✅ All checks passed"
    exit 0
fi
```

**How to Run:**
```shell
# Run manually (recommended workflow)
./check_this_branch.sh                    # Before jj new
./check_this_branch.sh                    # Before jj describe
./check_this_branch.sh                    # Before jj git push

# Or set up as pre-push hook (optional)
```

**When to Update CHECK_FILES:**
- Added new files to branch → Add to CHECK_FILES list
- Expanded scope to new directories → Add glob patterns
- Document in THIS_BRANCH.md: "If working on files outside `<pattern>`, update CHECK_FILES"

### 3. Consolidation and Publication Workflow

**Core Principle:** Branch metadata files help during development but must NOT be published to main.

**Throughout Branch Work (Continuous Consolidation):**

1. **Migrate stable checks to permanent infrastructure:**
   - When a check proves useful → create permanent script/test
   - Example: SVG validation → `scripts/validate-svgs.sh`
   - Example: Link checking → add to existing `scripts/check-links.sh`
   - Document migration in THIS_BRANCH.md consolidation plan

2. **Simplify check_this_branch.sh as you go:**
   - Remove checks that have been migrated
   - Keep only branch-specific temporary checks
   - Goal: End with minimal script, not complex masterpiece

3. **Update permanent project docs:**
   - Add new checks to README/CONTRIBUTING
   - Update CI/CD configuration if needed
   - Document in THIS_BRANCH.md when this is done

**Before Publication (Three Approaches):**

#### Approach 1: Simple Deletion (Quick, loses metadata for PR revisions)

```shell
# When ready to publish
rm THIS_BRANCH.md check_this_branch.sh
# Note: May also need to squash deletion down through parent changes
jj git push
```

**Pros:** Simple, clean
**Cons:** If PR needs revisions, you won't have the checker anymore

**Use when:** Small PRs unlikely to need revisions

#### Approach 2: Parallel Change Structure (Preserves metadata, more complex)

```shell
# Initial branch setup
jj new -m "Add feature X"  # Change A (published)
jj new -m "Branch metadata for feature X"  # Change A2 (not published)
# Create THIS_BRANCH.md and check_this_branch.sh in A2

# Continue development
jj edit A  # Work on actual feature
# ... make changes ...
jj new -m "Continue feature X"  # Change B (published)
jj new -m "Update branch metadata"  # Change B2 (not published)
jj edit B2
# Update THIS_BRANCH.md, check_this_branch.sh to reflect B's changes

# Publish just the feature changes
jj bookmark set feature-x -r B  # Point bookmark at last published change
jj git push --bookmark feature-x
```

**Pros:** Metadata available throughout PR review process
**Cons:** More complex change graph management

**Use when:** Complex PRs likely to need multiple review iterations

#### Approach 3: Hybrid (Stash commit IDs, restore on demand)

```shell
# During development, track metadata in regular changes

# Before publishing
echo "Last change with metadata: $(jj log -r @ --no-graph -T change_id)" > /tmp/some-branch-metadata-ref
rm THIS_BRANCH.md check_this_branch.sh
jj describe -m "Feature X (ready for review)"
jj git push

# If PR needs revisions, restore metadata
METADATA_CHANGE=$(cat /tmp/some-branch-metadata-ref)
jj new -d X -m "Restore branch metadata for revisions"
jj restore --from "$METADATA_CHANGE" THIS_BRANCH.md check_this_branch.sh
```

**Pros:** Simple during development, can restore if needed
**Cons:** Requires manual tracking of commit IDs

**Use when:** Medium complexity, want flexibility

**Recommendation:** Start with Approach 1 (simple deletion). Only use Approach 2/3 if you actually need to restore metadata during PR review.

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

### Error Handling in Shell Scripts

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

### Output Formatting in Shell Scripts

**CRITICAL: Avoid "log-log-log" patterns for multiline output**

❌ **WRONG - Breaks vertical alignment:**
```shell
echo "=== Summary ==="
echo "  Status:    ✅ Passed"
echo "  Files:     42"
echo "  Time:      1.234s"

# Especially bad when variables have different widths:
for file in $FILES; do
    echo "Processing: $file"  # Breaks alignment in logs
    echo "  Status:   $status"
    echo "  Size:     $size"
done
```

✅ **CORRECT - Use single output for block-formatted content:**
```shell
# Pattern 1: printf with format string
printf "=== Summary ===
  Status:    ✅ Passed
  Files:     %d
  Time:      %.3fs
" "$file_count" "$elapsed"

# Pattern 2: Heredoc or here-string (POSIX sh)
cat <<EOF
=== Summary ===
  Status:    ✅ Passed
  Files:     $file_count
  Time:      ${elapsed}s
EOF

# Pattern 3: Build string then output once
output="=== Summary ===
  Status:    ✅ Passed
  Files:     $file_count
  Time:      ${elapsed}s"
echo "$output"
```

**Why this matters:**
- Multiple echo calls break vertical alignment when buffered or redirected
- Log viewers may interleave output from parallel processes between echo calls
- Block-formatted output (tables, aligned columns) must stay together
- Single output statement ensures atomic write to stdout/logs

**When multiline output is acceptable:**
- ✅ Separate logical sections: different echo for different sections
- ✅ Progressive status updates: "Processing file 1... done", "Processing file 2... done"
- ✅ Streaming output where each line is independent
- ❌ NEVER: Block-formatted tables or aligned columns with multiple echo calls

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

### Logging Patterns

**AVOID consecutive Logger.log calls ("log-log-log" antipattern):**

❌ **WRONG - Multiple calls break vertical alignment:**
```javascript
Logger.log('⚠️  WARNING: Something is wrong');
Logger.log('   Expected: This should happen');
Logger.log('   Suggestion: Do this instead');
```

✅ **CORRECT - Single multi-line call:**
```javascript
Logger.log('⚠️  WARNING: Something is wrong\n' +
           '   Expected: This should happen\n' +
           '   Suggestion: Do this instead');
```

❌ **WRONG - Ugly block text output in shell:**
```shell
echo "Doing something"
echo ""
echo "Details:"
echo "  - Item 1"
echo "  - Item 2"
```

✅ **CORRECT - Output one message as one message:**
```shell
echo "Doing something

Details:
  - Item 1
  - Item 2"
```

**Newline usage:**
- Use `\n` only to separate lines WITHIN a message
- Don't add leading or trailing `\n` unless you specifically want a blank line after the message
- `Logger.log('Line 1\nLine 2')` outputs two lines + automatic newline at end
- `Logger.log('Message\n\n')` outputs message + blank line (double newline)

**Why this matters:**
- Multiple Logger.log calls may interleave with other logs in concurrent execution
- Single call ensures message stays together as atomic block
- Consistent newline handling prevents unexpected blank lines

❌ **WRONG - Weird leading/trailing newlines:**
```javascript
Logger.log('\n=== Doing thing ===');
Logger.log('Finished\n');
```
✅ **CORRECT - Output without leading/trailing newlines:**
```javascript
Logger.log('=== Doing thing ===');
Logger.log('Finished');
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
