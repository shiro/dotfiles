#!/bin/zsh

BACKUP_LOCATION="/mnt/hdd1/backup/`hostname`"


if [ ! -d "$BACKUP_LOCATION" ]; then
  ssh shiro@homebox [ -d "$BACKUP_LOCATION" ]
  if [ $? -eq 0 ]; then
    BACKUP_LOCATION="ssh://shiro@homebox$BACKUP_LOCATION"
  else
    echo "could not access backup location '$BACKUP_LOCATION'"
    exit 1
  fi
fi


# attempt to read passphrase from the keyring
env_passphrase="$(secret-tool lookup Title "system-backup-reference")"
if [ -n "$env_passphrase" ];then
  export BORG_PASSPHRASE="$env_passphrase"
fi


# read the passphrase
if [ -z "$BORG_PASSPHRASE" ]; then
  echo -n 'Repo passphrase:'
  read -s BORG_PASSPHRASE
  export BORG_PASSPHRASE
  echo
fi

backup --compression zlib -l system "$BACKUP_LOCATION/main" \
  --daily 3 --weekly 2 --monthly 1

local externalPhotographyPath='/mnt/hdd1/pictures/photography'
if [ -e "$externalPhotographyPath" ]; then
  backup --compression zlib -l photography "$BACKUP_LOCATION/main" \
    --daily 3 --weekly 2 --monthly 1
else
  echo "skipping 'photography' since '$externalPhotographyPath' does not exist"
fi

backup --compression zlib -l games "$BACKUP_LOCATION/main" \
  --daily 3 --weekly 2 --monthly 1

backup --compression zlib -l music "$BACKUP_LOCATION/main" \
  --daily 3 --weekly 2 --monthly 1
