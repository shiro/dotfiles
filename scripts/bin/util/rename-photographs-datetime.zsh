#!/bin/zsh
# author: shiro <shiro@usagi.io>
#
# this script renames raw photos and their associated xmp files
# the format is unique and consists of the file creation time and
# a unique identifier created from the file's content's hash

# usage:
#   SCRIPT_NAME FILE [File...]
#
# FILE - raw or xmp files to rename


# construct a unique with format: '{original_date}-{uid}'
# uid is constructed by using the first part of the raw file (without EXIF) md5 value
get_new_filename() {
  md5="$(exiftool "$1"  -all= -o - 2>/dev/null | md5sum | cut -d' ' -f1)"
  uid="${md5:0:5}"

  original_date="$(exiftool -s3 -d "%Y-%m-%d_%Hh%Mm%S" -DateTimeOriginal "$1")"

  echo "$original_date-$uid"
}

rename_file() {
  echo "$1 -> $2"
  mv "$1" "$2"
}

process_xmp() {
  file="$1"

  local base_path="${file:h}" # file path without filename
  local raw_file="${file:r}" # raw file name including extension
  local xmp_ext="${file:e}"
  local raw_ext="${raw_file:e}"

  if [ ! -f "$raw_file" ]; then
    echo "warning: no matching raw file found for xmp '$file'"
    echo
    continue
  fi

  local new_filename="$(get_new_filename "$raw_file")"

  rename_file "$file" "$base_path/$new_filename.$raw_ext.$xmp_ext"
}


# process xmp files
for file in "$@"; do
  [ ! -f "$file" ] || \
  [[ ! ${file:t:e:l} == "xmp" ]] && continue

  process_xmp "$file"

  echo
done


# process raw files
for file in "$@"; do
  [ ! -f "$file" ] && continue

  [[ ${file:t:e:l} == "xmp" ]] && continue

  local base_path="${file:h}" # file path without filename
  local raw_file="$file" # raw file name including extension
  local raw_ext="${raw_file:e}"


  # make sure there's no xmp belonging to the file with an old name
  # since it would be impossible to associate it again
  local xmp_file="$(find "$base_path" -maxdepth 1 -name "${raw_file:t:r}.*" | grep -Pi 'xmp$')"

  if [ -n "$xmp_file" ]; then
    echo "warning: found xmp file belonging to raw, renaming it also"
    process_xmp "$xmp_file"
  fi

  local new_filename="$(get_new_filename "$raw_file")"
  rename_file "$file" "$base_path/$new_filename.$raw_ext"

  echo
done
