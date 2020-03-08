#!/bin/zsh

setopt nullglob


SCRIPT_NAME="`basename $0`"

usage(){
  cat <<USAGE
Usage: $SCRIPT_NAME BORG_REPO_PATH
USAGE
}

LOCATION_FILE=~/.local/config/backup/`hostname`/system.lst

set +x

while getopts :l:-: opt; do
  case "$opt" in
    -) case "$OPTARG" in
        help)
          usage; exit 0
          ;;
        *)
          usage; exit 1
          ;;
      esac;;
    :|\?)
      usage; exit 1
      ;;
  esac
done
shift $((OPTIND-1))

# accept 1 arg
[ $# -ne 1 ] && usage && exit 1

BORG_REPO="$1"
shift 1

export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes
export BORG_RELOCATED_REPO_ACCESS_IS_OK=yes

# validate input
[ ! -d "$BORG_REPO" ] && echo "borg repo \"$BORG_REPO\" could not be found" && exit 1

#BACKUP_NAME="`borg list --format '{name}' "$BORG_REPO" | fzf`"
BACKUP_NAME="`borg list --format '{name}' "$BORG_REPO"`"


dialog_loop(){
  cat <<EOF
backup restore utility script options:
  [d]ump    file list to listfile
  [e]xtract files from listfile
  [m]odify  listfile
  [q]uit
EOF

  read -sk1 ans

  case "$ans" in
    d)
      dump_filelist
      ;;
    e)
      extract_files
      ;;
    m)
      modify_listfile
      ;;
    q)
      exit 0
      ;;
  esac
}

select_listfile(){
  cat <<EOF
where is the listfile?
  [s]elect from current directory
  [i]nput a path
EOF
  read -sk1 ans
  case "$ans" in
    s)
      local selection=(*.lst)

      [ ${#selection[@]} -eq 0 ] && \
        echo "no listfiles in the current directory" && \
        return 1

      listfile="`printf '%s\n' "${selection[@]}" | fzf`"
      ;;
    i)
      read "?listfile path: " listfile

      [ -n "$listfile" ] && [[ "$listfile" != *.lst ]] && \
        listfile="$listfile.lst"

      [ ! -f "$listfile" ] && \
        echo "not such file: \"$listfile\"" && \
        return 1
      ;;
  esac
}


modify_listfile(){
  eval select_listfile || return

  vim "$listfile" || return

  echo "saved changes"
}


dump_filelist(){
  read "?listfile name: ($BACKUP_NAME.lst) " listfile_destination

  [ -z "$listfile_destination" ] && \
    listfile_destination="$BACKUP_NAME.lst"

  [[ "$listfile_destination" != *.lst ]] && \
    listfile_destination="$listfile_destination.lst"

  echo "dumping to \"$listfile_destination\""

  file_list=("${(@f)$(borg list --format '{bpath}{LF}' "$BORG_REPO::$BACKUP_NAME")}")
  borg list --format '{bpath}{LF}' "$BORG_REPO::$BACKUP_NAME" \
    | sed -e 's/^/# /' \
    > "$listfile_destination"

  echo "listfile created"
}


extract_files(){
  eval select_listfile || return

  read -sk1 "?edit listfile in memory? [y/n] " ans
  echo

  if [[ $ans =~ [Yy] ]]; then
    local tmp_listfile="/tmp/restore-backup.lst.tmp"

    vim -c "sav! $tmp_listfile" "$listfile" || return

    listfile="$tmp_listfile"
  fi

  echo "restoring from \"$listfile\""

  sed "$listfile" \
    -e '/^#/d' \
    -e 's/^ //g' \
    | xargs -d '\n' \
    borg extract "$BORG_REPO::$BACKUP_NAME"

  echo "restored successfully"
}



while true; do
  dialog_loop
  echo
done
