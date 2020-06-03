proj(){cd "${HOME}/project/$@"}
compdef '_files -W ~/project/ -g "~/project/*"' proj

work(){cd "${HOME}/project/work/$@"}
compdef '_files -W ~/project/work/ -g "~/project/work/*"' work

alias dt='cd ~/Desktop'
alias dot="cd $DOTFILES"


codi() {
  local syntax="${1:-python}"
  shift
  vim -c \
    "let g:startify_disable_at_vimenter = 1 |\
    set bt=nofile ls=0 noru nonu nornu |\
    hi ColorColumn ctermbg=NONE |\
    hi VertSplit ctermbg=NONE |\
    hi NonText ctermfg=0 |\
    Codi $syntax" "$@"
}
