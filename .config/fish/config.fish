if status is-interactive
  type -q direnv; and direnv hook fish | source
  type -q starship; and starship init fish | source
end
