#!/usr/bin/env zsh

if [ $# -eq 0 ]; then
  alacritty
else
  # remove ignore -e flag since it's the default
  [[ $1 == "-e" ]] && shift

  alacritty -e zsh -ic -c "$*"
fi
