# Maintaining AGENTS Documentation Files

**Last Updated:** 2025-12-16

---

## Overview

This guide explains how to create, organize, and maintain AGENTS.md and ~/.agents/ documentation files for AI coding assistants.

---

## Core Principles

### 1. "When to read" directives go in the REFERENCING file, not the target file

- ❌ WRONG: Put "When to read this:" inside `jj-howto.md`
- ✅ CORRECT: Put directive in `AGENTS.global.md` Quick Navigation
- **Why:** By the time you're reading the file, it's too late to know you should read it

**Example:**
```markdown
<!-- In AGENTS.global.md -->
**Specialized guides (you MUST read when relevant):**
- **`~/.agents/jj-howto.md`** - READ when working with version control in repos with `.jj/`
```

### 2. Keep AGENTS.global.md scannable - extract details to separate files

- Main file: Brief intro + "MUST read X file when doing Y"
- Separate files: Detailed commands, workflows, examples
- **Ratio guideline:** If a section is longer than the actual changes it documents, extract it

**Example of good refactoring:**
- Before: AGENTS.global.md had 100 lines of jj commands
- After: AGENTS.global.md has 4-line intro + directive, `jj-howto.md` has 100+ lines
- Result: Main file is scannable, detailed info available when needed

### 3. File organization patterns

**Directory structure:**
- `~/.agents/X-howto.md` - How-to guides (jj-howto, git-howto, mcp-project-overrides, agents-files-howto)
- `~/.agents/rules/X.md` - Rules and conventions (shell-scripts, testing, branch-metadata, obsidian)

**Content distinction:**
- **Howtos:** Reference documentation, commands, workflows, step-by-step instructions
- **Rules:** Requirements, patterns to follow/avoid, validation criteria, "MUST/MUST NOT" directives

### 4. When to create a new .agents file

Create a separate file when ANY of these apply:
- Topic has 50+ lines of detailed content
- Topic is only relevant in specific contexts (not all projects)
- Content includes many examples or command references
- You find yourself scrolling past it frequently in the main file
- Content needs updating independently from AGENTS.global.md

### 5. Required updates when adding a new .agents file

**Checklist:**
- [ ] Add to Quick Navigation in AGENTS.global.md with "READ when X" directive
- [ ] Add to Important Reminders if it's critical (e.g., security, data loss prevention)
- [ ] Update "Last Updated" timestamp in AGENTS.global.md
- [ ] Include clear examples in the new file (don't just describe, show)
- [ ] Remove detailed content from AGENTS.global.md, keep only brief intro + directive

**Example commit:**
```
📚 .agents: Extract jj details to jj-howto.md

Keep AGENTS.global.md scannable by moving detailed jj commands
and workflows to separate howto file.
```

### 6. Cross-referencing pattern

**For critical/required content:**
```markdown
**➡️ When doing X, you MUST read `~/.agents/X-howto.md` for detailed instructions.**
```

**For optional/supplementary content:**
```markdown
**See also:**
- `~/AGENTS.TOOLS.local.md` - Tool/MCP server configurations (if exists)
```

**Usage guidelines:**
- Use "MUST read" for critical/required reading
- Use "See also" for optional supplementary content
- Always use full path (`~/.agents/file.md`) for clarity
- Include context: "READ when X" not just "READ this file"

### 7. Naming conventions

**Files:**
- Use kebab-case for filenames (`jj-howto.md`, not `jj_howto.md`)
- Descriptive names (`mcp-project-overrides.md` > `mcp.md`)
- Rules go in `rules/` subdirectory
- Howtos go in top-level `~/.agents/`

**Structure:**
- Start with `# Title` (H1) - no "When to read this:" section
- Include "Last Updated" timestamp for maintenance tracking
- Use `---` separators between major sections
- Include examples, not just prose

### 8. Don't duplicate - reference

**Avoid duplication:**
- If content exists in a howto file, reference it from AGENTS.global.md
- Don't copy-paste between files
- Keep single source of truth for each topic

**Acceptable duplication:**
- Quick reference examples in main file (2-3 lines)
- Critical security warnings that should be seen in multiple places
- Cross-references that add context

---

## Common Patterns

### Adding a new howto file

```shell
# 1. Create the file
cat > ~/.agents/my-topic-howto.md << 'EOF'
# My Topic Howto

**Last Updated:** $(date +%Y-%m-%d)

---

## Overview
[Brief description]

## [Sections with examples]
EOF

# 2. Update AGENTS.global.md Quick Navigation
# Add to "Specialized guides" section:
# - **`~/.agents/my-topic-howto.md`** - READ when working with my-topic

# 3. Update AGENTS.global.md content section
# Replace detailed content with brief intro + directive

# 4. Update timestamp in AGENTS.global.md
```

### Adding a new rule file

```shell
# 1. Create the file
cat > ~/.agents/rules/my-rule.md << 'EOF'
# My Rule Guidelines

**Last Updated:** $(date +%Y-%m-%d)

---

## When These Rules Apply
[Context when rules should be followed]

## Requirements
[MUST/MUST NOT directives]

## Examples
[Good vs bad examples]
EOF

# 2. Follow same update process as howto files
```

---

## Project-Specific AGENTS Files

**When to read this section:** Setting up AGENTS.local.md or private AGENTS.md for a specific project/repository.

### Overview

While `~/.agents/` files provide global guidance, individual projects need project-specific context:
- Private projects: Use `AGENTS.local.md` or private `AGENTS.md` (gitignored or in `.git/info/exclude`)
- Public projects: Use `AGENTS.local.md` (gitignored) for personal notes, public `AGENTS.md` for team conventions

### What to Include in Project-Specific Files

**Essential content:**
- Project architecture patterns and anti-patterns
- Language-specific conventions for this codebase
- Testing patterns with real examples from the project
- Known issues and workarounds
- Build/deployment quirks

**For repos you own/maintain (dbarnett/*, joshuakto/fit, etc.):**
- **GitHub issue tracking** (see below)
- Current project priorities
- Release planning notes

### Tracking GitHub Issues

**CRITICAL:** Always use `gh issue list` CLI commands for issue tracking, NOT GitHub MCP tools. The CLI output format is designed to be cached and compared for change detection. The specific JSON query format shown below produces consistent, diff-friendly output that can be stashed in files.

**Purpose:** Keep agents aware of open issues, new comments, and priorities without constantly querying GitHub API.

**When to use:**
- Repositories under your direct ownership (dbarnett/*)
- Projects where you're lead maintainer (joshuakto/fit)
- Active projects you regularly work on

**Where to document:**
- Private projects: In `AGENTS.local.md` or private `AGENTS.md`
- Public projects: In `AGENTS.local.md` (gitignored), NOT public AGENTS.md

#### Pattern 1: Inline Issue Tracking

Best for projects with <10 open issues. Include directly in AGENTS.local.md:

```markdown
## GitHub Issues

**Last fetched:** 2025-12-15 23:30 UTC
**Recheck on or after:** 2025-12-22 (weekly)

**Important issues:**
- #42: Add dark mode support - assigned to me, in progress
- #38: Performance regression in v2.1 - needs investigation
- #27: Feature request: export to CSV - backlog

**All open issues (sorted by number):**
<!-- Fetch with: gh issue list --state open --json number,title,labels,updatedAt --limit 100 -->
#15 | Documentation outdated | labels: docs | updated: 2025-12-10
#27 | Feature: export to CSV | labels: enhancement | updated: 2025-12-14
#38 | Performance regression | labels: bug,p1 | updated: 2025-12-15
#42 | Add dark mode | labels: enhancement,in-progress | updated: 2025-12-15

**Directive to agents:**
When starting work on this project, compare the issue list above with latest from GitHub.
If last fetch is older than recheck date, or if you detect differences, update this section.
```

**Update command:**
```shell
# Refresh issue listing
{
  echo "**Last fetched:** $(date -u +"%Y-%m-%d %H:%M UTC")"
  echo "**Recheck on or after:** $(date -u -d '+7 days' +"%Y-%m-%d") (weekly)"
  echo ""
  echo "**All open issues (sorted by number):**"
  gh issue list --state open --json number,title,labels,updatedAt \
    --jq 'sort_by(.number) | .[] | "#\(.number) | \(.title) | labels: \(.labels | map(.name) | join(",")) | updated: \(.updatedAt | split("T")[0])"'
} > /tmp/issues.txt
# Then manually merge into AGENTS.local.md
```

#### Pattern 2: Separate Issue Cache File

Best for projects with >10 open issues. Keeps AGENTS.local.md clean.

**In AGENTS.local.md:**
```markdown
## GitHub Issues

**➡️ Check `.git/info/ISSUE_CACHE.md` for current open issues**

Last updated: 2025-12-15
Directive: Compare cached issues with `gh issue list` before starting work.
If changes detected or cache is >7 days old, regenerate cache.
```

**Create `.git/info/ISSUE_CACHE.md`:**
```markdown
# GitHub Issue Cache for <repo-name>

**Generated:** 2025-12-15 23:30 UTC
**Regenerate on or after:** 2025-12-22

## All Open Issues

#15 | Documentation outdated | labels: docs | updated: 2025-12-10
#27 | Feature: export to CSV | labels: enhancement | updated: 2025-12-14
#38 | Performance regression | labels: bug,p1 | updated: 2025-12-15
#42 | Add dark mode | labels: enhancement,in-progress | updated: 2025-12-15

## Important Issues

- #38: Performance regression - **HIGH PRIORITY**
- #42: Dark mode - in progress, targeting v2.2

## Recently Closed (last 30 days)

#40 | Fix login bug | closed: 2025-12-12
#35 | Update dependencies | closed: 2025-12-08
```

**Add to `.git/info/exclude`:**
```
ISSUE_CACHE.md
```

**Regeneration script:**
```shell
#!/usr/bin/env sh
# Regenerate issue cache in .git/info/ISSUE_CACHE.md

CACHE_FILE=".git/info/ISSUE_CACHE.md"
REPO_NAME=$(basename "$PWD")

cat > "$CACHE_FILE" << EOF
# GitHub Issue Cache for $REPO_NAME

**Generated:** $(date -u +"%Y-%m-%d %H:%M UTC")
**Regenerate on or after:** $(date -u -d '+7 days' +"%Y-%m-%d")

## All Open Issues

EOF

gh issue list --state open --json number,title,labels,updatedAt --limit 100 \
  --jq 'sort_by(.number) | .[] | "#\(.number) | \(.title) | labels: \(.labels | map(.name) | join(",")) | updated: \(.updatedAt | split("T")[0])"' \
  >> "$CACHE_FILE"

cat >> "$CACHE_FILE" << 'EOF'

## Recently Closed (last 30 days)

EOF

gh issue list --state closed --search "closed:>$(date -u -d '30 days ago' +%Y-%m-%d)" \
  --json number,title,closedAt --limit 20 \
  --jq 'sort_by(.number) | reverse | .[] | "#\(.number) | \(.title) | closed: \(.closedAt | split("T")[0])"' \
  >> "$CACHE_FILE"

echo "✅ Issue cache regenerated: $CACHE_FILE"
```

#### Which Pattern to Use?

**Inline (Pattern 1):**
- ✅ Single file to read
- ✅ Self-contained
- ❌ Clutters AGENTS.local.md if many issues
- **Use when:** <10 open issues

**Separate file (Pattern 2):**
- ✅ Keeps AGENTS.local.md clean
- ✅ Easy to regenerate with script
- ✅ Can include more metadata without clutter
- ❌ One more file to manage
- **Use when:** >10 open issues

#### Detecting Changes

**Quick comparison:**
```shell
# Generate fresh listing
gh issue list --state open --json number --jq '.[].number' | sort -n > /tmp/current_issues.txt

# Extract cached listing
grep "^#[0-9]" .git/info/ISSUE_CACHE.md | cut -d'|' -f1 | tr -d '# ' | sort -n > /tmp/cached_issues.txt

# Compare
if ! diff -q /tmp/current_issues.txt /tmp/cached_issues.txt > /dev/null; then
  echo "⚠️  Issues have changed - cache needs update"
  diff /tmp/cached_issues.txt /tmp/current_issues.txt
else
  echo "✅ Issue cache is current"
fi
```

#### Agent Directive

When agents encounter issue cache in AGENTS.local.md or .git/info/ISSUE_CACHE.md:
1. Check if "recheck" date has passed
2. If yes, or if making changes to the project, fetch current issues
3. Compare with cached listing (use issue numbers as fingerprint)
4. If differences found, notify user and optionally update cache
5. Highlight new issues or newly closed issues in output

**Self-sustaining:** Once set up, the directives in AGENTS.local.md guide agents to maintain the cache themselves. Only manual intervention needed if script fails or format changes.

---

## File Templates

### Howto Template

```markdown
# [Topic] Howto

**Last Updated:** YYYY-MM-DD

---

## Overview

Brief description of what this covers and why it exists.

---

## [Main Content Sections]

Detailed instructions, commands, workflows, examples.

---

## Tips and Best Practices

Optional section for advanced usage.

---

## Troubleshooting

Optional section for common issues.
```

### Rule Template

```markdown
# [Topic] Rules and Guidelines

**Last Updated:** YYYY-MM-DD

---

## When These Rules Apply

Clear context about when to follow these rules.

---

## Requirements

**CRITICAL:** [Critical rules that must be followed]

**IMPORTANT:** [Important rules that should be followed]

---

## Patterns

**✅ CORRECT:**
[Good examples]

**❌ WRONG:**
[Bad examples with explanations]

---

## Validation

How to verify compliance with these rules.
```

---

## Maintenance

**Regular review:**
- Update "Last Updated" timestamps when modifying files
- Check cross-references are still valid
- Remove outdated content
- Add new examples as patterns emerge

**When refactoring:**
- Create backup before major changes
- Test that references still work
- Update all cross-references
- Verify agents can find the content

**Version control:**
- Commit AGENTS files to dotfiles repo
- Include descriptive commit messages
- Use emoji prefixes (📚 for docs)
