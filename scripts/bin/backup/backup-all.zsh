#!/bin/zsh

BACKUP_LOCATION="/mnt/hdd1/backup/`hostname`"


# read the passphrase
if [ -z "$BORG_PASSPHRASE" ]; then
  echo -n 'Repo passphrase:'
  read -s BORG_PASSPHRASE
  export BORG_PASSPHRASE
  echo
fi

backup --compression zlib -l system "$BACKUP_LOCATION/system" --keep-monthly 1
backup --compression zlib -l games "$BACKUP_LOCATION/games" --keep-monthly 1
backup --compression zlib -l photography "$BACKUP_LOCATION/photography" --keep-monthly 1
