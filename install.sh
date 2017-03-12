#!/usr/bin/env bash

command_exists() {
    type "$1" > /dev/null 2>&1
}

echo "Installing dotfiles."


echo "Initializing submodule(s)"
git submodule update --init --recursive

 
mkdir -p local # local files directory
mkdir -p ~/.localbin # local files directory


mkdir -p local/zsh_comp_cache
touch local/.zsh_history


source install/link.sh


# install fzf if not installed
if ! [[ -f ~/.fzf.zsh ]]; then
	echo "installing fzf"
	if ! [[ -f ~/.fzf/install ]]; then
		rm -rf ~/.fzf
		git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	fi
	~/.fzf/install --all
fi

# install wslpath
if ! [[ -f ~/bin/wslpath ]]; then
	echo "installing wslpath"
	wget https://github.com/darealshinji/scripts/raw/master/wslpath -O ~/bin/wslpath
fi

echo "Done. Reload your terminal."
