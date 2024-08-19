if status is-interactive
  # Requires foreign-env: https://github.com/oh-my-fish/plugin-foreign-env
  # Context: https://superuser.com/questions/446925/re-use-profile-for-fish
  fenv source ~/.profile

  type -q direnv; and direnv hook fish | source
  type -q starship; and starship init fish | source
end
