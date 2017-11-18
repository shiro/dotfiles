command_exists() {
    type "$1" > /dev/null 2>&1
}


[ -d ~/bin ] && export PATH=~/bin:$PATH


# WSL nice workaround
unsetopt BG_NICE


# load zit, the plugin manager
source ${ZDOTDIR}/plugin/zit.zsh
export ZIT_MODULES_PATH="${HOME}/.local/share/zit-modules"


# additional completions
zit-in "https://github.com/zsh-users/zsh-completions" "zsh-completions"
zit-lo "zsh-completions" "zsh-completions.plugin.zsh"


# enable completion
autoload -U compinit && compinit -u -d ~/.local/share/misc/.zcompdump


[ -z "$TMUX" ] && export TERM=xterm-256color

configs=(
	${ZDOTDIR}/*.zsh
	${ZDOTDIR}/alias/*
	${ZDOTDIR}/plugin/*
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


# load custom settings
if [[ -f "${ZDOTDIR}/.zshrc.local" ]]; then
  source ${ZDOTDIR}/.zshrc.local
fi


# compile everything so it loads faster
zit-lo "zit" "extras/compile-zsh-files.zsh"


if [[ $1 == eval ]]
then
    "$@"
set --
fi
