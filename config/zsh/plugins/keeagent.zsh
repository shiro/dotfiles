if [[ -z $SSH_AUTH_SOCK ]]; then
	export SSH_AUTH_SOCK="/tmp/.ssh-auth-sock"
fi

keepass(){
	if [ -f /tmp/msysgit2unix-socket.pid ]; then
		rm /tmp/msysgit2unix-socket.pid $SSH_AUTH_SOCK 2>/dev/null
	fi
	python2 ~/bin/msysgit2unix-socket "$(realpath ~/.ssh/keeagent.sock):$SSH_AUTH_SOCK"
}

# load keepass socket on startup (if it's not there)
[ ! -f /tmp/msysgit2unix-socket.pid ] && [ -f ~/.ssh/keeagent.sock ] && keepass
