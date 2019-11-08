proj(){cd "${HOME}/project/$@"}
compdef '_files -W ~/project/ -g "~/project/*"' proj

work(){cd "${HOME}/project/work/$@"}
compdef '_files -W ~/project/work/ -g "~/project/work/*"' work

alias dt='cd ~/Desktop'
alias dot="cd $DOTFILES"
