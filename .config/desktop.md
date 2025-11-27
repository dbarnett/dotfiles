# Desktop Environment Configuration

**Last updated:** 2025-11-27

## Overview

Desktop setup using Hyprland via the HyDE (Hyprland Desktop Environment) framework on Arch Linux.

## Core Components

- **Compositor:** Hyprland 0.52.1
- **Desktop Framework:** HyDE
- **Status Bar:** Waybar (managed by HyDE's Python watcher)
- **Notification Daemon:** swaync (NOT dunst - see issues below)
- **Launcher:** vicinae, rofi
- **Terminal:** Kitty
- **Wallpaper:** swww with HyDE's wallbash color extraction

## HyDE Configuration System

HyDE dynamically generates waybar configs. Key locations:

- **Generated config:** `~/.config/waybar/config.jsonc` (DO NOT edit directly - gets regenerated)
- **Module overrides:** `~/.local/share/waybar/modules/*.jsonc` (EDIT HERE)
- **Custom modules:** Place in `~/.local/share/waybar/modules/`
- **Waybar watcher:** `~/.local/lib/hyde/waybar.py --watch` (runs as background process)

## Customizations Applied

### Waybar Modules (in `~/.local/share/waybar/modules/`)

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
   - Click to switch layouts via hyde-shell
   - **NOTE:** Currently NOT in HyDE's generated config, needs manual addition

### Scripts Created

- **`~/.local/bin/waybar-keyboard-layout`** - Converts Hyprland keyboard layout to flag emoji

## Known Issues & Fixes

### Issue: Dunst vs Swaync Conflict

**Problem:** Dunst auto-starts via DBus activation, preventing swaync from running.

**Solution Applied:**
```bash
# Masked systemd service
systemctl --user mask dunst.service

# Masked DBus activation
ln -sf /dev/null ~/.local/share/dbus-1/services/org.knopwob.dunst.service
```

**Verify swaync is running:**
```bash
ps aux | grep "[s]waync"
busctl --user list | grep Notifications
```

### Issue: Hyprland Window Rule Errors

**Problem:** Added invalid `urgent` parameter to windowrulev2 (doesn't exist in Hyprland).

**Solution:** Removed the broken rule. Web notification click-to-focus is a known Wayland limitation.

### Issue: Config Auto-Regeneration

**Problem:** HyDE regenerates `~/.config/waybar/config.jsonc` dynamically.

**Solution:** Don't edit config.jsonc directly. Override modules in `~/.local/share/waybar/modules/`.

## Next Steps / TODO

- [ ] Add `custom/keyboard` to HyDE's waybar layout config
- [ ] Configure swaync appearance (currently using default with large bell icon)
- [ ] Investigate HyDE config.ctl system for permanent waybar layout changes
- [ ] Fix notification click behavior (currently shows kitty terminal popup)
- [ ] Configure wallbash to use `--vibrant` profile for better color contrast
- [ ] Remove/configure hidden waybar modules (custom/wallchange, custom/theme, etc.)

## HyDE Color System (Wallbash)

Colors are extracted from wallpapers via `~/.local/lib/hyde/wallbash.sh`.

**Color profiles available:**
- `--default` - Balanced (current)
- `--vibrant` - Higher saturation, better contrast
- `--pastel` - Muted colors
- `--mono` - Monochrome

**To change profile:** Modify how wallbash is called in HyDE's wallpaper scripts.

## Useful Commands

```bash
# Restart waybar
systemctl --user restart hyde-hyprland-bar.service

# Check waybar logs
journalctl --user -u hyde-hyprland-bar.service -n 50

# Reload Hyprland config
hyprctl reload

# Check Hyprland config errors
hyprctl configerrors

# Check keyboard layout
hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap'

# Kill notification daemon and restart
killall swaync && swaync &
```

## Files Modified in Dotfiles

- `~/.config/hypr/windowrules.conf` - Hyprland window rules (removed broken urgent rule)
- `~/.local/share/waybar/modules/*.jsonc` - Waybar module overrides
- `~/.local/bin/waybar-keyboard-layout` - Custom keyboard layout script
- `~/.local/share/dbus-1/services/org.knopwob.dunst.service` - Dunst DBus mask

## References

- [Hyprland Wiki](https://wiki.hyprland.org/)
- [HyDE Project](https://github.com/prasanthrangan/HyDE)
- [Waybar Wiki](https://github.com/Alexays/Waybar/wiki)
- [SwayNC](https://github.com/ErikReider/SwayNotificationCenter)
