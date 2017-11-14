#!/usr/bin/env bash

command_exists() {
    type "$1" > /dev/null 2>&1
}

echo "Installing dotfiles."


echo "Initializing submodule(s)"
git submodule update --init --recursive

 
mkdir -p local # local files directory
mkdir -p ~/.local/share # local files directory
mkdir -p ~/.local/share/misc


source scripts/link.sh


# install fzf if not installed
if [ ! -d ~/.local/share/fzf ]; then
	echo "installing fzf"
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.local/share/fzf
	~/.local/share/fzf/install --all
fi

# install wslpath
if ! [[ -f ~/bin/wslpath ]]; then
	echo "installing wslpath"
	wget https://github.com/darealshinji/scripts/raw/master/wslpath -O ~/bin/wslpath
fi

echo "Done. Reload your terminal."
