#!/usr/bin/env zsh

adbfs ~/tmp/mnt > /dev/null 2>&1

SRC="$HOME"/Music
DST="$HOME"/tmp/mnt/storage/6432-6330/Music

for f in "$SRC"/*; do
  filename="$(basename "$f")"
  if [ ! -f "$DST/$filename" ]; then
    echo "[ADD] $filename"
    cp "$f" "$DST/$filename"
  fi
done

for f in "$DST"/*; do
  filename="$(basename "$f")"
  if [ ! -f "$SRC/$filename" ]; then
    echo "[REM] $filename"
    rm "$f"
  fi
done

echo "done!"
