#!/usr/bin/zsh

SCRIPT_NAME="`basename $0`"

usage(){
  cat <<USAGE
  Usage: $SCRIPT_NAME [OPTION]...
    -o=<REPO_PATH>  backup to REPO_PATH
    -c=<CONFIG>     specify the CONFIG location
        --help      print this message
USAGE
}

CONFIG_FILE=~/.local/config/backup/`hostname`/system.json


while getopts :c:o:-: opt; do
  case "$opt" in
    c)
      if [ ! -f "$OPTARG" ]; then
        echo "$OPTARG: not found"
        exit 1
      fi
      CONFIG_FILE="$OPTARG"
      ;;
    o)
      if [ ! -d "$OPTARG" ]; then
        echo "$OPTARG: not found"
        exit 1
      fi
      BORG_REPO="`realpath "$OPTARG"`"
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


# no additional arguments
[ $# -ne 0 ] && usage && exit 1


BORG_REPO=${BORG_REPO:-`jq -r '.destination' "$CONFIG_FILE"`}
LOCATION_LIST=( `jq -r '.location[]' "$CONFIG_FILE" | tr '\n' ' '` )


# borg will use this
export BORG_REPO
export BORG_RELOCATED_REPO_ACCESS_IS_OK=yes


# read the passphrase
echo -n 'Repo passphrase:'
read -s BORG_PASSPHRASE
export BORG_PASSPHRASE
echo


IFS=$'\n'
EXCLUDE_FILES=(`jq -r '.exclude.files[]' "$CONFIG_FILE"`)
EXCLUDE_PATTERNS=(`jq -r '.exclude.patterns[]' "$CONFIG_FILE"`)
unset IFS


# some helpers and error handling:
info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

info "Starting backup"

# build a dynamic param string
for i in $EXCLUDE_FILES; do paramString+="-e \"*/$i\" "; done

for i in $EXCLUDE_PATTERNS; do paramString+="-e \"$i\" "; done


echo "$paramString" | xargs \
borg create                         \
    --verbose                       \
    --list                          \
    --stats                         \
    --show-rc                       \
                                    \
    ::'main-{hostname}-{now}'       \
    "${LOCATION_LIST[@]}"

backup_exit=$?

info "Pruning repository"

borg prune                          \
    --list                          \
    --prefix 'main-{hostname}-'     \
    --show-rc                       \
    --keep-daily=7                  \
    --keep-weekly=4                 \
    --keep-monthly=1

prune_exit=$?

# use highest exit code as global exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))

if [ ${global_exit} -eq 1 ];
then
    info "Backup and/or Prune finished with a warning"
fi

if [ ${global_exit} -gt 1 ];
then
    info "Backup and/or Prune finished with an error"
fi

exit ${global_exit}
