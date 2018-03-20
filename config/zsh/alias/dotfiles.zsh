editlocal(){
  FILE=${1:-alias}
  $EDITOR "${HOME}/.local/share/dotfiles/${FILE}"
}
