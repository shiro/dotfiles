#!/usr/bin/env zsh

class=`hyprctl activewindow | grep class: | cut -d' ' -f2`
vim_cmd="vim -c 'cd wiki'"

if [ "$class" = "Alacritty" ]; then
    tmux new-window -a $vim_cmd
else
    al $vim_cmd
fi
