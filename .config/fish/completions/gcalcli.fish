# Manually register script individually since argcomplete doesn't seem to
# support automatic global activation yet for fish shell.
if type -q register-python-argcomplete
  register-python-argcomplete --shell fish gcalcli \
    | source
end
