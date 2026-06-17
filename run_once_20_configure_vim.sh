#!/bin/sh
# Vim/Neovim setup: vim-plug bootstrap + LSP server installs.
#
# Desired LSP servers listed as "name:filetype" below.
# Add an entry → chezmoi detects content change → re-runs this script →
# existence check skips already-installed servers, installs only new ones.
#
# Servers install to: ~/.local/share/vim-lsp-settings/servers/<name>/

LSP_SERVERS="
bash-language-server:sh
marksman:markdown
yaml-language-server:yaml
"

install_lsp_if_missing() {
  name="$1" ft="$2"
  dir="$HOME/.local/share/vim-lsp-settings/servers/$name"
  if [ ! -d "$dir" ]; then
    echo "Installing LSP server: $name" 1>&2
    vim +"set ft=$ft" +"set cmdheight=9" +"call LspInstallServerThenQuit('$name')"
  fi
}

plug_path="$HOME/.vim/autoload/plug.vim"
if [ ! -f "$plug_path" ]; then
  curl -fLo "$plug_path" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  vim +'PlugInstall --sync' +qa
fi

printf '%s\n' "$LSP_SERVERS" | grep -v '^$' | while IFS=: read -r name ft; do
  install_lsp_if_missing "$name" "$ft"
done
