# explorer commands
ex(){ explorer.exe /e,"$(wslpath -w "$(realpath "$1")")" }
exrc(){ ex $ZSH/alias }
extt(){ ex ~/.dotfiles/pandoc }

# mischelanious commands
rc(){ $EDITOR "$ZSH/$1" }
alias rcre='. ~/.zshrc'
alias r='/usr/bin/reset'
alias wget_website='wget -mkEpnp'
alias hosts='vim /etc/hosts'

alias lnode='PATH=$(cygpath $(npm bin)):$PATH'

# composer
alias comp='php ~/bin/composer.phar'

# tmux
alias tmux='tmux -u'

#artisan
alias art="php artisan"
# alias t="winpty"
alias sedr="sed -r"

# LaTeX
tt(){ cp ~/.dotfiles/pandoc/$1.tex $2.tex }

# Vim
rcvim(){ vim "$DOTFILES/config/nvim/$1" }


# sh function to murder all running processes matching a pattern
# function killall () {
#   ps ax --windows | grep $1 | grep -v grep | awk '{print $1}' | xargs kill -9
# }


# 'work on', via https://coderwall.com/p/feoi0a
function wo() {
  cd $(find $CODE_DIR -type d -maxdepth 3 | grep -i $* | grep -Ev Pods --max-count=1)
}

# lnenable(){ export CYGWIN="winsymlinks:nativestrict" }
