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

