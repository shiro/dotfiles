#!/bin/zsh

set -e

usage(){
  cat << EOF
usage:
  dotunlink FILE [FILES...]
EOF
}

[ $# -eq 0 ] && usage && exit 1

for file in "$@"; do
  [ ! -f "$file" ] && usage && exit 1
done

for file in "$@"; do
  TARGET="$file"

  # get full path
  TARGET="$(readlink -f "$TARGET")"

  LINK_ROOT=$DOTFILES/linux/system


  [ ! -f "$LINK_ROOT$TARGET" ] && continue

  rm "$LINK_ROOT$TARGET"
  find "$LINK_ROOT" -type d -empty -delete
done
