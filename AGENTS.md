# Dotfiles Repository - AI Agent Instructions

**Filename:** `AGENTS.md` (you may access this via `CLAUDE.md` symlink)
**Location:** This file is repo-specific (not deployed to `~/`)

**Note:** The `CLAUDE.md` → `AGENTS.md` symlink exists for Claude Code compatibility until Claude Code officially supports `AGENTS.md` ([#6235](https://github.com/anthropics/claude-code/issues/6235)). This is a **local symlink within the repo**, not in `~/`.

**Maintenance:** Run `agents-tool` regularly (checks file mtimes automatically)

---

## ⚠️ CRITICAL - READ FIRST

**You are in the dotfiles repository.** This repo uses **chezmoi** to manage dotfiles.

### 🚨 MANDATORY PREREQUISITE

**YOU MUST READ `~/AGENTS.global.md` BEFORE PROCEEDING WITH ANY WORK.**

That file contains essential global conventions including:
- jj (Jujutsu) version control workflow
- Shell script preferences (avoid bashisms, fish shell compatibility)
- File editing rules (indentation, whitespace, sed prohibition)
- General coding patterns that apply to ALL work in this repository

**If you skip reading `~/AGENTS.global.md`, you WILL make mistakes.**

**Additional required reading:**
1. **This file** - Repository structure and chezmoi workflow
2. **`.agents/howto-chezmoi.md`** - Detailed chezmoi patterns and gotchas (read when working with chezmoi)
3. **`THIS_BRANCH.md`** - Current branch status and TODOs (read if exists)

---

## 📁 Repository Overview

This is a chezmoi-managed dotfiles repository containing shell configs, editor settings, and tool configurations for Linux/macOS systems.

**Structure:**
- **Source:** `~/.dotfiles/` → symlinked to `~/.local/share/chezmoi/` (treat as identical)
- **Destination:** `~/` (where files are deployed)
- **Remote:** `git@github.com:dbarnett/dotfiles.git`

**Path Resolution & Reading Files:**

**CRITICAL - Read this carefully:**

In this dotfiles repository, file references use HOME paths (`~/foo`) but you should generally read from repo source paths (`./dot_foo`).

**Chezmoi naming convention:**
- **In repo:** Files/dirs use `dot_*` prefix
  - `.agents/` → `./dot_agents/`
  - `.bashrc` → `./dot_bashrc`
  - `.config/hypr/` → `./dot_config/hypr/`
- **Deployed:** After `chezmoi apply`, files appear in `~/` with actual dotfile names
  - `~/.agents/`, `~/.bashrc`, `~/.config/hypr/`

**What to read - Examples:**
- Documentation says `~/AGENTS.global.md` → **Read `./AGENTS.global.md`** (repo source may have uncommitted changes)
- Documentation says `~/.agents/foo.md` → **Read `./dot_agents/foo.md`** (fresh source, not stale deployed)
- Documentation says `~/.config/hypr/hyprland.conf` → **Read `./dot_config/hypr/hyprland.conf`** (current working state)
- Documentation says `~/.bashrc` → **Read `./dot_bashrc`** (latest edits before deployment)

**When to read from `~/` (deployed) instead:**
- Explicitly checking deployed state: "verify ~/.bashrc was deployed correctly"
- File ONLY exists in home, not tracked: `~/.bash_history`, `~/.cache/`
- Instructions specifically say "deployed version" (rare)

**Default rule:** If unsure, prefer repo source (`./dot_*`) over deployed (`~/`).

**Files in this repo that DON'T deploy to home:**
- `AGENTS.md` (this file - repo-specific instructions)
- `CLAUDE.md` (symlink to AGENTS.md for Claude Code compatibility)
- `AGENTS.local.md` (session notes and local context, gitignored)
- `THIS_BRANCH.md` (branch metadata, if exists)
- `check_this_branch.sh` (branch validation script, if exists)

**Files that DO deploy to home:**
- `AGENTS.global.md` → `~/AGENTS.global.md` (global agent guidelines)
- `dot_agents/*` → `~/.agents/*` (specialized guides)
- All other tracked dotfiles

---

## 🔧 Quick Chezmoi Reference

See `.agents/howto-chezmoi.md` for detailed patterns and gotchas.

**Common operations:**
```shell
chezmoi add ~/.bashrc       # Track a new file
chezmoi edit ~/.bashrc      # Edit in source, auto-apply
chezmoi diff                # Preview what would change
chezmoi apply               # Deploy changes to home
chezmoi cd                  # Jump to source directory
```

**With encryption:**
```shell
chezmoi add --encrypt ~/.gmailctl/config.personal.jsonnet
```

**Template syntax (safe patterns):**
```
{{ if eq (or (index . "machine_profile") "personal") "work" }}
work-specific content
{{ end }}
```

**⚠️ Important:** Always use safe patterns to avoid hard dependencies:
- ✅ **Safe:** `{{ or (index . "key") "default" }}` - returns default if key missing
- ✅ **Safe:** `{{ if hasKey . "key" }}{{ .key }}{{ end }}` - explicit check
- ❌ **Unsafe:** `{{ .key | default "value" }}` - accesses key first, errors if missing
- ❌ **Unsafe:** `{{ .key }}` - direct access, errors if missing

See `_dev/check_templates.sh` for validation.

---

## ⚙️ Machine Configuration

Configure machine-specific settings in `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
    machine_profile = "work"  # or "personal"
    vcs_author_email = "work@example.com"  # Optional override

[encryption]
    type = "age"
    [encryption.age]
        identity = "~/.config/chezmoi/key.txt"
        recipient = "age1rfypa36vaxk04x7rr6capfayu0575t3jplwrdy22m8yn7h0gpe5q6sauay"
```

**Age encryption:**
- Private key: `~/.config/chezmoi/key.txt` (NEVER commit, copy securely to new machines)
- Public key: In `chezmoi.toml` above (safe to commit)
- Encrypted files stored as `encrypted_*.age` in source

---

## 📋 Current State (Migration Complete)

**All 92 yadm-tracked files have been migrated to chezmoi.**

Chezmoi now manages all dotfiles that yadm previously tracked, including:
- Shell configs (`.bashrc`, `.bash_aliases`, `.profile`, etc.)
- Git configs (`.gitconfig`, `.gitignore`, `.gitconfig.d/*`)
- Editors (`.vimrc`, `.vim/`, `.config/helix/`, `.config/fish/`, `.config/nvim`)
- Tools (`.npmrc`, `.config/gh/`, `.config/hypr/`, etc.)
- Encrypted files (gmailctl configs via age encryption)

**Excluded from tracking (`.chezmoiignore`):**
- Caches: `.cache/`, `.cargo/`, `.rustup/`, `.npm/`, etc.
- App data: `.local/share/` (except specific files), `.mozilla/`, `.steam/`
- IDEs: `.config/JetBrains/`, `.config/Code - OSS/`
- History files: `.bash_history`, `.viminfo`, etc.

---

## 🔍 Common Tasks

### Adding a New Dotfile

```shell
chezmoi add ~/.config/newapp/config.yaml
```

### Editing an Existing File

```shell
# Option 1: Edit in source with auto-apply
chezmoi edit ~/.bashrc

# Option 2: Edit in home, then add changes
vim ~/.bashrc
chezmoi add ~/.bashrc
```

### Templating for Different Machines

**In source:** `dot_bashrc.tmpl`
```shell
{{ if eq (or (index . "machine_profile") "personal") "work" }}
export WORK_SPECIFIC=value
{{ else }}
export PERSONAL_SPECIFIC=value
{{ end }}
```

**Note:** Always use safe template patterns (see Template syntax section above). The pre-commit hook validates templates automatically.
```

### Adding Encrypted Files

```shell
chezmoi add --encrypt ~/.gmailctl/config.personal.jsonnet
```

**Important:** Encrypted files are stored as `encrypted_*` in source and auto-decrypted on `chezmoi apply`.

---

## 🐚 Version Control Workflow

This repo uses **Jujutsu (jj)** for version control. See `~/AGENTS.global.md` for jj workflow details.

**Quick reference:**
```shell
jj status              # Check current change
jj show --stat         # See what changed
jj new -m "Description" # Start new change
jj describe            # Update change description
jj git push            # Push bookmark to GitHub
```

---

## 🏠 Dotfiles Repository Conventions

### Change Description Convention (WIP: prefix)

**WIP: prefix usage:**
- **Single change:** Prefix with `WIP:` and include detailed task notes
- **Multi-change series:** Prefix ALL changes in the series with `WIP:`
  - Example: `main -> WIP: refactor X -> WIP: add Y -> WIP: fix Z (@)`
  - Walking backwards through WIP: changes from @ = the "current work series"
  - Each change has its own detailed description with scope, TODOs, progress
- **Ready to push:**
  - Remove `WIP:` prefix from all changes in the series
  - Condense each description to 10-15 lines max
  - Keep only: what changed, why, important notes
  - Remove TODOs (already done or tracked in AGENTS.local.md)
  - Usually squash series into one or a few logical commits

### Bookmark Conventions

**Stacked series (multiple topics in development):**
- Use multiple bookmarks to make topics explicit
- Example: `main -> WIP: aaa -> WIP: bbb (_somechange) -> WIP: zzz (_anotherchange)`
- Each bookmark marks a separate logical topic
- Prevents ambiguity about what's grouped together

**Dotfiles-specific bookmarks:**
- **`_local`**: Miscellaneous uncurated local changes on top of main
  - Use for changes that still need to be consolidated and made pushable
  - Like a "staging area" for uncommitted ideas
  - Eventually split out into proper topic bookmarks or push directly
- **`_<topic>`**: Specific WIP topics (e.g., `_fix_hyprland`, `_agents_refactor`)
  - Prefix with `_` to indicate work-in-progress
  - Use lowercase with underscores

### agents-tool Usage

**In dotfiles context:**
- `agents-tool` - Check/refresh AGENTS files, get dotfiles-specific guidance
- `agents-tool --task` - Shows dotfiles workflow guidance (no THIS_BRANCH.md needed)

**Why no THIS_BRANCH.md in dotfiles:**
- Dotfiles changes should be small, focused, single-purpose
- Use `jj describe` to document WIP change scope (keep detailed while working)
- Condense descriptions to 10-15 lines max before pushing
- For multi-step work, track TODOs in AGENTS.local.md "Current Roadmap" section

### Chezmoi Path Preferences

**When reading files in this repository:**
- **Prefer `./AGENTS.global.md`** over `~/AGENTS.global.md` (repo source is fresher)
- **Prefer `./dot_agents/`** over `~/.agents/` (read from source, not deployed)
- **Exception:** When checking deployed state, read `~/` paths explicitly

**Why:** Source files in repo may have uncommitted changes. Reading repo source ensures you see current state.

---

## 🔒 Security Notes

**Public repository:** This is a PUBLIC repository on GitHub.

**Safe to commit:**
- Encrypted files (`encrypted_*.age`)
- Public configuration
- Template files
- Age public key

**NEVER commit:**
- Age private key (`~/.config/chezmoi/key.txt`)
- Unencrypted secrets
- Machine-specific passwords
- API keys or tokens
- Personal email addresses or private info

**Use `.chezmoiignore`** to exclude sensitive files from tracking.

---

## 🛠️ Claude Code Configuration

**IMPORTANT**: Any `.claude/settings.json` in this repo becomes `~/.claude/settings.json` when deployed.

- **Use `.claude/settings.local.json`** - Already gitignored (machine-specific)
- **Do NOT track `.claude/settings.json`** - Would propagate to global Claude config

**Required setup for working in this repo:**

Create `.dotfiles/.claude/settings.local.json` (or in chezmoi source):
```json
{
  "permissions": {
    "additionalDirectories": [
      "~/.config"
    ],
    "allow": [
      "Read(~/.config/**)",
      "Edit(~/.config/**)",
      "Bash(ls:~/.config/**)",
      "Bash(grep:~/.config/**)",
      "Bash(find:~/.config/**)"
    ]
  }
}
```

This allows Claude Code to:
- Access `~/.config` files (Hyprland, waybar, etc.)
- Read and edit configuration files
- Run diagnostic commands on configs

---

## 📌 Known Issues & Tasks

**Source of Truth:** [GitHub Issues](https://github.com/dbarnett/dotfiles/issues)

⚠️ **SECURITY NOTE**: This is a **public repository**. When creating or updating GitHub issues:
- ❌ NO sensitive information (passwords, API keys, private paths, account details)
- ❌ NO personal system information that could be a security risk
- ✅ Configuration structure, public tool names, general troubleshooting steps
- ✅ Use `AGENTS.local.md` (gitignored) for any sensitive local context

**Issue label conventions:**
- `ai-agent` - Issues intended for AI coding assistants to read and act on
- `enhancement` - Feature requests and improvements

**Checking issues:**
```shell
gh issue list --repo dbarnett/dotfiles            # All open issues
gh issue list --repo dbarnett/dotfiles -l ai-agent  # AI-relevant issues only
```

**Local session context:** Maintain `AGENTS.local.md` (gitignored) with:
- Recent issue fetch metadata ("last checked YYYY-MM-DD")
- Quick notes on which issues are currently relevant and why
- Temporary TODOs and session-specific context
- Local configuration state that changes frequently
- **Any sensitive information that shouldn't be in public issues**

---

## 🪟 Hyprland/HyDE Desktop Configuration

**📄 IMPORTANT: See `~/.config/desktop.md` for detailed HyDE setup documentation**

That file contains:
- Complete HyDE configuration system explanation
- Waybar customization workflow (module overrides, auto-generation)
- Active issues (icon rendering, module overrides)
- Portability notes for migrating to other Hyprland setups
- Known issues and fixes (dunst/swaync conflict, etc.)
- Custom scripts and modules created
- Wallbash color system
- Complete command reference

**Current Setup:**
- **Compositor:** Hyprland 0.52.1
- **Desktop Environment:** HyDE (Hyprland Desktop Environment)
- **Plugin Manager:** hyprpm
- **Active Plugins:** hy3 (i3-like tiling)

**Quick diagnostic commands:**
```shell
hyprctl plugin list    # Check plugin status
hyprpm list            # List available plugins
journalctl --user -u hyprland -n 50 | grep -i error  # Check for errors
```

---

## 📚 References

- **Chezmoi docs:** https://www.chezmoi.io/
- **Chezmoi patterns:** `.agents/howto-chezmoi.md`
- **Global conventions:** `~/AGENTS.global.md`
- **Branch workflow:** `~/.agents/rules/branch-metadata.md`
- **Shell script guidelines:** `~/.agents/rules/shell-scripts.md`
- **Testing guidelines:** `~/.agents/rules/testing.md`

---

## ✅ Session Checklist

**When starting work:**
- [ ] **MUST read `~/AGENTS.global.md`** - Essential global conventions (jj, shell, coding patterns)
- [ ] Read this file (AGENTS.md)
- [ ] Read `.agents/howto-chezmoi.md` when working with chezmoi
- [ ] Check `THIS_BRANCH.md` if working on a branch
- [ ] Check GitHub issues: `gh issue list --repo dbarnett/dotfiles`
- [ ] Run `jj status` to see current state
- [ ] Review `chezmoi diff` before applying changes

**When ending session:**
- [ ] Run `./check_this_branch.sh` if it exists
- [ ] Commit changes with descriptive message
- [ ] Update `THIS_BRANCH.md` if working on a branch
- [ ] Update `AGENTS.local.md` with session notes
- [ ] Consider if changes need testing on other machines

---

**End of AGENTS.md** - See `~/AGENTS.global.md` for global conventions
