#!/usr/bin/env zsh

export MPD_HOST="$HOME/.config/mpd/socket"

command="$1"
shift

has-track() {
  [[ `mpc current` != "" ]]
}

# Library mode: normal queue behaviour with ashuffle refilling it.
# Stop ashuffle while rebuilding the queue (it refills on clear), then start it again.
library-mode() {
  systemctl --user stop ashuffle.service 2>/dev/null || true
  mpc -q consume off
  mpc -q single off
  mpc -q repeat off
  mpc -q clear
  for item in "$@"; do
    # Fall back to a file:// URI for files not yet in the MPD database.
    mpc -q add "$item" 2>/dev/null || mpc -q add "file://$HOME/Music/$item"
  done
}

start-shuffle() {
  systemctl --user start ashuffle.service
}

reload-library() {
  library-mode /
  mpc -q shuffle
  start-shuffle
}

case "$command" in
  play)
    mpc play
    ;;
  pause)
    mpc pause
    ;;
  playpause | toggle)
    mpc toggle
    ;;
  next)
    mpc next || (reload-library && mpc play)
    ;;
  prev)
    mpc prev || (reload-library && mpc play)
    ;;
  forward)
    mpc seek '+00:00:05'
    ;;
  backward)
    mpc seek '-00:00:05'
    ;;
  volume-up)
    mpc volume '+5'
    ;;
  volume-down)
    mpc volume '-5'
    ;;
  library)
    selected=`ls ~/Music | shuf | rofi -dmenu -i`
    if [ -n "$selected" ]; then
      # Paths are relative to the MPD music directory (~/Music); ashuffle continues after it.
      library-mode "$selected"
      mpc -q play
      start-shuffle
    fi
    ;;
  ui)
    ncmpcpp
    ;;
esac

