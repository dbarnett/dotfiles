# Dotfiles Repository - AI Agent Instructions

**Filename:** `AGENTS.md` (you may access this via `CLAUDE.md` symlink)
**Location:** This file is repo-specific (not deployed to `~/`)

**Note:** The `CLAUDE.md` → `AGENTS.md` symlink exists for Claude Code compatibility until Claude Code officially supports `AGENTS.md` ([#6235](https://github.com/anthropics/claude-code/issues/6235)). This is a **local symlink within the repo**, not in `~/`.

---

## ⚠️ CRITICAL - READ FIRST

**You are in the dotfiles repository.** This repo uses **chezmoi** to manage dotfiles.

**ESSENTIAL ADDITIONAL INSTRUCTIONS:**

**IF** `AGENTS.local.md` exists → **THEN** you MUST read it FIRST before ANY action and treat it as an extension of AGENTS.md

**MUST** read and respect `dot_agents/howto-chezmoi.md` as an extension of AGENTS.md (because almost every file in this repo is a chezmoi file)

These files contain binding instructions equivalent to AGENTS.md itself.

---

## 📁 Repository Overview

This is a chezmoi-managed dotfiles repository containing shell configs, editor settings, and tool configurations for Linux/macOS systems.

**Structure:**
- **Source:** `~/.dotfiles/` → symlinked to `~/.local/share/chezmoi/` (treat as identical)
- **Destination:** `~/` (where files are deployed)
- **Remote:** `git@github.com:dbarnett/dotfiles.git`

**Path Resolution Rules:**
In this dotfiles repository, file references use HOME paths (`~/foo`) but you should generally read from repo source paths (`./dot_foo`).

**Chezmoi naming convention:**
- **In repo:** Files/dirs use `dot_*` prefix
  - `.agents/` → `./dot_agents/`
  - `.bashrc` → `./dot_bashrc`
  - `.config/hypr/` → `./dot_config/hypr/`
- **Deployed:** After `chezmoi apply`, files appear in `~/` with actual dotfile names

**What to read - Examples:**
- Documentation says `~/AGENTS.global.md` → **Read `./AGENTS.global.md`**
- Documentation says `~/.agents/foo.md` → **Read `./dot_agents/foo.md`**
- Documentation says `~/.config/hypr/hyprland.conf` → **Read `./dot_config/hypr/hyprland.conf``

**Default rule:** If unsure, prefer repo source (`./dot_*`) over deployed (`~/`).

**Files in this repo that DON'T deploy to home:**
- `AGENTS.md` (this file - repo-specific instructions)
- `CLAUDE.md` (symlink to AGENTS.md)
- `AGENTS.local.md` (session notes and local context, gitignored)

---

## 🔧 Essential Chezmoi Instructions

You MUST read and respect `dot_agents/howto-chezmoi.md` (unconditional)

That howto will tell you how to correctly read/edit/manage files here.

WHY: If you ignore those instructions you'll end up reading and editing completely the wrong copies of files, or crossing wires and documenting completely the wrong scope of information in a file.

---

## 🔒 Universal Security Rule

**IF** you touch/edit/modify ANY file in this repo → **THEN** you MUST determine if it's truly ignored from tracking, and if tracked → MUST contain NO sensitive information

**What counts as sensitive:**
- Email addresses (personal or work)
- Hostnames or machine names
- File paths that identify your system
- Passwords, API keys, tokens
- Personal account information
- Company-specific information
- Usernames or account details

**True Exceptions (safe for sensitive info):**
- Only files in `.gitignore` or `.git/info/exclude` are truly untracked
- `THIS_BRANCH.md` (designed to be removed before push)

**Common Mistakes - AVOID THESE:**
- `.chezmoiignore` files are TRACKED and PUBLIC - they only prevent copying to $HOME
- "Just examples" with real data are still PUBLIC

**EVEN IF:**
- You're just reading or making small edits
- It's just documentation or comments
- You think information isn't sensitive
- You're using ignore files (except .gitignore and .git/info/exclude)
- It's temporary or you'll remove it later
- It's already public elsewhere

---

## 🚀 Commands

See `_dev/README.md` for some useful helpers related to validating and profiling your changes here.

Build/lint/test commands are available in `_dev/` directory:
- `check_templates.sh` - Validate chezmoi templates for safe data access
- `check_sensitive_strings.sh` - Prevent committing sensitive content
- `check_this_system_quick.sh` - System diagnostics

You MUST run relevant checks frequently while making changes to verify them.

---

## 📋 Operational IF->THEN Rules

### Shell Script Triggers

**IF** you open ANY file ending in `.sh` → **THEN** you MUST read `dot_agents/rules/shell-scripts.md` BEFORE editing, EVEN IF:
- It's just a one-line fix
- You're copying from another file
- You think syntax looks obvious
- You've written shell scripts before

**IF** you create ANY shell code block in markdown → **THEN** you MUST read `dot_agents/rules/shell-scripts.md` BEFORE creating, EVEN IF:
- It's just for documentation
- It's a simple echo command
- It won't actually be executed
- You're using POSIX features only

**IF** you use Bash tool with ANY shell command → **THEN** you MUST read `dot_agents/rules/shell-scripts.md` BEFORE running, EVEN IF:
- It's just checking status
- The command looks simple
- You know it works elsewhere

### Version Control Triggers

**IF** you run ANY jj command (status, new, describe, log, etc.) → **THEN** you MUST read `dot_agents/jj-howto.md` BEFORE running, EVEN IF:
- You're just checking current state
- You've used git before
- The command looks simple
- You're not planning to commit yet

**IF** you type "git" or "jj" in ANY context → **THEN** you MUST read `dot_agents/jj-howto.md` BEFORE proceeding, EVEN IF:
- It's just in conversation
- You're mentioning it casually
- You're not actually running commands
- You think you know the workflow

### Testing Triggers

**IF** you create ANY test file → **THEN** you MUST read `dot_agents/rules/testing.md` BEFORE creating, EVEN IF:
- It's just a simple test
- You're copying existing patterns
- You think you know testing principles
- It's just for documentation

**IF** you write ANY test code → **THEN** you MUST read `dot_agents/rules/testing.md` BEFORE writing, EVEN IF:
- It's just one assertion
- You're following existing examples
- You think the test is obvious
- It's just a temporary test

---

## ✅ Critical Reminders

- `AGENTS.local.md` = extension of this file (if it exists)
- `dot_agents/howto-chezmoi.md` = extension of this file (unconditional)
- Security rule applies to ANY file modification in tracked files
- "EVEN IF" clauses eliminate all rationalization attempts
- Public repository = permanent disclosure
- No exceptions for "minor," "quick," or "temporary" actions

---

**End of AGENTS.md** - See essential extension files for complete guidance
