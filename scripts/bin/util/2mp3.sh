#!/bin/sh

SCRIPT_NAME="`basename "$0"`"

usage(){
  cat << EOF
usage: $SCRIPT_NAME [INPUT FILES...]
EOF
}


if [ $# == 0 ]; then
  usage && exit 1
fi


for inputFile in "$@"; do
  inputFileBase=${inputFile%.*}


  ffmpeg -i "$inputFile" \
    -ab 320k \
    -acodec libmp3lame \
    -f mp3 \
    "$inputFileBase.mp3"
done
