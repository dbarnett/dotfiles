# AGENTS.global.md - General Directives for AI Coding Assistants

**Last Updated:** 2025-12-15 (jj-howto refactoring)
**Location:** `~/AGENTS.global.md`

**Note:** If you have an old `~/AGENTS.md` file from a previous version of this dotfiles setup, you should delete it. This file (`~/AGENTS.global.md`) has replaced it.

---

This file contains general preferences and conventions for AI coding assistants (Claude Code, Cursor, Gemini CLI, etc.) across all projects.

## 📑 Quick Navigation

**Essential sections to read:**
- **📋 How to Use This File** - Setting up project-level AGENTS.md files
- **🐚 Version Control: Jujutsu (jj)** - Introduction (detailed howto in separate file)
- **🎯 General Coding Preferences** - Core principles

**Specialized guides (you MUST read when relevant):**
- **`~/.agents/jj-howto.md`** - READ when working with version control in repos with `.jj/`
- **`~/.agents/rules/shell-scripts.md`** - READ when writing/debugging shell scripts
- **`~/.agents/rules/testing.md`** - READ when writing/reviewing tests
- **`~/.agents/rules/branch-metadata.md`** - READ when starting branch work or using THIS_BRANCH.md/check_this_branch.sh
- **`~/.agents/rules/obsidian.md`** - READ when working with Obsidian vault (`~/.myvault`)

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

**IMPORTANT:** Design this from scratch - do NOT copy from `~/AGENTS.global.md` which contains personal preferences. `~/AGENTS.global.md` will generally be referenced indirectly via `AGENTS.local.md` in this case.

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

**➡️ When working with jj or working with version control in a repository that has `.jj/`, you MUST read `~/.agents/jj-howto.md` for commands, workflows, and key concepts.**

**Quick overview:**
- Jujutsu provides a friendlier interface to Git with automatic snapshotting
- Changes are tracked continuously without explicit staging
- You work with "changes" (stable IDs) rather than commits
- Use `jj status`, `jj show --stat`, and `jj log` to understand current state

---

## 🎯 General Coding Preferences

### Shell Scripts

**CRITICAL: User runs fish shell - avoid bashisms**

**➡️ When writing/debugging shell scripts, you MUST read `~/.agents/rules/shell-scripts.md` for detailed guidelines.**

- **Always use ````shell` markdown fence**, not ````bash`, unless specifically requiring bash
- Start scripts with `#!/usr/bin/env sh` for portability

**Quick reference - avoid these bashisms:**
- ❌ Heredocs (`cat <<EOF`)
- ❌ Process substitution (`<(command)`)
- ❌ Bash arrays
- ❌ `[[` conditionals - use `[` instead

### Output Formatting in Shell Scripts

**CRITICAL: Avoid "log-log-log" patterns for multiline output**

❌ **WRONG - Breaks vertical alignment:**
```shell
echo "=== Summary ==="
echo "  Status:    ✅ Passed"
echo "  Files:     42"
echo "  Time:      1.234s"
```

✅ **CORRECT - Use single output for block-formatted content:**
```shell
# Pattern 1: printf with format string
printf "=== Summary ===
  Status:    ✅ Passed
  Files:     %d
  Time:      %.3fs
" "$file_count" "$elapsed"

# Pattern 2: Build string then output once
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

### File Editing
- Clean up trailing whitespace (except `.md` files)
- Ensure newline at end of file
- Preserve existing indentation style (tabs vs spaces)
- **Check indentation ONLY with `cat -A`** (NOT sed): tabs show as `^I`, spaces as themselves
- **NEVER use sed for editing** - only Edit tool (user can't verify sed changes)

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
  - Add to TODO list in THIS_BRANCH.md if in scope

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
- **Maintain index of code-to-docs mappings** (which docs correspond to which code)

### Testing

**➡️ When writing/reviewing tests, you MUST read `~/.agents/rules/testing.md` for detailed guidelines.**

**Core Principles (quick reference):**
- **One test = one thing** - Each test should verify a single behavior
- **Use parameterized tests** for variations of the same test logic
- **Test real behavior, not mocks** - Only mock external dependencies (APIs, databases, file systems, time)
- **Functional tests spanning multiple components** → separate test file/directory

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

1. **When working with version control in repos with `.jj/`, read `~/.agents/jj-howto.md`** for commands and workflows
2. **Always use `jj` commands**, not `git` directly (except `jj git push/fetch`)
3. **Use ````shell` not ````bash`** in markdown unless bash-specific features required
4. **Avoid bashisms** (heredocs, process substitution, etc.) - user runs fish shell
5. **When starting branch work, read `~/.agents/rules/branch-metadata.md`** for THIS_BRANCH.md guidance
6. **FIXME = blocking, TODO = deferrable** - check_this_branch.sh enforces this
7. **When writing tests, read `~/.agents/rules/testing.md`** for detailed guidelines
8. **When writing shell scripts, read `~/.agents/rules/shell-scripts.md`** for detailed guidelines
9. **Update this file's timestamp** when making changes
10. **Verify project `AGENTS.md` is current** if manually copied (not symlinked)

---

**End of AGENTS.global.md** - See project-specific `AGENTS.local.md` for overrides and `~/.agents/rules/` for specialized guidelines
