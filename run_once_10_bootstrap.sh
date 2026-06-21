#!/bin/sh

system_type=$(uname -s)

# Write a system config file safely:
# - skips if content already matches (and no mode specified)
# - backs up before overwriting
# - uses sudo only if file/dir not writable by current user
# - mode: optional chmod arg (e.g. 0755) applied after write
# Content string: use \n for newlines (expanded via printf %b)
write_system_file() {
  dest="$1"
  content=$(printf '%b' "$2")
  mode="${3:-}"
  dir=$(dirname "$dest")

  # Skip entirely if content matches and no mode to apply
  if [ -z "$mode" ] && [ -r "$dest" ] && [ "$(cat "$dest")" = "$content" ]; then
    return 0
  fi

  # Determine if sudo needed
  if [ -w "$dest" ] || [ -w "$dir" ]; then
    use_sudo=0
  else
    use_sudo=1
  fi

  # Ensure parent dir exists
  if [ "$use_sudo" = 1 ]; then
    sudo mkdir -p "$dir"
  else
    mkdir -p "$dir"
  fi

  # Write if content differs
  if ! [ -r "$dest" ] || [ "$(cat "$dest")" != "$content" ]; then
    if [ "$use_sudo" = 1 ]; then
      [ -f "$dest" ] && sudo cp "$dest" "${dest}.bak" 2>/dev/null || true
      printf '%s' "$content" | sudo tee "$dest" >/dev/null
    else
      [ -f "$dest" ] && cp "$dest" "${dest}.bak" 2>/dev/null || true
      printf '%s' "$content" > "$dest"
    fi
  fi

  # Apply mode if specified
  if [ -n "$mode" ]; then
    if [ "$use_sudo" = 1 ]; then
      sudo chmod "$mode" "$dest"
    else
      chmod "$mode" "$dest"
    fi
  fi
}

install_essential_pkgs() {
  echo "Installing essential system packages..." 1>&2

  if [ "$system_type" != "Linux" ]; then
    echo "Skipping package install: $system_type not yet supported" 1>&2
    return
  fi

  if grep -qe 'ID\(_LIKE\)\?=arch' /etc/os-release; then
    install_essential_arch
  elif grep -qe 'ID\(_LIKE\)\?=debian' /etc/os-release; then
    install_essential_debs
  else
    echo "Skipping package install: only Arch and Debian-like distros supported" 1>&2
  fi
}

install_essential_arch() {
  # Install yay (AUR helper) if not present
  if ! command -v yay >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay-bootstrap
    (cd /tmp/yay-bootstrap && makepkg -si --noconfirm)
    rm -rf /tmp/yay-bootstrap
  fi

  sudo pacman -S --needed --noconfirm keyd vicinae

  setup_keyd
}

install_essential_debs() {
  sudo apt install -y \
    build-essential \
    cmake \
    colordiff \
    colormake \
    curl \
    direnv \
    fzf \
    keychain \
    percol \
    python3 \
    python3-stdeb \
    pythonpy \
    nodejs \
    npm \
    neovim \
    vim-gtk3 \
    keyd

  install_vicinae_linux
  setup_keyd
}

install_vicinae_linux() {
  if command -v vicinae >/dev/null 2>&1; then
    echo "vicinae already installed." 1>&2
    return
  fi
  # Download latest release binary from GitHub
  VICINAE_URL=$(curl -s https://api.github.com/repos/vicinaehq/vicinae/releases/latest \
    | grep "browser_download_url.*linux.*x86_64" | head -1 | cut -d'"' -f4)
  if [ -z "$VICINAE_URL" ]; then
    echo "Warning: could not find vicinae release URL. Install manually from https://github.com/vicinaehq/vicinae/releases" 1>&2
    return
  fi
  curl -L "$VICINAE_URL" -o /tmp/vicinae && sudo install /tmp/vicinae /usr/local/bin/vicinae && rm /tmp/vicinae
}

setup_keyd() {
  write_system_file /etc/keyd/default.conf '[ids]\n*\n\n[main]\ncapslock = f19\n'
  sudo systemctl enable --now keyd
}

setup_sleep() {
  if [ "$system_type" != "Linux" ]; then return; fi
  # Lid close: hibernate on battery (NVMe ~15s resume), suspend on AC.
  # Avoids suspend-then-hibernate EFI var bugs. No suspend-then-hibernate at all.
  write_system_file /etc/systemd/sleep.conf.d/hibernate-delay.conf \
    '[Sleep]\nHibernateDelaySec=15min\n'
  write_system_file /etc/systemd/logind.conf.d/lid.conf \
    '[Login]\nHandleLidSwitch=hibernate\nHandleLidSwitchExternalPower=suspend\n'
  sudo systemctl reload systemd-logind 2>/dev/null || true
}

setup_networking() {
  if [ "$system_type" != "Linux" ]; then return; fi
  if ! command -v nmcli >/dev/null 2>&1; then return; fi

  # Disable WiFi power saving — kernel enables it by default; causes AP inactivity kicks.
  # udev rule covers boot (interface add); NM dispatcher covers iwd restarts
  # (iwd re-enables power save when it takes over the interface).
  # NM's wifi.powersave setting is silently ignored with iwd backend.
  write_system_file /etc/udev/rules.d/81-wifi-powersave.rules \
    'ACTION=="add", SUBSYSTEM=="net", KERNEL=="wlan*", RUN+="/usr/bin/iw dev %k set power_save off"\n'
  sudo udevadm control --reload-rules
  # $1/$2 are literal in the output script, not expanded here
  # shellcheck disable=SC2016
  nm_dispatcher='#!/bin/sh\n[ "$2" = "up" ] || exit 0\niw dev "$1" set power_save off\n'
  write_system_file /etc/NetworkManager/dispatcher.d/99-wifi-powersave "$nm_dispatcher" 0755

  # systemd-networkd conflicts with NM for DHCP/routing — disable if NM is present.
  sudo systemctl disable --now systemd-networkd systemd-networkd.socket 2>/dev/null || true
  sudo systemctl stop \
    systemd-networkd-varlink.socket \
    systemd-networkd-varlink-metrics.socket \
    systemd-networkd-resolve-hook.socket 2>/dev/null || true

  # wpa_supplicant conflicts with iwd — mask (not just disable) to prevent socket activation.
  # Only applies if iwd backend is configured; wpa_supplicant is correct on non-iwd setups.
  if [ -f /etc/NetworkManager/conf.d/iwd.conf ]; then
    sudo systemctl mask --now wpa_supplicant 2>/dev/null || true
  fi
}

install_rust() {
  echo "Installing Rust..." 1>&2
  rustc_path=$(which rustc)
  if [ -x "$rustc_path" ]; then
    echo "Already installed." 1>&2
  else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  fi
}

install_essential_pkgs
install_rust
setup_sleep
setup_networking
