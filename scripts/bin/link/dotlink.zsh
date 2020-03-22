#!/bin/zsh

set -e

usage(){
  cat << EOF
usage:
  dotlink FILE [FILES...]
EOF
}

[ $# -eq 0 ] && usage && exit 1

for file in "$@"; do
  [ ! -f "$file" ] && usage && exit 1
done

for file in "$@"; do
  TARGET="$file"

  [ ! -f "$TARGET" ] && usage && exit 1

  # get full path
  TARGET="$(readlink -f "$TARGET")"

  LINK_ROOT=$DOTFILES/linux/system


  if [ ! -f "$LINK_ROOT$TARGET" ]; then
    mkdir -p "$LINK_ROOT${TARGET:h}"
    sudo cp "$TARGET" "$LINK_ROOT$TARGET"
    sudo chown "`whoami`" "$LINK_ROOT$TARGET"
  else
    vim -d "$TARGET" "$LINK_ROOT$TARGET" 
  fi
done
