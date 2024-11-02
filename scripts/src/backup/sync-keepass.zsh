#!/usr/bin/env bash


# Important note:
# If you don't synchronize but then edit the other file,
# the newer modification time on the second file edited
# will cause data to be overridden.
# The solution would be to merge manually
# (Database --> Merge from database).


#####################
##  Configuration  ##
#####################

# Name of your remote storage as defined in Rclone
DRIVE_NAME="google-drive"

# Name and locations of the passwords file
DB_FILE_NAME="cache.dat"
LOCAL_LOCATION="$HOME/Documents"
REMOTE_LOCATION="tmp"

#####################


# Compose full path to local and remote database files
LOCAL_PATH="$LOCAL_LOCATION/$DB_FILE_NAME"
REMOTE_PATH="$REMOTE_LOCATION/$DB_FILE_NAME"

# Alias import and export commands and make them available within the functions
alias passwords_export="rclone copy $LOCAL_PATH $DRIVE_NAME:$REMOTE_LOCATION"
alias passwords_import="rclone copy $DRIVE_NAME:$REMOTE_PATH $LOCAL_LOCATION"
shopt -s expand_aliases

function format_datetime_from_string ()
{
	echo `date -d "$1" +"%F %T.%3N"`
}

# Parse local passwords file modification time using the stat command
function get_local_passwords_mtime ()
{
        local string=`stat -c %y $LOCAL_PATH | cut -d ' ' -f 1,2;`
	echo `format_datetime_from_string "$string"`
}

# Parse remote passwords file modification time using Rclone's lsl command
# See: https://rclone.org/commands/rclone_lsl/
function get_remote_passwords_mtime ()
{
	output=`rclone lsl $DRIVE_NAME:$REMOTE_PATH 2>/dev/null`
	if [ $? -eq 3 ]; then
		unset output
		return 1
	else
        	local string=`echo "$output" | tr -s ' ' | cut -d ' ' -f 3,4;`
		echo `format_datetime_from_string "$string"`
		unset output
		return 0
	fi

}

function sync_passwords ()
{

	# Storing the values so they can be used for printing and then conversion
        local human_readable_local_mtime=`get_local_passwords_mtime`
        human_readable_remote_mtime=`get_remote_passwords_mtime 2>/dev/null`

	# In case there is no remote yet
	if [ $? -ne 0 ]; then
		printf "No remote passwords database found!\n"
		printf "Exporting...\t"
		passwords_export
		printf "Done!\n"
		return 0
	fi

	# Printing modification times to the user
        printf "Local passwords file modification time:\t\t$human_readable_local_mtime\n"
        printf "Remote passwords file modification time:\t$human_readable_remote_mtime\n"

	# The conversion is required for the comparison in the following if statement
        local_mtime_in_seconds_since_epoch=$(date -d "$human_readable_local_mtime" +%s)
        remote_mtime_in_seconds_since_epoch=$(date -d "$human_readable_remote_mtime" +%s)
	unset human_readable_remote_mtime

        # Handle local being newer than remote
        if [ "$local_mtime_in_seconds_since_epoch" -gt "$remote_mtime_in_seconds_since_epoch" ]; then
                printf "Local passwords file found to be newer than remote!\n"
                printf "Exporting...\t"
                passwords_export
                printf "Done!\n"
		return 0

        # Handle remote being newer than local
        elif [ "$local_mtime_in_seconds_since_epoch" -lt "$remote_mtime_in_seconds_since_epoch" ]; then
                printf "Local passwords file found to be older than remote!\n"
                printf "Importing...\t"
                passwords_import
                printf "Done!\n"
		return 0

        else
                printf "Password files are synchronized.\n"
		return 0
        fi
}

sync_passwords
