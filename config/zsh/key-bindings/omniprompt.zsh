# omniprompt (~/bin/omniprompt) can run commands in this shell as if they
# were typed at the prompt: it writes the command to this shell's request
# file and presses ^X^] in the tmux pane, which runs the widget below.
#
# Request file: the first line is "run" (enter and run the command) or "type"
# (only put it at the prompt), the rest is the command line. Text already
# typed at the prompt is pushed onto the buffer stack (push-line), so it comes
# back at the next prompt.
#
# The ready file tells omniprompt that this shell has the widget; shells
# without it get printed output only. Keep the paths and the key in sync with
# SHELL_RUN_DIR and SHELL_RUN_KEYS_HEX in omniprompt.

[[ -o interactive ]] || return 0

typeset -g _omniprompt_dir="${XDG_RUNTIME_DIR:-/tmp}/omniprompt"

_omniprompt-run() {
  local file="$_omniprompt_dir/request-$$" request mode
  [[ -f $file ]] || return 0
  request="$(<$file)"
  rm -f -- "$file"
  [[ $request == *$'\n'* ]] || return 0
  mode="${request%%$'\n'*}"

  [[ -n $BUFFER ]] && zle push-line
  BUFFER="${request#*$'\n'}"
  CURSOR=$#BUFFER

  if [[ $mode == run ]]; then
    zle accept-line
  else
    zle redisplay
  fi
}
zle -N _omniprompt-run

# Requests run here as " omniprompt --job FILE": never save them to history
_omniprompt-history() { [[ $1 != *' --job '*omniprompt/job-* ]]; }
autoload -Uz add-zsh-hook
add-zsh-hook zshaddhistory _omniprompt-history
bindkey -M viins '^X^]' _omniprompt-run
bindkey -M vicmd '^X^]' _omniprompt-run
bindkey -M emacs '^X^]' _omniprompt-run

# The ready file holds a token unique to this zsh instance (exec zsh keeps the
# pid and start time, but gets a new token). omniprompt keys its session for
# this shell on it, and the session ends when this shell exits.
zmodload -F zsh/datetime p:EPOCHREALTIME 2>/dev/null
typeset -g _omniprompt_token="${EPOCHREALTIME//[^0-9]/}"
[[ -n $_omniprompt_token ]] || _omniprompt_token="$(date +%s%N)"

_omniprompt-exit() {
  rm -f -- "$_omniprompt_dir/ready-$$" "$_omniprompt_dir/request-$$"
  (( $+commands[omniprompt] )) &&
    setsid -f omniprompt --end-session "$$" "$_omniprompt_token" &>/dev/null
}

if mkdir -p -m 700 "$_omniprompt_dir" 2>/dev/null; then
  print -r -- "$_omniprompt_token" >|"$_omniprompt_dir/ready-$$"
  autoload -Uz add-zsh-hook
  add-zsh-hook zshexit _omniprompt-exit
fi
