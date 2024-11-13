# David's home directory & dotfiles

## System bootstrap

This dotfiles config is applied using [yadm](https://yadm.io/).
[Install it](https://yadm.io/docs/install) and then [activate
it](https://yadm.io/docs/getting_started#if-you-have-an-existing-remote-repository)
like:

```sh
$ echo 'export VCS_AUTHOR_EMAIL=me@example.com' >> ~/.profile.local
$ . ~/.profile.local
$ yadm clone git@github.com:dbarnett/dotfiles.git
```

Note: requires env var support in yadm 3.2.0 or later.

TODO: Fix sometimes getting stuck on vim plug installs etc and needing rerun.

### More setup

Set up SSH keys for GitHub:
https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/

### Fonts

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

### Other preferences

Set up Compose key. On Linux:

```sh
$ setxkbmap -option compose:ralt
```

GTK Theme:
gtk-chtheme (Ambiance or similar)

gnome-terminal scrolling:
Edit > Profile Preferences > Scrolling > Scrollback > 10000

## Legacy system bootstraps

The following instructions are mostly old manual setup instructions I need to
update to take advantage of yadm.

### Basic setup (OS X)

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

### For i3
Kill ugly dunst notifications:
```sh
$ sudo apt install notify-osd
$ sudo apt purge dunst
```

Tolerable launcher:
```sh
$ sudo apt remove suckless-tools 
$ sudo dpkg -i Downloads/rofi_0.15.11-4_amd64.deb  # if package isn't in dist
$ sudo ln -s /usr/bin/rofi /usr/local/bin/dmenu
```

Prevent weird Nautilus desktop window
(https://faq.i3wm.org/question/1/how-can-i-get-rid-of-the-nautilus-desktop-window.1.html).
```sh
$ gsettings set org.gnome.desktop.background show-desktop-icons false
```
