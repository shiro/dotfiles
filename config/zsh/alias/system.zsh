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
alias se='sudo -e'

# less shutting down remote servers
alias stahp='poweroff'

alias whatismyip='curl ifconfig.me'

# copy/move using rsync
alias cs='rsync -a --progress'
function ms(){
  rsync -a --progress --remove-source-files "$1" "$2" && \
  find "$1" -depth -type d -empty -exec rmdir "{}" \;
}
