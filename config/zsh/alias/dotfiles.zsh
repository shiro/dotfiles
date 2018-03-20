rc(){ $EDITOR "${ZDOTDIR}/$1" }

# reload rc
alias rcre=". ${ZDOTDIR}/.zshrc"

editlocal(){
  FILE=${1:-alias}
  $EDITOR "${HOME}/.local/share/dotfiles/${FILE}"
}
