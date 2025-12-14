# Branch Metadata: THIS_BRANCH.md and check_this_branch.sh

**When to read this file:** You MUST read this file when:
- Starting work on a new branch/bookmark
- Creating or updating THIS_BRANCH.md or check_this_branch.sh
- Working on nontrivial changes that span multiple commits

---

Any time you're **branching off from main/master** or **starting a series of changes** in any repo
or project, whether it's code or config or documents you're planning to edit, it's important to
capture the intent in notes and set up a helper script to help verify the work is on track with the
intent and requirements.

**NOTE:** This also applies if you're in the middle of nontrivial changes and notice this guidance
later... it's never too late to get organized!

For any such work, create these files in your project:

## 1. THIS_BRANCH.md (formerly THIS_GIT_BRANCH.md)

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

## 2. check_this_branch.sh

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
# Extract jj metadata - CORRECT patterns with proper error handling
echo "=== Branch Checks for <Project> ==="
echo ""

# Get current change info
CURRENT_ID=$(jj log -r @ --no-graph -T 'change_id.short(7)' 2>&1)
CURRENT_EXIT=$?
if [ $CURRENT_EXIT -ne 0 ]; then
    echo "Current: ERROR - $CURRENT_ID" >&2
else
    CURRENT_DESC=$(jj log -r @ --no-graph -T 'description.first_line()' 2>&1)
    CURRENT_EMPTY=$(jj log -r @ --no-graph -T 'if(empty, " (empty)", "")' 2>&1)
    echo "Current: $CURRENT_ID$CURRENT_EMPTY - $CURRENT_DESC"
fi

# Get parent change info
PARENT_ID=$(jj log -r @- --no-graph -T 'change_id.short(7)' 2>&1)
PARENT_EXIT=$?
if [ $PARENT_EXIT -ne 0 ]; then
    echo "Parent:  ERROR - $PARENT_ID" >&2
else
    PARENT_DESC=$(jj log -r @- --no-graph -T 'description.first_line()' 2>&1)
    echo "Parent:  $PARENT_ID - $PARENT_DESC"
fi

# Show distance from main (how many commits ahead)
DISTANCE=$(jj log -r '::@ ~ ::main' --no-graph -T '' | wc -l 2>&1)
if [ "$DISTANCE" -gt 0 ] 2>/dev/null; then
    echo "Ahead:   main+$DISTANCE"
fi

# Show bookmark/branch name if set
BOOKMARK=$(jj log -r @ --no-graph -T 'bookmarks' 2>&1)
if [ -n "$BOOKMARK" ] && [ "$BOOKMARK" != "(no bookmarks)" ]; then
    echo "Branch:  $BOOKMARK"
fi
echo ""
```

**Common jj template mistakes to avoid:**
- ❌ `short_change_id` - keyword doesn't exist
- ✅ `change_id.short(7)` - correct method call syntax
- ❌ `$(jj ... 2>/dev/null || echo "unknown")` - silently hides real errors
- ✅ `$(jj ... 2>&1)` then check `$?` and surface errors to stderr
- ❌ `description` alone - returns full multi-line description
- ✅ `description.first_line()` - just the summary line

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
    echo "   Use: rm THIS_BRANCH.md check_this_branch.sh"
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

## 3. Consolidation and Publication Workflow

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

### Approach 1: Simple Deletion (Quick, loses metadata for PR revisions)

```shell
# When ready to publish
rm THIS_BRANCH.md check_this_branch.sh
# Note: May also need to squash deletion down through parent changes
jj git push
```

**Pros:** Simple, clean
**Cons:** If PR needs revisions, you won't have the checker anymore

**Use when:** Small PRs unlikely to need revisions

### Approach 2: Parallel Change Structure (Preserves metadata, more complex)

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

### Approach 3: Hybrid (Stash commit IDs, restore on demand)

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
