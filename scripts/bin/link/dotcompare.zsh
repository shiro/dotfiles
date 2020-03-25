#!/bin/zsh

usage(){
  cat << EOF
usage:
  dotcompare [FILE]

description:
  Perform a diff between the system and the dotfiles file copies.
  Lists all modified files when FILE is not specified.
EOF
}

LINK_ROOT=$DOTFILES/linux/system

# list changed files mode
if [ $# -eq 0 ]; then
  while read TARGET; do
    [ ! -f "$TARGET" ] && echo "file '$TARGET' only exists in dotfiles" && continue

    changes="$(diff -y --suppress-common-lines "$TARGET" "$LINK_ROOT$TARGET")"
    is_same=$?
    changes=$(echo "$changes" | wc -l)

    if [ $is_same -eq 1 ]; then
      echo "$TARGET: $changes"
    fi

  done < <(find "$DOTFILES/linux/system" -type f | sed -r "s|^$LINK_ROOT(.*)|\\1|")

  exit 0
fi


# compare 2 files mode

[ $# -ne 1 ] && usage && exit 1

[ ! -f "$1" ] && echo "cannot access '$1': no such file" && exit 1

TARGET="$(readlink -f "$1")"
TARGET="${TARGET#"$LINK_ROOT"}"


[ ! -f "$TARGET" ]           && echo "cannot access '$TARGET': no such file"            && exit 1
[ ! -f "$LINK_ROOT$TARGET" ] && echo "cannot access '$LINK_ROOT$TARGET': no such file"  && exit 1


if ! diff "$TARGET" "$LINK_ROOT$TARGET" > /dev/null; then
  sudo -E vim -d "$TARGET" "$LINK_ROOT$TARGET"
fi
