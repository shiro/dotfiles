#!/usr/bin/zsh

SCRIPT_NAME="`basename $0`"

usage(){
  cat <<USAGE
  Usage: $SCRIPT_NAME [OPTION]... repository
    repository      destination borg repository
    -l=<LIST FILE>  specify the location file
        --help      print this message
    -n, --dry-run   do not persist backups
USAGE
}

LOCATION_FILE=~/.local/config/backup/`hostname`/system.lst
local dry_run=false

set +x

while getopts :l:n-: opt; do
  case "$opt" in
    l)
      if [ ! -f "$OPTARG" ]; then
        echo "$OPTARG: not found"
        exit 1
      fi
      LOCATION_FILE="$OPTARG"
      ;;
    n)
      dry_run=true
      ;;
    -) case "$OPTARG" in
        help)
          usage; exit 0
          ;;
        dry-run)
          dry_run=true
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

[ -z "$BORG_REPO" ] && \
  usage && \
  exit 1

[ ! -d "$BORG_REPO" ] && \
  echo "repository \"$BORG_REPO\": not a directory" && \
  exit 1

# borg will use this
export BORG_REPO
export BORG_RELOCATED_REPO_ACCESS_IS_OK=yes


# read the passphrase
if [ -z "$BORG_PASSPHRASE" ]; then
  echo -n 'Repo passphrase:'
  read -s BORG_PASSPHRASE
  export BORG_PASSPHRASE
  echo
fi


# some helpers and error handling:
info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

info "Starting backup"

args=
$dry_run && args="-n"

borg create                          \
    --patterns-from "$LOCATION_FILE" \
    --show-rc                        \
    --list \
    $args \
    ::'main-{hostname}-{now}'

backup_exit=$?

[ $dry_run ] && exit 0

info "Pruning repository"

borg prune                           \
    --list                           \
    --prefix 'main-{hostname}-'      \
    --show-rc                        \
    --keep-daily=7                   \
    --keep-weekly=4                  \
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
