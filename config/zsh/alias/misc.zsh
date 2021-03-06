# mischelanious commands
alias wget_website='wget -mkEpnp'
alias hosts='vim /etc/hosts'

alias lnode='PATH=$(cygpath $(npm bin)):$PATH'

# composer
alias comp='php ~/bin/composer.phar'

# tmux
alias tmux='tmux -u'

# artisan
alias art="php artisan"

# sed
alias sedr="sed -r"

# vim
rcvim(){ vim "$XDG_CONFIG_HOME/nvim/$1" }
fv(){ 
	file="$(fzf)"
	[ ! -z $file ] && vim "$file"
}

# sh function to murder all running processes matching a pattern
function killall () {
  ps ax | grep $1 | grep -v grep | awk '{print $1}' | xargs kill -9
}

# 'work on', via https://coderwall.com/p/feoi0a
function wo() {
  cd $(find $CODE_DIR -type d -maxdepth 3 | grep -i $* | grep -Ev Pods --max-count=1)
}

