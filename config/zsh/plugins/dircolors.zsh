#!/bin/zsh

[ -f "$HOME/.config/zsh/dircolors" ] && \
  eval "$(dircolors "$HOME/.config/zsh/dircolors")" || echo noo
