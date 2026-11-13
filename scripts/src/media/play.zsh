#!/usr/bin/env zsh

set -e

export MPD_HOST="$HOME/.config/mpd/socket"

if [ $# -eq 0 ]; then
  >&2 echo "error, need at least one argument, but got $#"
  exit 1
fi

# Local-socket MPD clients can play files outside the music directory via file:// URIs.
uri() { print -r -- "file://$(realpath "$1")" }

# Stop the library shuffler first, otherwise it refills the queue as soon as it's cleared.
systemctl --user stop ashuffle.service 2>/dev/null || true

# Replace the queue with the given file(s) and play them through once.
# consume: each track is removed from the queue once it has played, so the queue ends up empty.
mpc -q repeat off
mpc -q random off
mpc -q single off
mpc -q consume on
mpc -q clear
for f in "$@"; do
  mpc -q add "$(uri "$f")"
done

mpc -q play
