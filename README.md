# 🏠 David's home directory & dotfiles

## 🚀 System bootstrap

This dotfiles config uses [chezmoi](https://www.chezmoi.io/) for templating and cross-platform support.

**Note:** The `yadm-legacy` bookmark maintains the last yadm-based version if rollback is needed.

### First-time setup on a new machine

**Prerequisites:** If you have another dotfiles manager (yadm, stow, etc.) active, back up and remove/disable it first to avoid conflicts.

**Note:** Chezmoi automatically removes leftover yadm template files (`##template`, `##template,e.*`) on apply.

1. **Install chezmoi and age:**
   ```sh
   # Arch Linux
   sudo pacman -S chezmoi age

   # macOS
   brew install chezmoi age
   ```

   **Arch Linux only:** Also install Nix (used alongside pacman for dev tools — see [Package management](#-package-management-arch-linux) below). Use the Determinate Systems installer; the official installer has quirks on Arch. After installing, symlink the fish integration:
   ```sh
   sudo ln -s /etc/profile.d/nix-daemon.fish /etc/fish/conf.d/nix-daemon.fish
   ```

2. **Set up age encryption key:**

   **First machine (generate new key):**
   ```sh
   mkdir -p ~/.config/chezmoi
   age-keygen -o ~/.config/chezmoi/key.txt
   # Save the public key shown - you'll need it in step 3
   ```

   **Additional machines (use existing key):**
   ```sh
   mkdir -p ~/.config/chezmoi
   # Securely copy key.txt from first machine to ~/.config/chezmoi/key.txt
   # (via ssh, password manager, encrypted USB, etc.)
   ```

   **⚠️ Security:** The `key.txt` file is your private key. Protect it like a password.

3. **Configure chezmoi:**
   Create `~/.config/chezmoi/chezmoi.toml`:
   ```toml
   encryption = "age"
   [age]
       identity = "~/.config/chezmoi/key.txt"
       recipient = "age1..."  # Your public key from step 2
   ```

4. **Initialize:**
   ```sh
   chezmoi init git@github.com:dbarnett/dotfiles.git
   ```

   **⚠️ Caution:** Don't use `chezmoi init --apply` - it can [silently overwrite existing files](https://github.com/twpayne/chezmoi/issues/1551).

5. **Decrypt encrypted files:**
   The encrypted files (`.gmailctl/config.personal.jsonnet`) will need to be manually decrypted on the first machine, then chezmoi will sync them encrypted to new machines.

6. **Review and apply dotfiles:**
   ```sh
   # Preview what will change
   chezmoi diff

   # Apply if everything looks good
   chezmoi apply

   # Source the new profile
   . ~/.profile.local
   ```

   The bootstrap script (`run_once_bootstrap.sh`) will run automatically on first apply.

   **Templates use your git config email by default.** To override (e.g., work email on work machine), edit `~/.config/chezmoi/chezmoi.toml` and add:
   ```toml
   [data]
       vcs_author_email = "work@example.com"
   ```
   Then re-apply: `chezmoi apply`

### 🔄 Development workflow

Edit files directly in the chezmoi source directory and apply:

```sh
cd ~/.local/share/chezmoi
# Edit files
chezmoi diff  # Preview changes
chezmoi apply  # Apply to $HOME
```

Or use chezmoi commands from anywhere:
```sh
chezmoi edit ~/.bashrc  # Opens in editor, auto-applies on save
chezmoi add ~/.new_config  # Track new file
```

## 📦 Package management (Arch Linux)

Packages are split between **pacman/yay** (system-level) and **Nix** (dev tools). Nix is not used on macOS.

| Tool | Manager | Reason |
|------|---------|--------|
| pandoc, shellcheck | Nix | Avoid Haskell rebuild cascade in pacman |
| ruff, marksman | Nix | Dev tools, no system integration needed |
| pipewire, qt6, bluez, etc. | pacman | System-integrated, must stay system-managed |
| docker, networkmanager | pacman | System integration |

**Updating:**
```sh
yay -Syu                   # system packages
nix profile upgrade --all  # nix packages
```

## 🖥️ Desktop environment

On Arch Linux, this setup uses **GNOME** (previously Hyprland/HyDE — see `~/hypr.md` for legacy config).

GNOME-specific setup runs automatically via `run_once_setup_gnome.sh` when `chezmoi apply` is run inside an active GNOME session. This configures:
- **Caps Lock → vicinae** (clipboard/snippet manager): Caps Lock remapped to F19 via keyd, F19 bound to `vicinae toggle` in GNOME keybindings

**Note:** `run_once_setup_gnome.sh` is a no-op on macOS and non-GNOME desktops.

### GNOME manual steps (not easily automatable)

- **WiFi backend**: create `/etc/NetworkManager/conf.d/iwd.conf` with `[device]\nwifi.backend=iwd` and disable `wpa_supplicant` (conflicts with iwd on Intel BE200 Wi-Fi 7). Once this file exists, bootstrap's `setup_networking()` will handle disabling wpa_supplicant on future runs.
- **keyd**: installed by bootstrap, enabled via systemd — verify with `systemctl status keyd`

### jj machine-local config

`~/.config/jj/config.toml` is managed by chezmoi (base config). jj also reads `~/.config/jj/conf.d/*.toml`; that directory is ignored by chezmoi so it's safe for machine-local additions.

`~/.local/bin/jj` (tracked by chezmoi) is a shell-agnostic wrapper that blocks `jj git push` when `jj push` is aliased — no-op otherwise, safe on all machines.

On machines with `jj-hooks`/`jj-hp` installed:

```sh
JJ_CONFIG=~/.config/jj/conf.d/local.toml jj-hooks init
```

Writes config directly into `conf.d/local.toml` (ignored by chezmoi). Once the alias exists, the wrapper automatically activates the `jj git push` block.

For `hk` global git hooks: `hk install --global` writes to `~/.gitconfig` (chezmoi-tracked). Instead, append the hook sections to `~/.gitconfig.d/local.conf` (already included, not tracked by chezmoi).

### 🔧 Configuration architecture

This dotfiles repo supports multiple environments through two main strategies:

### Config variants: Personal vs Work

**Base configs** (git-tracked) contain portable, general-purpose setup.
**`.local` configs** (gitignored) contain work-specific tools and company setup.

**Pattern:** Base files automatically source `.local` files if they exist:

**In `.profile`:**
```shell
# Set up local env vars, etc
if [ -f "$HOME/.profile.local" ] ; then
  . "$HOME/.profile.local"
fi
```

**In `.hgrc`:** (legacy)
```shell
# Load local hgrc config
%include ~/.hgrc.local
```

**What goes where:**
- ✅ **Base (git):** Portable tool setup (Homebrew, Cargo, Starship, direnv), general aliases, OS detection
- ⚠️ **Local (gitignored):** Work-specific tools (pyenv, nvm, SDKMAN, company SDKs), VPN configs, hardcoded machine paths, API keys, work-specific aliases/functions

**Testing separation:** To verify base configs work independently, temporarily rename `.local` files and start a fresh shell. Core functionality should work without errors.

**Chezmoi machine type configuration:**

For work machines, set your machine type in `~/.config/chezmoi/chezmoi.toml`:
```toml
[data]
    machine_profile = "work"
```

This controls various work-specific behaviors:
- **gmailctl:** Changes symlink from `config.personal.jsonnet` → `config.work.jsonnet`
  - Create `~/.gmailctl/config.work.jsonnet` with work-specific Gmail filters
  - OAuth credentials (`credentials.json`, `token.json`) are NOT synced - regenerate per-machine with `gmailctl init`
- **Future use cases:** Can template other configs based on work vs personal machine

### Version Manager Isolation (pyenv, nvm, sdkman)

**Context:** Version managers like pyenv/nvm/sdkman are typically installed by work setup scripts and create complexity:
- Shell-specific implementations (nvm vs fish-nvm are separate tools)
- Path conflicts between personal npm setup and work nvm
- Duplicate installations when fish-nvm and standard nvm don't share directories

**Strategy:** Keep version managers ONLY in `.local` configs on work machines.

**Setup in `.profile.local` (work machine):**
```shell
# Version managers need PATH setup before shell-specific init
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
# Note: nvm.sh sourcing happens in .bashrc.local

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
```

**Bash init in `.bashrc.local` (work machine):**
```shell
# Conditional init - only runs if tools are installed
if [ -x "$(command -v pyenv)" ]; then
  eval "$(pyenv init -)"
fi

# Load standard nvm if using it (conflicts with fish-nvm)
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

**Fish init in `.config/fish/config.local.fish` (work machine):**
```fish
# Version manager initialization
type -q pyenv; and pyenv init - | source

# fish-nvm configuration - point to standard nvm directory to avoid duplicates
set -gx nvm_data "$NVM_DIR/versions/node"
```

**nvm vs fish-nvm conflict resolution:**
- Standard nvm is bash-specific (shell functions)
- fish-nvm is separate implementation for fish
- Both can install node to different directories → duplicates
- Solution: Configure `nvm_data` to point to standard nvm's directory
- Or: Choose one implementation (fish-nvm only, skip loading nvm.sh in bash)

### Config variants: Linux vs macOS

**Linux systems** include full Hyprland/HyDE desktop environment configs (`.config/hypr/`, `.config/waybar/`, etc.).
**macOS systems** have no desktop environment configs and use different tool paths (Homebrew at `/opt/homebrew/`, BSD vs GNU tools).

Handled via OS detection in shell configs (e.g., checking `uname -s`) and inline conditionals for tool paths. Yadm also supports alternates (`##os.Darwin`, `##os.Linux`) and templating (`##template` with `{{ env.VAR }}`), though migration to [chezmoi](https://www.chezmoi.io/) is planned for better cross-platform support (see [#1](https://github.com/dbarnett/dotfiles/issues/1)).

### Cross-sourcing pattern

Fish shell sources `.profile` via `foreign-env` plugin:
```fish
fenv source ~/.profile
```

**Why:** Avoids duplicating PATH setup and tool initialization between bash and fish. A single source of truth in `.profile` keeps configs DRY.

**Design:** `.profile` is structured to be re-sourceable (safe to call multiple times) and shell-agnostic (POSIX sh), enabling hot-reloading during config development without logout/login cycles.

**Note:** This pattern has some wrinkles and may be revisited later.

## 🔐 SSH setup

Set up SSH keys for GitHub:
https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/

### 🔤 Fonts

Some things like [Starship](https://starship.rs) need special fonts like
[Nerd Fonts](https://nerdfonts.com). To install on e.g. Debian Linux, do:

```sh
$ wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
$ mkdir -p ~/.local/share/fonts
$ cd ~/.local/share/fonts/
$ unzip ~/FiraCode.zip *.ttf
```

or on Mac just install font-fira-code-nerd-font through Homebrew.

Also requires some weird
[Nerd Font Web setup](https://mshaugh.github.io/nerdfont-webfonts/) involving
`term_.prefs_` for things like Chrome Secure Shell extension.

### ⚙️ Other preferences

Set up Compose key. On Linux:

```sh
$ setxkbmap -option compose:ralt
```

GTK Theme:
gtk-chtheme (Ambiance or similar)

gnome-terminal scrolling:
Edit > Profile Preferences > Scrolling > Scrollback > 10000

---

## 📜 Legacy system bootstraps

The following instructions are mostly old manual setup instructions I need to
update to take advantage of yadm.

### 🍎 Basic setup (macOS)

Install https://brew.sh/

```sh
$ brew install $(<system_bootstrap/brew_packages.txt)
$ pip3 install pythonpy
```

If there are permission errors, try

```sh
chmod g+w -R /usr/local
```

and check paths and user has groups admin and staff.
