# How to set up a fresh system to my tastes

This dotfiles config is applied using [yadm](https://yadm.io/).
[Install it](https://yadm.io/docs/install) and then [activate
it](https://yadm.io/docs/getting_started#if-you-have-an-existing-remote-repository)
like:

```sh
$ echo 'export VCS_AUTHOR_EMAIL=me@example.com' >> ~/.profile
$ $(tail -n 1 ~/.profile)
$ yadm clone git@github.com:dbarnett/dotfiles.git
```

Note: requires env var support in yadm 3.2.0 or later.

The following instructions are mostly old manual setup instructions I need to
update to take advantage of yadm.

## Basic setup (OS X)

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

## More setup

Set up SSH keys for GitHub:
https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/

```sh
$ (cd ~/Downloads && wget https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Black_Holes_-_Monsters_in_Space.jpg/1280px-Black_Holes_-_Monsters_in_Space.jpg)
```

## Other preferences
Keyboard settings:
```sh
$ setxkbmap -option compose:ralt
```

GTK Theme:
gtk-chtheme (Ambiance or similar)

gnome-terminal scrolling:
Edit > Profile Preferences > Scrolling > Scrollback > 10000

## For i3
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
