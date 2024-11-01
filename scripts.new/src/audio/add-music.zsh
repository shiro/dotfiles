#!/bin/zsh

MUSIC_LIB_DIR="$HOME/Music"

if [ $# -lt 1 ]; then
  echo "expected at least one file"
  exit 1
fi

filenames=($@);

# make sure all files exist
for filename in "${filenames[@]}"; do
  if [ ! -f "$filename" ]; then
    echo "file '$filename' not found"
    exit 1
  fi
done


dialog_loop(){
  filename="$1"

  play "$filename" > /dev/null && \
  player 2>/dev/null

  cat <<EOF
select action for '$filename':
  [a]dd    file to library
  [d]elete file and continue
  [s]kip   file and continue
  [q]uit   this script
EOF
  read -sk1 ans

  case "$ans" in
    a)
      add-file "$filename"
      ;;
    d)
      delete-file "$filename"
      ;;
    s)
      continue
      ;;
    q)
      exit 0
      ;;
  esac
}

add-file(){
  echo "moving '$1' to '$MUSIC_LIB_DIR'"
  mv -i "$1" "$MUSIC_LIB_DIR"
}

delete-file(){
  echo "deleting '$1'"
  if [ -f "$1" ]; then
    rm "$1"
  else
    echo "error, could not find file '$1'"
    exit 1
  fi
}

for filename in "${filenames[@]}"; do
  dialog_loop "$filename"
  echo
done
