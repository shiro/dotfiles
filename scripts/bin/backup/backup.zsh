#!/usr/bin/zsh

SCRIPT_NAME="`basename $0`"

usage(){
  cat <<USAGE
  Usage: $SCRIPT_NAME [OPTION]... -l LOCATION_FILE REPOSITORY
    REPOSITORY      destination borg repository

    options:
    --help          print this message


    -l LOCATION_FILE
                    specify the location file

    -n, --dry-run   do not persist backups

    --name BACKUP_NAME
                    backup name

    --keep-daily DAILY
                    the daily update to keep
    --keep-weekly WEEKLY
                    the weekly update to keep
    --keep-monthly MONTHLY
                    the montly update to keep

    --no-backup     skip the backup step
    --no-prune      skip the prune step
USAGE
}

DEFAULT_LOCATION_DIR="$HOME/.local/config/backup/`hostname`"

local location_file=
local backup_name=
local dry_run=false
local keep_daily=7
local keep_weekly=4
local keep_monthly=1

set +x

while getopts :l:n-: opt; do
  case "$opt" in
    l)
      if [ -f "$OPTARG" ]; then
        location_file="$OPTARG"
      elif [ -f "$DEFAULT_LOCATION_DIR/$OPTARG" ]; then
        location_file="$DEFAULT_LOCATION_DIR/$OPTARG"
      else
        echo "$OPTARG: not found"
        exit 1
      fi
      if [ -z $backup_name ]; then
        backup_name="`basename "$location_file"`"
      fi
      ;;
    n)
      dry_run=true
      ;;
    -) case "$OPTARG" in
        help)
          usage; exit 0
          ;;
        name)
          backup_name="$1"
          shift
          ;;
        dry-run)
          dry_run=true
          no_prune=true
          ;;
        keep-daily)
          keep_daily=$1
          shift
          ;;
        keep-weekly)
          keep_weekly=$1
          shift
          ;;
        keep-montly)
          keep_monthly=$1
          shift
          ;;
        no-backup)
          no_backup=true
          ;;
        no-prune)
          no_prune=true
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

# check parameter validity
[ $# -ne 1 ] && usage && exit 1

BORG_REPO=${1:-BORG_REPO}
shift 1

[ -z "$BORG_REPO" ] && \
  usage && \
  exit 1

[ ! -d "$BORG_REPO" ] && \
  echo "repository \"$BORG_REPO\": not a directory" && \
  exit 1

[ ! -f "$location_file" ] && \
  echo "no location file provided" && \
  exit 1

# initialize variables
[ -z $backup_name ] && \
  backup_name="`basename "$location_file"`"

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

  args=
  $dry_run && args="-n"

  borg create                          \
      --patterns-from "$location_file" \
      --show-rc                        \
      --list \
      $args \
      ::"main-{hostname}-{now}-${name}"

  [ $dry_run ] && exit 0
}

prune(){
  info "Pruning repository"

  borg prune                           \
      --list                           \
      --prefix 'main-{hostname}-'      \
      --show-rc                        \
      --keep-daily=7                   \
      --keep-weekly=4                  \
      --keep-monthly=1
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
