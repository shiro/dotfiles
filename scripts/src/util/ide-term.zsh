#!/usr/bin/env zsh

alacritty --class IDE --config-file=$HOME/.config/alacritty/ide.toml -e zsh -ic tmux
