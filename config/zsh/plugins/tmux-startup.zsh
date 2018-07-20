[[ -z "$TMUX" && -n "$TMUX_ID" ]] && {
	local SESSION="sesstion_$TMUX_ID"

	tmux a -t "$SESSION" 2>/dev/null || {
		cd && exec tmux new -s "$SESSION"
	}
}
