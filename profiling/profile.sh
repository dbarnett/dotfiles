#!/bin/sh
if [ -z "$1" ]; then
  echo "Usage: profile.sh {SYSTEM_NAME}"
  exit 1
fi
PROFILE_PATH="$(dirname "$0")"
SYSTEM_NAME="$1"

echo "Profiling vim startup time..."
logpath="$PROFILE_PATH/vim_startuptime/${SYSTEM_NAME}.log"
rm -f $logpath
vim --startuptime $logpath +qall

echo "Profiling nvim startup time..."
logpath="$PROFILE_PATH/nvim_startuptime/${SYSTEM_NAME}.log"
rm -f $logpath
nvim --startuptime $logpath +qall
