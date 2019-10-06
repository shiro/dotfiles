#!/bin/zsh


DEST="${HOME}/bin"

SOURCES=(
  "$DOTFILES/scripts/bin"
)

linkFiles(){
  if [ -d "$1" ]; then
	  echo "# from: $1"
  else
	  echo "# skip $1: not found"
	  return
  fi

  local files=(`find "$1" -type f`)

  for file in ${files[@]}; do
    if [ -f "$DEST/${file:r:t}" ] && [ ! -L "$DEST/${file:r:t}"  ]; then
      echo "[SKIP] ${file:t}\nfile with the same name exists in '$DEST'"
      continue
    fi

    echo "[LINK] ${file:t}"
    ln -sf "$file" "$DEST/${file:r:t}"
  done
}


for src in "${SOURCES[@]}"; do
  linkFiles "$src"
done

