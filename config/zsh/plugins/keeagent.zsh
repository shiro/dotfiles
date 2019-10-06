WEASELPAGENTDIR=/mnt/c/etc/weasel-pageant

local keepass-init(){
  eval $($WEASELPAGENTDIR/weasel-pageant -rba "/tmp/.weasel-pageant-$USER") >/dev/null 2>/dev/null
}

# killing old running socket
keepass(){
  $WEASELPAGENTDIR/weasel-pageant -k >/dev/null 2>/dev/null
  rm "/tmp/.weasel-pageant-$USER" 2>/dev/null

  keepass-init
}

keepass-init
