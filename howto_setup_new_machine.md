# How to set up a fresh (Debian-based) system to my tastes

## Basic setup
```sh
$ sudo apt-get install $(cat ubuntu_selections)
$ sudo pypi-install pythonpy
```
Git:
```sh
$ git config --global user.name "My Name"
$ git config --global user.email myaddress@example.com
```

Also set up SSH keys for GitHub:
https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/

```sh
$ git clone git@github.com:dbarnett/dotfiles.git
$ mkdir ~/projects ~/.local/bin
$ ln -s dotfiles/bin dotfiles/.* ~/
# And download corresponding image for .fehbg
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
$ sudo apt-get install notify-osd
$ sudo apt-get purge dunst
```

Tolerable launcher:
```sh
$ sudo apt-get remove suckless-tools 
$ sudo dpkg -i Downloads/rofi_0.15.11-4_amd64.deb  # if package isn't in dist
$ sudo ln -s /usr/bin/rofi /usr/local/bin/dmenu
```

Prevent weird Nautilus desktop window
(https://faq.i3wm.org/question/1/how-can-i-get-rid-of-the-nautilus-desktop-window.1.html).
```sh
$ gsettings set org.gnome.desktop.background show-desktop-icons false
```
