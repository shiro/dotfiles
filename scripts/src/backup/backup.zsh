#!/usr/bin/env zsh

SCRIPT_NAME="`basename $0`"

usage(){
  cat <<USAGE
  Usage: $SCRIPT_NAME [OPTION]... -l LOCATION_FILE REPOSITORY
    REPOSITORY      destination borg repository

  Options:
    --help          print this message


    -l LOCATION_FILE
                    specify the location file

    -n, --dry-run   do not persist backups

    --name BACKUP_NAME
                    backup name

    --daily DAILY
                    the daily updates to keep
    --weekly WEEKLY
                    the weekly updates to keep
    --monthly MONTHLY
                    the montly updates to keep
    --last BACKUP_COUNT
                    the amount of backups to keep

    --no-backup     skip the backup step
    --no-prune      skip the prune step

    --compression COMPRESSION
                    the compression to use
USAGE
}

DEFAULT_LOCATION_DIR="$HOME/.local/config/backup/`hostname`"

local location_file
local backup_name
local dry_run

local keep_daily
local keep_weekly
local keep_monthly
local keep_last

local compression


set +x

SHORT=l:n
LONG=help,dry-run,no-prune,no-backup,last:,daily:,weekly:,monthly:,name:,compression:

OPTS=$(getopt --options $SHORT --long $LONG --name "$0" -- "$@")

[ $? != 0 ] && exit 1;

eval set -- "$OPTS"

while true ; do
  case "$1" in
    -l )
      if [ -f "$2" ]; then
        location_file="$2"
      elif [ -f "$DEFAULT_LOCATION_DIR/$2" ]; then
        location_file="$DEFAULT_LOCATION_DIR/$2"
      else
        echo "$2: not found"
        exit 1
      fi

      if [ -z $backup_name ]; then
        backup_name="`basename "$location_file"`"
      fi

      shift 2
      ;;
    -n | --dry-run )
      dry_run=1
      no_prune=1
      shift
      ;;
    --name )
      backup_name="$2"
      shift 2
      ;;
    --last )
      keep_last=$2
      shift 2
      ;;
    --daily )
      keep_daily=$2
      shift 2
      ;;
    --weekly )
      keep_weekly=$2
      shift 2
      ;;
    --monthly )
      keep_monthly=$2
      shift 2
      ;;
    --last )
      keep_last=$2
      shift 2
      ;;
    --no-backup )
      no_backup=1
      shift
      ;;
    --no-prune )
      no_prune=1
      shift
      ;;
    --compression )
      compression=$2
      shift 2
      ;;
    --help )
      usage; exit 0
      ;;
    -- )
      shift
      break
      ;;
    *)
      echo "Internal error!"
      exit 1
      ;;
  esac
done


# check parameter validity
[ $# -ne 1 ] && usage && exit 1

BORG_REPO=${1:-BORG_REPO}
shift 1

[ -z "$BORG_REPO" ] && \
  usage && \
  exit 1

if [ ! -d "$BORG_REPO" ] && [[ "$BORG_REPO" != 'ssh://'* ]]; then
  echo "repository \"$BORG_REPO\": not a directory"
  exit 1
fi

[ ! -f "$location_file" ] && \
  echo "no location file provided" && \
  exit 1

# initialize variables
[ -z $backup_name ] && \
  backup_name="`basename "$location_file"`"


if [ ! $keep_daily ] && [ ! $keep_weekly ] && [ ! $keep_monthly ] && [ ! $keep_last ]; then
  no_prune=1
fi

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

backup(){
  info "Starting backup"

  args=()
  [ $dry_run ] && args+="--dry-run"
  [ "$compression" ] && args+=("-C" "$compression")

  borg create                          \
      --patterns-from "$location_file" \
      --show-rc                        \
      --list                           \
      --exclude-caches                 \
      --exclude-if-present .nobackup   \
      ${args[@]}                       \
      ::"{hostname}-$backup_name-{now}"
}

prune(){
  info "Pruning repository"

  args=()
  [ $keep_daily ] && args+="--keep-daily $keep_daily"
  [ $keep_weekly ] && args+="--keep-weekly $keep_weekly"
  [ $keep_monthly ] && args+="--keep-monthly $keep_monthly"
  [ $keep_last ] && args+="--keep-last $keep_last"
  [ $dry_run ] && args+="--dry-run"

  borg prune                                  \
      --list                                  \
      --prefix "{hostname}-$backup_name" \
      --show-rc                               \
      ${=args[@]}
}

if [ -z $no_backup ]; then
  backup
  backup_exit=$?
fi

if [ -z $no_prune ]; then
  prune
  prune_exit=$?
fi

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
