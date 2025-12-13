# Desktop Environment Configuration

**Last updated:** 2025-11-30

## 🚀 Quick Start for New Claude Sessions

**Active issues to fix:**
1. ⚠️ **Icon rendering broken** - All waybar icons show as blanks/text instead of icons
2. ❓ **HyDE module override mechanism unclear** - Don't know how to properly override `~/.local/share` modules
3. 📝 **~/dotfiles/ cruft** - Old directory needs consolidation with yadm worktree

**Key context:**
- Waybar appearance: `[3% 60%] [deactivated 22:49] ... [74% wlan0 40%]` ← should have icons, not text/blanks
- HyDE scans BOTH `~/.config/waybar/modules/` and `~/.local/share/waybar/modules/`
- System files in `~/.local/share` come from `~/HyDE/Configs/`, not packages
- Edit files in real `$HOME` paths, commit with `yadm add` + `yadm commit`

**Jump to:** [Icon rendering issue](#issue-icons-not-rendering-2025-11-30--active-problem) | [Module override problem](#issue-module-overrides-not-working-2025-11-30) | [HyDE config system](#hyde-configuration-system)

## Overview

Desktop setup using Hyprland via the HyDE (Hyprland Desktop Environment) framework on Arch Linux.

### Portability Notes

When migrating to other Hyprland setups (ML4W, etc.):

**✅ Fully Portable (work as-is):**
- Waybar module configs (`~/.config/waybar/modules/*.jsonc`)
- Custom scripts (`~/.local/bin/waybar-keyboard-layout`)
- Dunst/swaync DBus masking
- Hyprland window rules (`.config/hypr/windowrules.conf`)

**🚨 HyDE-Specific (need replacement):**
- `hyde-shell waybar` auto-generation → manual waybar config editing
- `~/.local/share/waybar/` system defaults → not present in other setups
- Wallbash color extraction → replace with pywal, static themes, or other
- HyDE's waybar Python watcher → standard waybar reload methods

**❓ May Need Adjustment:**
- Icon rendering issues (may or may not exist in other setups)
- Custom module click handlers using `hyde-shell` → replace with direct commands

## Core Components

- **Compositor:** Hyprland 0.52.1
- **Desktop Framework:** HyDE
- **Status Bar:** Waybar (managed by HyDE's Python watcher)
- **Notification Daemon:** swaync (NOT dunst - see issues below)
- **Launcher:** vicinae, rofi
- **Terminal:** Kitty
- **Wallpaper:** swww with HyDE's wallbash color extraction

## HyDE Configuration System

> **🚨 HyDE-SPECIFIC:** This entire section describes HyDE's custom waybar management. Other Hyprland setups (ML4W, etc.) use standard waybar configs without auto-generation.

HyDE uses a two-tier waybar configuration system with auto-generation:

### File Hierarchy
- **`~/.local/share/waybar/`**: System defaults (managed by HyDE, overwritten on updates - DON'T EDIT)
- **`~/.config/waybar/`**: User customizations (edit here, takes precedence)
  - `modules/`: Module definition overrides (`.jsonc` files)
  - `includes/includes.json`: **Auto-generated** by `hyde-shell waybar` - scans both directories
  - `config.jsonc`: Working config (transient, gets regenerated)
  - `style.css`: Auto-generated CSS aggregator

### Module Override Workflow (HyDE-specific)
To customize a module:
1. Copy from `~/.local/share/waybar/modules/X.jsonc` to `~/.config/waybar/modules/X.jsonc`
2. Edit the `~/.config/` version
3. **Remove system default**: `rm ~/.local/share/waybar/modules/X.jsonc`
   - Required because `hyde-shell waybar` includes both, and last one wins
4. Regenerate: `hyde-shell waybar`
5. Restart: `killall waybar` (Hyprland auto-restarts)

**For non-HyDE setups:** Just edit `~/.config/waybar/config.jsonc` and module files directly. No auto-generation to worry about.

## Customizations Applied

> **✅ PORTABLE:** These module customizations work with any waybar setup, not just HyDE.

### Waybar Modules (in `~/.config/waybar/modules/`)

1. **`battery.jsonc`** - Battery with visual states
   - Shows icon that changes with charge level
   - Color states: green >80%, yellow <30%, red <15%
   - Icons change from empty to full battery

2. **`idle_inhibitor.jsonc`** - Caffeine mode indicator
   - Shows just icon (☕) instead of "deactivated" text
   - Click to toggle preventing screen sleep

3. **`pulseaudio#microphone.jsonc`** - Mic indicator
   - Shows only icon (🎤 or 🎤 muted)
   - Removed percentage display (was duplicate of speaker volume)

4. **`backlight.jsonc`** - Screen brightness
   - Shows only icon (☀️ variations)
   - Removed percentage (screen itself shows brightness level)
   - Tooltip shows actual percentage on hover

5. **`custom-keyboard.jsonc`** - Keyboard layout indicator
   - Script: `~/.local/bin/waybar-keyboard-layout`
   - Shows flags: 🇺🇸 (English) / 🇲🇽 (Spanish)
   - Click handler: `hyde-shell keyboardswitch` (🚨 HyDE-specific)
     - **For non-HyDE:** Replace with `hyprctl switchxkblayout` or custom script
   - **NOTE:** Currently NOT in HyDE's generated config, needs manual addition

### Scripts Created

> **✅ PORTABLE:** Works with any Hyprland setup that uses waybar.

- **`~/.local/bin/waybar-keyboard-layout`** - Converts Hyprland keyboard layout to flag emoji
  - Uses `hyprctl` (standard Hyprland command)
  - Called by `custom-keyboard.jsonc` module

## Known Issues & Fixes

### Issue: Dunst vs Swaync Conflict

> **✅ PORTABLE:** This is a general Linux desktop issue, not HyDE-specific.

**Problem:** Dunst auto-starts via DBus activation, preventing swaync from running.

**Solution Applied:**
```shell
# Masked systemd service
systemctl --user mask dunst.service

# Masked DBus activation
ln -sf /dev/null ~/.local/share/dbus-1/services/org.knopwob.dunst.service
```

**Verify swaync is running:**
```shell
ps aux | grep "[s]waync"
busctl --user list | grep Notifications
```

### Issue: Hyprland Window Rule Errors

**Problem:** Added invalid `urgent` parameter to windowrulev2 (doesn't exist in Hyprland).

**Solution:** Removed the broken rule. Web notification click-to-focus is a known Wayland limitation.

### Issue: Module Overrides Not Working (2025-11-30)

> **🚨 HyDE-SPECIFIC:** This is caused by HyDE's auto-generation system.

**Problem:** Edited modules in `~/.config/waybar/modules/` but changes not appearing.

**Root cause:** HyDE's `hyde-shell waybar` scans BOTH `~/.config` and `~/.local/share` directories and includes everything in `includes.json`. When a module exists in both locations, the **last loaded wins** (system default overrides custom).

**Solution (INCORRECT - see below):** ~~Remove system defaults~~ This was wrong - fighting HyDE's design.

**CRITICAL LESSON LEARNED:** HyDE's `waybar.py` intentionally scans BOTH directories. The system files in `~/.local/share` are NOT managed by packages - they're copied from `~/HyDE/Configs/` during installation. Deleting them fights HyDE's architecture.

**Proper override mechanism:** UNKNOWN - need to investigate how HyDE handles duplicate module definitions (JSON merging? last-wins? key-level override?)

**Current state:** Both copies exist again (restored from `~/HyDE/Configs/.local/share/waybar/modules/`). Custom versions in `~/.config` may or may not be taking effect.

### Issue: Icons Not Rendering (2025-11-30) ⚠️ ACTIVE PROBLEM

> **❓ UNCLEAR:** May be HyDE-specific (early startup timing) or general waybar/font issue.

**Current waybar appearance (from screenshots):**
```
[3% 60%] [deactivated 22:49]  [1 2 3 claude ~/.dotfiles]  [74% wlan0 40% 40%] [🛜 B 62%] [  ] [  ]
```
- Battery: "74%" with blank space instead of battery icon
- idle_inhibitor: literal text "deactivated" instead of caffeine icon
- Network/Bluetooth: Some icons work (🛜 wifi, B for bluetooth glyph)
- Other modules: Empty boxes/blanks where icons should be

**Symptoms:**
- Battery shows "74%" but no battery icon (blank space before percentage)
- idle_inhibitor shows literal text "deactivated" instead of caffeine icon
- Even Unicode emojis (☕ 💤) fail to render when tested
- Nerd Font icons in config files (verified present with `cat -A`, hexdump)

**Investigation:**
- JetBrainsMono Nerd Font installed and detected by fontconfig
- Font file: `~/.local/share/fonts/JetBrains/JetBrainsMonoNerdFont-Regular.ttf`
- Icons ARE in both HyDE's defaults and our custom configs
- Waybar has correct libraries (pango, cairo, fontconfig)
- Standard emojis also fail → not just Nerd Font private-use-area glyphs

**HyDE's original configs use Unicode escapes:**
- `idle_inhibitor.jsonc`: `\udb80\udd76` (activated), `\udb81\udeca` (deactivated)
- These are Nerd Font Material Design Icons in UTF-16 surrogate pair format

**Hypothesis:** Waybar starts before font services fully initialize, causing all icon rendering to fail. May be HyDE-specific if it launches waybar very early in startup.

**Next steps:**
- Test delayed waybar startup
- Examine Pango font config for waybar process
- Try on non-HyDE Hyprland setup to isolate
- Check if HyDE's Unicode escape format works better than direct UTF-8

## Next Steps / TODO

- [ ] Add `custom/keyboard` to HyDE's waybar layout config
- [ ] Configure swaync appearance (currently using default with large bell icon)
- [ ] Investigate HyDE config.ctl system for permanent waybar layout changes
- [ ] Fix notification click behavior (currently shows kitty terminal popup)
- [ ] Configure wallbash to use `--vibrant` profile for better color contrast
- [ ] Remove/configure hidden waybar modules (custom/wallchange, custom/theme, etc.)

## HyDE Color System (Wallbash)

> **🚨 HyDE-SPECIFIC:** Other setups may use different theming (pywal, etc.) or static themes.

Colors are extracted from wallpapers via `~/.local/lib/hyde/wallbash.sh`.

**Color profiles available:**
- `--default` - Balanced (current)
- `--vibrant` - Higher saturation, better contrast
- `--pastel` - Muted colors
- `--mono` - Monochrome

**To change profile:** Modify how wallbash is called in HyDE's wallpaper scripts.

## Useful Commands

```shell
# Restart waybar
killall waybar  # Hyprland auto-restarts it

# Regenerate waybar includes after module changes
hyde-shell waybar

# Check waybar process
pgrep -a waybar

# Reload Hyprland config
hyprctl reload

# Check Hyprland config errors
hyprctl configerrors

# Check keyboard layout
hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap'

# Kill notification daemon and restart
killall swaync && swaync &

# Font debugging
fc-match "JetBrainsMono Nerd Font"
fc-list | grep -i nerd
```

## Dotfiles Workflow

**Repository:** `~/.local/share/yadm/repo.git` (bare repo managed by yadm)

**Worktrees:**
- `$HOME` (main branch) - Live environment
- `~/.dotfiles/` (staging branch) - Safe editing environment (THIS directory where Claude edits)

**Editing workflow:**
1. Edit files in `~/.dotfiles/` (staging worktree) OR directly in `$HOME` paths
2. Use `yadm add <file>` to stage changes
3. Use `yadm commit` to commit
4. If edited in staging: merge `staging → main` to apply to live environment

**IMPORTANT:** Prefer editing files directly in their real `$HOME` paths and using yadm to commit. The staging worktree is for safety when unsure, but creates sync complexity.

**Known issue:** `~/dotfiles/` exists - likely old cruft from before yadm migration. Need to investigate and consolidate.

## Files Modified in Dotfiles (yadm status)

**Staged (ready to commit):**
- `~/.config/waybar/modules/battery.jsonc`
- `~/.config/waybar/modules/custom-keyboard.jsonc`
- `~/.config/waybar/modules/hyprland-language.jsonc`
- `~/.config/waybar/modules/idle_inhibitor.jsonc`
- `~/.config/waybar/modules/pulseaudio#microphone.jsonc`

**Modified (staged):**
- `~/.config/desktop.md` - This documentation file

**Previously committed:**
- `~/.config/hypr/windowrules.conf` - Hyprland window rules
- `~/.local/bin/waybar-keyboard-layout` - Custom keyboard layout script
- `~/.local/share/dbus-1/services/org.knopwob.dunst.service` - Dunst DBus mask

**Note:** The waybar module files may not be overriding HyDE's system defaults correctly - override mechanism still unclear.

## References

- [Hyprland Wiki](https://wiki.hyprland.org/)
- [HyDE Project](https://github.com/prasanthrangan/HyDE)
- [HyDE Waybar Documentation](https://hydeproject.pages.dev/de/configuring/waybar/)
- [Waybar Wiki](https://github.com/Alexays/Waybar/wiki)
- [SwayNC](https://github.com/ErikReider/SwayNotificationCenter)
