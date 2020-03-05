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

# less shutting down remote servers
alias stahp='poweroff'

alias whatismyip='curl ifconfig.me'

alias note=xournalpp
