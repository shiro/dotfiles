WEASELPAGENTDIR=/mnt/c/etc/weasel-pageant

# killing old running socket
#$WEASELPAGENTDIR/weasel-pageant -k >/dev/null 2>/dev/null

eval $($WEASELPAGENTDIR/weasel-pageant -rba "/tmp/.weasel-pageant-$USER") >/dev/null 2>/dev/null
