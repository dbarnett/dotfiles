# ~/.agents Directory

**Purpose**: Specialized howto guides and rules for AI coding assistants across all projects.

**Last Updated:** 2025-12-19

---

## What's Here

This directory contains detailed guides that supplement `~/AGENTS.global.md` with specialized instructions:

### Howto Guides

- **`jj-howto.md`** - Jujutsu (jj) version control commands, workflows, and concepts
- **`chezmoi-howto.md`** - Dotfiles management with chezmoi
- **`agents-files-howto.md`** - Guidelines for creating/modifying AGENTS.md files and organizing this directory
- **`configuring-mcp-tools.md`** - MCP server setup and usage patterns

### Rules (Detailed Guidelines)

Located in `rules/` subdirectory:

- **`shell-scripts.md`** - Shell scripting best practices (POSIX compliance, avoid bashisms)
- **`testing.md`** - Testing principles and patterns
- **`branch-metadata.md`** - THIS_BRANCH.md and check_this_branch.sh conventions
- **`obsidian.md`** - Working with Obsidian vault (`~/.myvault`)

---

## How to Use

### For AI Agents

When `~/AGENTS.global.md` or a project's `AGENTS.local.md` says **"you MUST read [filename]"**, read that file for detailed context relevant to your current task.

**Read selectively based on task:**

- Working with version control in a `.jj/` repo → Read `jj-howto.md`
- Writing shell scripts → Read `rules/shell-scripts.md`
- Writing tests → Read `rules/testing.md`
- Starting branch work → Read `rules/branch-metadata.md`
- Setting up AGENTS.md files → Read `agents-files-howto.md`

### For Humans

These files serve as reference documentation for conventions shared across projects. They're structured to be AI-readable but useful for humans too.

**Organization philosophy:**

- Keep `~/AGENTS.global.md` scannable by extracting detailed content here
- Each file focuses on a specific domain
- Files are self-contained (can be read independently)

---

## File Hierarchy

```
~/AGENTS.global.md           # Main directives, points to specific howtos
  ↓
~/.agents/
  ├── README.md              # This file
  ├── jj-howto.md            # VCS commands and workflows
  ├── agents-files-howto.md  # Meta-documentation
  ├── rules/
  │   ├── shell-scripts.md
  │   ├── testing.md
  │   └── ...
  └── ...

Project/AGENTS.md            # Project-specific base instructions
  ↓
Project/AGENTS.local.md      # Machine-specific overrides (gitignored)
  ↓
  Copies key conventions from ~/AGENTS.global.md
  References ~/.agents/ files when needed
```

**Design principle:** Project-level `AGENTS.local.md` files copy especially relevant content from the global file to flatten the lookup structure (2 levels instead of 3-4).

---

## Maintenance

### Adding New Files

When creating new howto/rule files:

1. Read `agents-files-howto.md` for guidelines
2. Keep focused on a single domain
3. Update this README's file list
4. Reference from `~/AGENTS.global.md` with "you MUST read" directive
5. Update `~/AGENTS.global.md` timestamp

### Updating Existing Files

- Update file's "Last Updated" timestamp
- Update `~/AGENTS.global.md` timestamp if you change how files are referenced
- Consider updating project `AGENTS.local.md` files if you change core conventions

---

**End of README** - See individual files for detailed content.
