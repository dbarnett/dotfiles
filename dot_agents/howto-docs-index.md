# Documentation Index Pattern (DOCS_INDEX.md)

**Last Updated:** 2025-12-26

---

## Overview

DOCS_INDEX.md is a self-contained documentation index that provides:
- Tree structure showing doc relationships
- Quick reference for finding topics
- Code→Docs mappings
- Automated staleness detection via embedded scan output
- Self-enforcing freshness with expiration dates

**When to use this pattern:**
- Projects with 5+ documentation files
- Documentation spanning multiple directories
- Need to track code-to-docs relationships
- Want to prevent searching for content that's already indexed

---

## File Structure

```markdown
# Documentation Index

**Last Updated:** YYYY-MM-DD
**Regenerate By:** YYYY-MM-DD (Last Updated + 7 days)

**⚠️ CRITICAL: Check this index BEFORE searching docs or code!**

## Documentation Tree
[Tree showing parent→child relationships with arrows]

## Quick Reference
**Topic?** → path § section-name (line XX)

## Code→Docs Mappings
### Component Name
**Code:** file:line, function names
**Docs:** related sections with line numbers
**Last Updated:** timestamp

## Raw Heading Scan Output
**Generated:** YYYY-MM-DD HH:MM
**Command:** grep -Hn '^#\+ ' ...
[Full scan output with line numbers]
```

---

## Generation Command

```shell
# Generate DOCS_INDEX.md with scan output
TODAY=$(date '+%Y-%m-%d')
REGEN_BY=$(date -d '+7 days' '+%Y-%m-%d' 2>/dev/null || date -v '+7d' '+%Y-%m-%d')
GENERATED=$(date '+%Y-%m-%d %H:%M')

cat > .agents/DOCS_INDEX.md <<EOF
# Documentation Index

**Last Updated:** $TODAY
**Regenerate By:** $REGEN_BY

**⚠️ CRITICAL: Check this index BEFORE searching docs or code!**

## Documentation Tree
[TODO: Add tree structure showing doc relationships]

## Quick Reference
[TODO: Add topic → file § section mappings]

## Code→Docs Mappings
[TODO: Add component → docs mappings]

## Raw Heading Scan Output

**Generated:** $GENERATED
\`\`\`
$(grep -Hn '^#\+ ' README.md 2>/dev/null || true)
$(find docs -name "*.md" -exec grep -Hn '^#\+ ' {} + 2>/dev/null || true)
\`\`\`
EOF
```

After generating, fill in the TODO sections at top with manual curation.

---

## AGENTS.md Integration

```markdown
## 📚 Documentation Index

**IMPORTANT: You MUST read [.agents/DOCS_INDEX.md](.agents/DOCS_INDEX.md) BEFORE searching docs or code.**

**If you search without checking the index, you WILL miss related content and waste time.**

**When to use:**
- Before any doc search - check if already indexed
- Looking for specific topics - use Quick Reference
- Finding code locations - check Code→Docs Mappings
- After modifying docs - regenerate to keep line numbers current

**Regenerate weekly** (check "Regenerate By" date) or after doc changes.
```

---

## Benefits Over Other Approaches

**vs. Manual README links:**
- Automated - always reflects current state
- Line numbers enable diff-based staleness detection
- Embedded scan output = self-contained validation

**vs. Grep every time:**
- Faster - one index read vs multiple searches
- Shows relationships - tree structure reveals doc organization
- Prevents missing content - Quick Reference covers all topics

**vs. Static CODE_MAPPINGS.md:**
- Self-validating - scan output enables automated freshness checks
- Force freshness - weekly expiration prevents stale indexes
- Comprehensive - tree + quick ref + mappings in one place

---

## Maintenance Workflow

**For Agents:**

1. **Session start:** Check "Last Updated" and "Regenerate By" dates
2. **If stale (>7 days):** Regenerate before searching
3. **Before doc search:** Read Quick Reference and Tree sections
4. **After modifying docs:** Rerun scan, update Tree/Quick Reference, update timestamps

**For Users:**

- Run regeneration command weekly or when docs change significantly
- Review and update Tree, Quick Reference, and Code→Docs sections manually
- Commit updated DOCS_INDEX.md with doc changes

---

## Project-Specific Variations

**Include code files in scan:**
```shell
# For JSDoc or similar
find src -name "*.js" -exec grep -Hn '^/\*\* ' {} +
```

**Multiple doc directories:**
```shell
find docs guides api -name "*.md" -exec grep -Hn '^#\+ ' {} +
```

**Event-driven regeneration:**
Add to pre-commit hook to regenerate when docs change.

---

## Expected Benefits

✅ **Tree structure** - Agents understand doc relationships at a glance
✅ **Quick reference** - Instant topic lookup without grep
✅ **Code→Docs mappings** - Find relevant docs when modifying code
✅ **Scan output** - Enables automated staleness detection (compare line numbers)
✅ **Expiration date** - Forces weekly freshness checks

Token efficiency: Single index read vs. repeated searches across multiple files.

---

**End of howto-docs-index.md**
