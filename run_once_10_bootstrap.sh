#!/bin/sh

system_type=$(uname -s)

install_essential_pkgs() {
  echo "Installing essential system packages..." 1>&2

  if [ "$system_type" != "Linux" ]; then
    # TODO: Handle other platforms.
    echo "Failed: system type $system_type not supported" 1>&2
    return
  fi

  if grep -qe 'ID\(_LIKE\)\?=arch' /etc/os-release; then
    install_essential_arch
  elif grep -qe 'ID\(_LIKE\)\?=debian' /etc/os-release; then
    install_essential_debs
  else
    echo "Failed: only Arch and Debian-like distros supported" 1>&2
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

  sudo pacman -S --needed --noconfirm keyd

  # vicinae: AUR clipboard/snippet manager
  yay -S --needed --noconfirm vicinae

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
  sudo mkdir -p /etc/keyd
  printf '[ids]\n*\n\n[main]\ncapslock = f19\n' | sudo tee /etc/keyd/default.conf
  sudo systemctl enable --now keyd
}

setup_sleep() {
  if [ "$system_type" != "Linux" ]; then return; fi
  # One sudo: create dirs, write configs, reload logind.
  # Hibernate after 15min of suspend (battery idle → suspend → hibernate).
  # Lid close: hibernate on battery (NVMe ~15s), suspend on AC.
  # Avoids suspend-then-hibernate EFI var bugs.
  sudo sh -c '
    mkdir -p /etc/systemd/sleep.conf.d /etc/systemd/logind.conf.d
    printf "[Sleep]\nHibernateDelaySec=15min\n" > /etc/systemd/sleep.conf.d/hibernate-delay.conf
    printf "[Login]\nHandleLidSwitch=hibernate\nHandleLidSwitchExternalPower=suspend\n" > /etc/systemd/logind.conf.d/lid.conf
    systemctl reload systemd-logind
  '
}

setup_networking() {
  if [ "$system_type" != "Linux" ]; then return; fi
  if ! command -v nmcli >/dev/null 2>&1; then return; fi

  # Disable WiFi power saving — kernel enables it by default; causes AP to kick
  # client for "inactivity" (reason code 4) on otherwise-healthy connections.
  sudo mkdir -p /etc/NetworkManager/conf.d
  printf '[connection]\nwifi.powersave = 2\n' | sudo tee /etc/NetworkManager/conf.d/wifi-powersave.conf

  # systemd-networkd conflicts with NM for DHCP/routing — disable if NM is present.
  sudo systemctl disable --now systemd-networkd systemd-networkd.socket 2>/dev/null || true
  sudo systemctl stop \
    systemd-networkd-varlink.socket \
    systemd-networkd-varlink-metrics.socket \
    systemd-networkd-resolve-hook.socket 2>/dev/null || true

  # wpa_supplicant conflicts with iwd — only disable if iwd backend is configured.
  # (wpa_supplicant is the correct NM backend on setups not using iwd.)
  if [ -f /etc/NetworkManager/conf.d/iwd.conf ]; then
    sudo systemctl disable --now wpa_supplicant 2>/dev/null || true
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
