alias vless="/usr/share/vim/vim74/macros/less.sh"
alias diff="colordiff"
alias make="colormake"
alias jdb="rlwrap jdb"

# br (broot)
if [ -f "$HOME/.config/broot/launcher/bash/br" ] ; then
  source $HOME/.config/broot/launcher/bash/br
fi
