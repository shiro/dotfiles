command_exists() {
    type "$1" > /dev/null 2>&1
}


[ -d ~/bin ] && export PATH=~/bin:$PATH


# WSL nice workaround
unsetopt BG_NICE


# load zit, the plugin manager
source ${ZDOTDIR}/plugins/zit.zsh
export ZIT_MODULES_PATH="${HOME}/.local/share/zit-modules"

# enable 256 color terminal
[ -z "$TMUX" ] && export TERM=xterm-256color

configs=(
	${ZDOTDIR}/*.zsh
	${ZDOTDIR}/alias/*
	${ZDOTDIR}/functions/*.zsh
	${ZDOTDIR}/completions/*.zsh
	${ZDOTDIR}/key-bindings/*.zsh
	${ZDOTDIR}/plugins/*
)

# source all .zsh files inside of the zsh/ directory
for config in "${configs[@]}"; do
	source $config;
done
 

# additional plugins
zit-in "https://github.com/knu/zsh-manydots-magic" "zsh-manydots-magic"
zit-lo "zsh-manydots-magic" "manydots-magic"

zit-in "https://github.com/m45t3r/zit" "zit"


# autoload colors && colors


# load local settings
[ -f ~/.local/share/dotfiles/zshrc ] && source ~/.local/share/dotfiles/zshrc
[ -f ~/.local/share/dotfiles/alias ] && source ~/.local/share/dotfiles/alias


# compile everything so it loads faster
[ -z $ZSH_NO_COMPILE ] && zit-lo "zit" "extras/compile-zsh-files.zsh"



if [[ $1 == eval ]]
then
    "$@"
set --
fi
