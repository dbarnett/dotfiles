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

# Screen idle: blank after 5min, lock 10min after blank.
# No suspend — only hibernate (or nothing on AC). Avoids suspend-then-hibernate
# complexity and EFI var bugs. NVMe makes hibernate fast enough (~15s).
#
# Lid close handled by logind (logind.conf.d/lid.conf set in bootstrap):
#   battery: hibernate | AC: suspend (no drain concern on wall power)
#
# GNOME idle sleep — valid types: blank, suspend, hibernate, shutdown, nothing.
#   battery: hibernate after 30min idle
#   AC: nothing (just blank/lock, no sleep — keeps remote sessions alive)
gsettings set org.gnome.desktop.session idle-delay 300
gsettings set org.gnome.desktop.screensaver lock-enabled true
gsettings set org.gnome.desktop.screensaver lock-delay 600
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 1800
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'hibernate'

# WiFi: use iwd backend (better for Intel BE200 / Wi-Fi 7), disable wpa_supplicant conflict
# Note: requires /etc/NetworkManager/conf.d/iwd.conf (set up by system bootstrap or manually)

echo "GNOME settings applied." 1>&2
