#!/usr/bin/env zsh

class=`hyprctl activewindow | grep class: | cut -d' ' -f2`
vim_cmd="cd wiki && vim"

if [ "$class" = "Alacritty" ]; then
    tmux new-window -a $vim_cmd
else
    al $vim_cmd
fi
