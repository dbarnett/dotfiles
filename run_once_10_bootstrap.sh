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
  # Hibernate after 15min of suspend (battery idle → suspend → hibernate)
  sudo mkdir -p /etc/systemd/sleep.conf.d
  printf '[Sleep]\nHibernateDelaySec=15min\n' | sudo tee /etc/systemd/sleep.conf.d/hibernate-delay.conf

  # Lid close: hibernate on battery (NVMe fast enough ~15s), suspend on AC (no drain concern).
  # Avoids suspend-then-hibernate EFI var bugs. No suspend on battery at all.
  sudo mkdir -p /etc/systemd/logind.conf.d
  printf '[Login]\nHandleLidSwitch=hibernate\nHandleLidSwitchExternalPower=suspend\n' \
    | sudo tee /etc/systemd/logind.conf.d/lid.conf
  sudo systemctl reload systemd-logind 2>/dev/null || true
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
