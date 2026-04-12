#!/usr/bin/env zsh

set -e

export MPD_HOST="$HOME/.config/mpd/socket"

if [ $# -eq 0 ]; then
  >&2 echo "error, need at least one argument, but got $#"
  exit 1
fi

# first insert first file and remove all others from the list
mpc insert "$(realpath $1)"
mpc next
mpc crop
shift

# then insert all the rest after
while [ "$#" -gt 0 ]; do
  mpc add "$(realpath "$1")"
  shift
done

mpc play
