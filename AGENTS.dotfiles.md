# 🏠 Dotfiles Repository - Agent Instructions

**Last Updated:** 2025-12-07 (Claude Code config section added)
**Location:** `~/.dotfiles/AGENTS.dotfiles.md`

This file contains dotfiles-specific instructions for AI coding assistants working in this repository.

---

## 📋 Repository Context

This is a **yadm-managed dotfiles repository** with a git worktree setup:

- **`~/`** - Live configs based on `main` branch (managed by yadm)
- **`~/.dotfiles/`** - Staging workspace on `staging` branch (this directory)

### Important: AGENTS.md Handling

Because files here mirror to `$HOME/`, we handle agent instructions specially:

- `~/AGENTS.md` - Global user instructions (tracked in this repo, synced to home)
- `~/.dotfiles/AGENTS.dotfiles.md` - **This file** - dotfiles-specific instructions
- `~/.dotfiles/AGENTS.md` - Copy of global instructions (same as `~/AGENTS.md`)

**Read BOTH files:**
1. Read `AGENTS.md` first for general conventions
2. Read this file (`AGENTS.dotfiles.md`) for dotfiles-specific guidance

### Claude Code Configuration

**IMPORTANT**: Because this is a yadm-managed dotfiles repo, any `.claude/settings.json` in this directory would also become `~/.claude/settings.json` (same file). Therefore:

- **Use `.claude/settings.local.json`** - Already gitignored (see `.gitignore:10`)
- **Do NOT track `.claude/settings.json`** - Would propagate to global Claude config

**Why `.gitignore` instead of `.git/info/exclude`:**

Due to [jj-vcs/jj#8140](https://github.com/jj-vcs/jj/issues/8140), jj fails to respect `.git/info/exclude` in worktrees (though it works fine in regular repos). This means:
- ❌ Can't use `.git/info/exclude` to ignore files only in this worktree
- ✅ Must use `.gitignore` to ignore `.claude/settings.local.json` globally

This is acceptable because:
- `.claude/settings.local.json` should be gitignored in ALL repos anyway (it's machine-specific)
- If we couldn't gitignore it globally, we'd have no workaround for this specific yadm+worktree setup

**Required setup for new worktrees:**

Create `.dotfiles/.claude/settings.local.json`:
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

NOTE: Similarly, CLAUDE.md is tracked as a symlink to AGENTS.md for now because they *STILL* haven't added support for AGENTS.md (https://github.com/anthropics/claude-code/issues/6235) and bootstrapping CC's link to that is a must.

**Verify setup:**
```shell
# Should exist and be gitignored
ls -la .claude/settings.local.json

# Should NOT be tracked
git status  # should not show .claude/settings.local.json
```

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
- Other labels as needed for organization

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

### Current Setup
- **Compositor:** Hyprland 0.52.1
- **Desktop Environment:** HyDE (Hyprland Desktop Environment)
- **Plugin Manager:** hyprpm
- **Active Plugins:** hy3 (i3-like tiling)

### Configuration Locations

**Main Hyprland configs** (edit in `~/.config/hypr/`):
- `hyprland.conf` - Main config, sources other files
- `userprefs.conf` - User-specific settings (layout, general options)
- `keybindings.conf` - All keybindings
- `windowrules.conf` - Window rules
- `monitors.conf` - Monitor configuration
- `workflows.conf` - Workflow-specific settings
- `animations.conf` - Animation settings
- `shaders.conf` - Shader effects

**HyDE system configs** (usually don't edit directly):
- `~/.local/share/hyde/hyprland.conf` - HyDE fallback config

### hy3 Plugin Configuration

**Installation:**
```shell
hyprpm add https://github.com/outfoxxed/hy3
hyprpm enable hy3
hyprctl reload
```

**Current keybindings** (in `~/.config/hypr/keybindings.conf:78-82`):
- `Super+D` - Create tab group
- `Super+Alt+D` - Toggle group tab/split mode
- `Super+Alt+R` - Toggle group horizontal/vertical

**Dispatchers replaced with hy3 versions:**
- `movefocus` → `hy3:movefocus` (lines 46-49)
- `movewindow` → `hy3:movewindow` (lines 62-65)

**Reference:**
- [hy3 GitHub](https://github.com/outfoxxed/hy3)
- [Author's config](https://git.outfoxxed.me/outfoxxed/nixnew/src/branch/master/modules/hyprland/hyprland.conf)

### 🔔 Notification Center

**Target setup**: swaync v0.12.3
- Config: `~/.config/swaync/`
- Startup: `exec-once = swaync` in `hyprland.conf`
- Test: `notify-send "Test" "Message"`
- Toggle: `swaync-client -t -sw`

**Waybar:**
- Config: `~/.config/waybar/`
- Reload: `killall waybar && waybar &`
- Debug: `waybar -l debug`

---

## 🔍 Diagnostic Commands

### Check Hyprland Status
```shell
# Plugin status
hyprctl plugin list
hyprpm list

# Current config errors
journalctl --user -u hyprland -n 50 | grep -i error

# Reload config
hyprctl reload

# Get version info
hyprctl version
```

### Check Workspace & Window Layout
```shell
# List windows on workspace 3
hyprctl clients -j | jq '.[] | select(.workspace.id == 3) | {class, title, size, at}'

# Current workspace info
hyprctl activeworkspace -j
```

### Check yadm Status
```shell
# Working in ~/.dotfiles/
cd ~/.dotfiles/
git status
git diff --stat

# See what's staged for home directory
yadm status
yadm diff --stat
```

---

## 📝 Workflow: Making Config Changes

### Safe Editing Process

1. **Work in staging workspace:**
   ```shell
   cd ~/.dotfiles/
   # Make changes to config files
   ```

2. **Test changes:**
   - For Hyprland: `hyprctl reload`
   - For waybar: `killall waybar && waybar &`
   - For system-wide: May need to re-login

3. **Commit to staging branch:**
   ```shell
   git add .config/hypr/userprefs.conf .config/hypr/keybindings.conf
   git commit -m "🔧 Configure hy3 plugin with minimal keybindings"
   ```

4. **Merge to main when ready:**
   ```shell
   git checkout main
   git merge staging
   ```

### Common Gotchas

- ❌ Don't edit files in `~/` directly - changes won't be in version control
- ❌ Don't commit `AGENTS.dotfiles.md` changes without updating timestamp
- ✅ Edit in `~/.dotfiles/`, test in `~/`, commit from `~/.dotfiles/`

---

## 📚 Resources

- [yadm documentation](https://yadm.io/)
- [Hyprland wiki](https://wiki.hyprland.org/)
- [HyDE project](https://github.com/prasanthrangan/HyDE)
- [hy3 plugin](https://github.com/outfoxxed/hy3)

---

## ✅ Session Checklist

When starting work on dotfiles:

- [ ] `cd ~/.dotfiles/` (work in staging)
- [ ] Verify `.claude/settings.local.json` exists (if using Claude Code)
- [ ] Read both `AGENTS.md` and `AGENTS.dotfiles.md`
- [ ] Check `AGENTS.local.md` (if exists) for recent session context
- [ ] Check GitHub issues: `gh issue list --repo dbarnett/dotfiles`
- [ ] Check `git status` to see current changes
- [ ] Review `THIS_GIT_BRANCH.md` (if working on a branch)
- [ ] Run diagnostic commands to understand current state

When ending a session:

- [ ] Update `AGENTS.local.md` with:
  - Session date and what was worked on
  - Relevant GitHub issues (last fetched date)
  - Any TODOs or temporary notes for next session
- [ ] Update `AGENTS.dotfiles.md` ONLY if configuration structure changed
- [ ] Update timestamp in this file if modified
- [ ] Commit meaningful changes to staging branch
- [ ] Consider filing GitHub issues for any recurring problems

---

**End of AGENTS.dotfiles.md**
