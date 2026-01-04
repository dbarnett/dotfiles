# Hyprland Desktop Environment Configuration

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

- [#3](https://github.com/dbarnett/dotfiles/issues/3) - waybar missing icons and rich content
- (FIXED) [#2](https://github.com/dbarnett/dotfiles/issues/2) - wrong notification center (kept starting dunst vs swaync)

### Issue: Hyprland Configuration Cleanup

**Problem:** Previously added invalid windowrule parameters.

**Solution:** Cleaned up window rules to use only valid Hyprland syntax.

### Issue: Waybar Icon Rendering
> **❓ ROOT CAUSE:** May be HyDE-specific (early startup timing) or general waybar/font issue.

**Current Symptoms:**
- Battery shows "74%" with blank space instead of battery icon
- Some modules show literal text instead of icons
- Network/Bluetooth: Some icons work, others show blank spaces
- Icons verified present in both HyDE defaults and custom configs

**Investigation Status:**
- Font services: JetBrainsMono Nerd Font installed and detected
- Icons present in configs: Verified with hexdump
- Issue affects both Nerd Font glyphs and Unicode emojis
- Similar behavior across different HyDE versions

**Likely Cause:** Waybar startup timing conflicts in HyDE's initialization sequence.

### Issue: Icons Not Rendering (#3) ⚠️ ACTIVE PROBLEM

> **❓ UNCLEAR:** May be HyDE-specific (early startup timing) or general waybar/font issue.

**Current waybar appearance (from screenshots):**
```
[3% 60%] [deactivated 22:49]  [1 2 3 claude ~/.dotfiles]  [74% wlan0 40% 40%] [🛜 B 62%] [  ] [  ]
```

**Current symptoms:**
- Battery shows "74%" with blank space instead of battery icon
- idle_inhibitor shows literal text "deactivated" instead of caffeine icon  
- Network/Bluetooth: Some icons work (🛜 wifi, B for bluetooth glyph)
- Other modules: Empty boxes/blanks where icons should be

**Investigation findings:**
- Font services: JetBrainsMono Nerd Font installed and detected
- Icons verified present in both HyDE defaults and custom configs  
- Affects both Nerd Font glyphs and Unicode emojis
- Issue persists across different HyDE versions

**Likely cause:** Waybar startup timing conflicts in HyDE's initialization sequence.

## Migration Decision Framework

**Key considerations for your choice:**
- **Working icons:** Primary issue to resolve
- **Customization ease:** How much framework fighting you'll tolerate  
- **Learning curve:** Initial setup vs long-term maintenance
- **Flexibility:** Ability to migrate between setups in future

## Current Desktop Status

**Working correctly:**
- ✅ Notification center (swaync)
- ✅ Hyprland window rules
- ✅ Custom scripts and fonts
- ✅ Dunst properly masked

**Needs resolution:**
- ❌ Waybar icon rendering
- ❓ Module override clarity (HyDE-specific)

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


## References

- [Hyprland Wiki](https://wiki.hyprland.org/)
- [HyDE Project](https://github.com/prasanthrangan/HyDE)
- [HyDE Waybar Documentation](https://hydeproject.pages.dev/de/configuring/waybar/)
- [Waybar Wiki](https://github.com/Alexays/Waybar/wiki)
- [SwayNC](https://github.com/ErikReider/SwayNotificationCenter)
