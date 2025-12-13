# Dotfiles Repository - AI Agent Instructions

**Location:** This file is repo-specific (not deployed to `~/`)
**Last Updated:** 2025-12-14

For global AI agent conventions across all projects, see `~/AGENTS.md` (deployed from `literal_AGENTS.md` in this repo).

---

## ⚠️ IMPORTANT: Read This First

**You are in the dotfiles repository.** This repo uses **chezmoi** to manage dotfiles.

**Required reading:**
1. **This file** - Repository structure and chezmoi workflow
2. **`~/AGENTS.md`** - Global agent conventions (jj workflow, shell preferences, etc.)
3. **`.agents/howto-chezmoi.md`** - Detailed chezmoi patterns and gotchas
4. **`THIS_BRANCH.md`** - Current branch status and TODOs (if exists)

---

## 📁 Repository Overview

This is a chezmoi-managed dotfiles repository containing shell configs, editor settings, and tool configurations for Linux/macOS systems.

**Structure:**
- **Source:** `~/.dotfiles/` (this directory - staging workspace during migration)
- **Future source:** `~/.local/share/chezmoi/` (will be main chezmoi source after migration)
- **Destination:** `~/` (where files are deployed)
- **Remote:** `git@github.com:dbarnett/dotfiles.git`

**Files in this repo that DON'T deploy to home:**
- `AGENTS.md` (this file - repo-specific instructions)
- `THIS_BRANCH.md` (branch metadata)
- `check_this_branch.sh` (branch validation script)

**Files that DO deploy to home:**
- `literal_AGENTS.md` → `~/AGENTS.md` (global agent guidelines)
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

**Template syntax:**
```
{{ if eq .machine_type "work" }}
work-specific content
{{ end }}
```

---

## ⚙️ Machine Configuration

Configure machine-specific settings in `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
    machine_type = "work"  # or "personal"
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
{{ if eq .machine_type "work" }}
export WORK_SPECIFIC=value
{{ else }}
export PERSONAL_SPECIFIC=value
{{ end }}
```

### Adding Encrypted Files

```shell
chezmoi add --encrypt ~/.gmailctl/config.personal.jsonnet
```

**Important:** Encrypted files are stored as `encrypted_*` in source and auto-decrypted on `chezmoi apply`.

---

## 🐚 Version Control Workflow

This repo uses **Jujutsu (jj)** for version control. See `~/AGENTS.md` for jj workflow details.

**Quick reference:**
```shell
jj status              # Check current change
jj show --stat         # See what changed
jj new -m "Description" # Start new change
jj describe            # Update change description
jj git push            # Push bookmark to GitHub
```

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

**Note:** `CLAUDE.md` is a symlink to `AGENTS.md` until Claude Code officially supports `AGENTS.md` ([#6235](https://github.com/anthropics/claude-code/issues/6235)).

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
- **Global conventions:** `~/AGENTS.md`
- **Branch workflow:** `~/.agents/rules/branch-metadata.md`
- **Shell script guidelines:** `~/.agents/rules/shell-scripts.md`
- **Testing guidelines:** `~/.agents/rules/testing.md`

---

## ✅ Session Checklist

**When starting work:**
- [ ] Read this file (AGENTS.md)
- [ ] Read `~/AGENTS.md` for global conventions
- [ ] Read `.agents/howto-chezmoi.md` for chezmoi details
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

**End of AGENTS.md** - See `~/AGENTS.md` for global conventions
