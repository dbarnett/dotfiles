if status is-interactive
  # Requires foreign-env: https://github.com/oh-my-fish/plugin-foreign-env
  # Context: https://superuser.com/questions/446925/re-use-profile-for-fish
  fenv source ~/.profile
  # Deduplicate $PATH, re-adding each item from tail to head.
  set -l old_path $PATH
  set -e PATH
  for p in $old_path[-1..1]
    fish_add_path --path $p
  end

  type -q direnv; and direnv hook fish | source
  type -q pyenv; and pyenv init - | source
  type -q starship; and starship init fish | source

  if type -q keychain
    # Override $SHELL for fish-shell/fish-shell#4583.
    set -lx SHELL fish
    eval (keychain --eval --agents ssh --quiet)
  end
end
