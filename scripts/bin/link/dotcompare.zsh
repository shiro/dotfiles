#!/bin/zsh

set -e

usage(){
  cat << EOF
usage:
  dotcompare FILE

description:
  Perform a diff between the system and the dotfiles file copies.
EOF
}

[ $# -ne 1 ] && usage && exit 1

LINK_ROOT=$DOTFILES/linux/system

[ ! -f "$1" ] && echo "cannot access '$1': no such file" && exit 1

TARGET="$(readlink -f "$1")"
TARGET="${TARGET#"$LINK_ROOT"}"


[ ! -f "$TARGET" ]           && echo "cannot access '$TARGET': no such file"           && exit 1
[ ! -f "$LINK_ROOT$TARGET" ] && echo "cannot access'$LINK_ROOT$TARGET': no such file"  && exit 1


if ! diff "$TARGET" "$LINK_ROOT$TARGET" > /dev/null; then
  sudo -E vim -d "$TARGET" "$LINK_ROOT$TARGET"
fi
