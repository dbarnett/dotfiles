#!/bin/sh
# GNOME-specific settings. Must run inside an active GNOME session (needs DBUS).
# chezmoi apply from a GNOME terminal satisfies this.

if [ "$(uname -s)" != "Linux" ] || [ "$XDG_CURRENT_DESKTOP" != "GNOME" ]; then
  echo "Skipping GNOME settings (requires Linux+GNOME, got $(uname -s)/$XDG_CURRENT_DESKTOP)" 1>&2
  exit 0
fi

echo "Configuring GNOME settings..." 1>&2

# Caps Lock (remapped to F19 by keyd) opens vicinae clipboard/snippet manager
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
  "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Vicinae'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'vicinae toggle'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding 'F19'

# WiFi: use iwd backend (better for Intel BE200 / Wi-Fi 7), disable wpa_supplicant conflict
# Note: requires /etc/NetworkManager/conf.d/iwd.conf (set up by system bootstrap or manually)

echo "GNOME settings applied." 1>&2
