# Manually register script individually since argcomplete doesn't seem to
# support automatic global activation yet for fish shell.
set -l cmdname (basename (status -f) .fish)
if type -q register-python-argcomplete
  register-python-argcomplete --shell fish {$cmdname} \
    | source
end
