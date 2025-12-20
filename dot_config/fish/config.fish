if status is-interactive
  # Requires foreign-env: https://github.com/oh-my-fish/plugin-foreign-env
  # Context: https://superuser.com/questions/446925/re-use-profile-for-fish
  fenv source ~/.profile
  # Deduplicate $PATH
  set -l old_path $PATH
  set -e PATH[1..]
  for p in $old_path
    fish_add_path --path --append $p
  end

  # MacOS stuff
  type -q /opt/homebrew/bin/brew; and /opt/homebrew/bin/brew shellenv | source
  test -e {$HOME}/.iterm2_shell_integration.fish; and source {$HOME}/.iterm2_shell_integration.fish

  type -q direnv; and direnv hook fish | source
  type -q pyenv; and pyenv init - | source
  type -q starship; and starship init fish | source

  if type -q keychain
    # Override $SHELL for fish-shell/fish-shell#4583.
    set -lx SHELL fish
    eval (keychain --eval id_ed25519 --quiet)
  end
end

# Set NVM_DIR if not already set
set -q NVM_DIR; or set -gx NVM_DIR ~/.nvm

# Configure fish-nvm to use standard nvm location
set -gx nvm_data $NVM_DIR/versions/node

# Platform-specific paths
if test (uname) = Darwin
  # macOS
  set -l PNPM_HOME "$HOME/Library/pnpm"
else
  # Linux
  set -l PNPM_HOME "$HOME/.local/share/pnpm"
end

# pnpm
if test -d $PNPM_HOME
  set -gx PNPM_HOME $PNPM_HOME
  if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
  end
end
# pnpm end
