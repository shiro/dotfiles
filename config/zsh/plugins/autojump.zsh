#!/bin/zsh

[ -f /etc/profile.d/autojump.zsh ] && { \
  source /etc/profile.d/autojump.zsh

  # fzf integration
  j(){
    [[ -n "$@" ]] && query="-q $@"

    cd "$(cat ~/.local/share/autojump/autojump.txt | sort -nr | awk -F "\\t" "{print \$NF}" | fzf +s $query )"
  }
}

