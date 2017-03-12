if [ -z $SSH_AUTH_SOCK ]; then
	export SSH_AUTH_SOCK="/tmp/.ssh-auth-sock"
	if [ ! -S  "$SSH_AUTH_SOCK" ]; then
		~/bin/msysgit2unix-socket.py "$(realpath ~/.ssh/keeagent.sock):$SSH_AUTH_SOCK"
	fi
fi
