# ensure vim style cursor
function zle-keymap-select zle-line-init zle-line-finish {
  if [ $KEYMAP = vicmd ]; then
    # the command mode for vi
    echo -ne "\e[2 q"
  else
    # the insert mode for vi
    echo -ne "\e[4 q"
  fi

  zle reset-prompt
  zle -R
}

# register the keymaps
zle -N zle-line-init
zle -N zle-line-finish
zle -N zle-keymap-select
