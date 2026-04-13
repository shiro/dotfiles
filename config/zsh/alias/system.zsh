# add self to one or more groups
enlist () {
  for group in $@; do
    sudo gpasswd -a $USER $group
  done
}

# remove self from one or more groups
resign () {
  for group in $@; do
    sudo gpasswd -d $USER $group
  done
}

# sudo repeat last command
alias please='sudo $(fc -ln -1)'

# sudo
alias se='sudo -E'

# less shutting down remote servers
alias stahp='poweroff'

alias whatismyip='curl ifconfig.me'

alias journal='journalctl -e'

# copy/move using rsync
alias cs='rsync -a --progress'
function ms(){
  rsync -a --progress --remove-source-files "$1" "$2" && \
  find "$1" -depth -type d -empty -exec rmdir "{}" \;
}

# reset permissions and groups
function rmchmod() {
  for target in "$@"; do
    if [ -d "$target" ]; then
      { chown -R $USER "$target" || sudo chown -R $USER "$target"; } 2>/dev/null
      { chgrp -R $USER "$target" || chgrp -R users "$target" || sudo chgrp -R $USER "$target" || sudo chgrp -R users "$target"; } 2>/dev/null
      { chmod -R u=rwX,go=rX "$target" || sudo chmod -R u=rwX,go=rX "$target"; } 2>/dev/null
    else
      { chown $USER "$target" || sudo chown $USER "$target"; } 2>/dev/null
      { chgrp $USER "$target" || chgrp users "$target" || sudo chgrp $USER "$target" || sudo chgrp users "$target"; } 2>/dev/null
      { chmod u=rw,go=r "$target" || sudo chmod u=rw,go=r "$target"; } 2>/dev/null
    fi
  done
}

function ifzsh(){
  BIND_INTERFACE="$1" LD_PRELOAD=/usr/lib/bindtointerface.so zsh
}
