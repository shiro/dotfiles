#!/bin/zsh

SCRIPT_NAME="`basename $0`"

usage(){
  cat <<USAGE
  Usage: $SCRIPT_NAME
USAGE
}

LOCATION_FILE=~/.local/config/backup/`hostname`/system.lst

set +x

while getopts :l:-: opt; do
  case "$opt" in
    l)
      if [ ! -f "$OPTARG" ]; then
        echo "$OPTARG: not found"
        exit 1
      fi
      LOCATION_FILE="$OPTARG"
      ;;
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

[ $# -ne 1 ] && usage && exit 1

BORG_REPO=${1:-BORG_REPO}
shift 1


