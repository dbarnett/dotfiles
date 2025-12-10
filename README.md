# 🏠 David's home directory & dotfiles

## 🚀 System bootstrap

This dotfiles config is currently managed with [yadm](https://yadm.io/), though migration to [chezmoi](https://www.chezmoi.io/) is under consideration for better templating and cross-platform support (see [#1](https://github.com/dbarnett/dotfiles/issues/1)).

[Install yadm](https://yadm.io/docs/install) and then [activate
it](https://yadm.io/docs/getting_started#if-you-have-an-existing-remote-repository)
like:

```sh
$ echo 'export VCS_AUTHOR_EMAIL=me@example.com' >> ~/.profile.local
$ . ~/.profile.local
$ yadm clone git@github.com:dbarnett/dotfiles.git
```

Note: requires env var support in yadm 3.2.0 or later.

**TODO:** Fix sometimes getting stuck on vim plug installs etc and needing rerun.

### 🔄 Development workflow

This repo uses a git worktree for safe editing:
- **`~/`** - Live configs on `main` branch (managed by yadm)
- **`~/.dotfiles/`** - Staging workspace on `staging` branch

To make changes:
```sh
cd ~/.dotfiles/
# Edit files here safely without breaking live system
git add .
git commit -m "Update configs"
# Test changes, then merge to apply live:
git checkout main
git merge staging
```

## 🖥️ Desktop environment

On Arch Linux, this setup includes [HyDE](https://github.com/prasanthrangan/HyDE) (Hyprland Desktop Environment) with customized configs for:
- 🪟 Hyprland compositor
- 🔔 swaync (notification daemon)
- 🚀 Various startup applications and workflows

HyDE configs are located in `~/.config/hypr/` and `~/.config/hyde/`.

See [#2](https://github.com/dbarnett/dotfiles/issues/2) for known issues and configuration details.

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

### For i3 (legacy)

**Note**: This section is legacy - currently using Hyprland instead of i3.

Kill ugly dunst notifications:
```sh
$ sudo apt install notify-osd
$ sudo apt purge dunst
```

Tolerable launcher:
```sh
$ sudo apt remove suckless-tools
$ sudo apt install rofi
$ sudo ln -s /usr/bin/rofi /usr/local/bin/dmenu
```

Prevent weird Nautilus desktop window
(https://faq.i3wm.org/question/1/how-can-i-get-rid-of-the-nautilus-desktop-window.1.html).
```sh
$ gsettings set org.gnome.desktop.background show-desktop-icons false
```
