#!/usr/bin/env bash
#
# omniprompt: voice/text command router.
#
# Hold Alt+F in Hyprland to dictate; on release hyprwhspr transcribes the
# speech and hands the text to omniprompt (via --hook) instead of typing it.
#
# omniprompt detects the focused window and, depending on it, more context:
#   kitty    -> working directory, foreground app of the focused tmux pane
#     zsh    -> output is printed into that pane instead of shown as popups
#     nvim   -> path of the current buffer and the cursor line and column
#   firefox  -> (no extra context)
# and, when a working directory is known, the closest git root (searched from
# the nvim buffer when one is open).
#
# opencode runs in the working directory, or in the git root when the nvim
# buffer belongs to a repository outside the working directory. opencode
# itself loads the AGENTS.md files from there up to the git root (and the
# global one), so this script does not send them.
#
# It then sends the request to opencode together with the context and the
# actions available in it. Actions are recipes for common tasks; anything else
# falls through to run-command, where opencode works out the commands itself.
# The request is routed by a light model ($MODEL), which does simple work
# itself and delegates medium and heavy work to subagents on stronger models.
# opencode runs everything and ends with a structured (JSON) reply saying
# what to show: an answer, a confirmation, a failure or nothing. This script
# shows it (printed into the zsh pane or as a popup), which saves the model a
# round trip. The only output opencode shows itself is a popup announcing
# long-running work before it starts (and timed output). This script never
# executes actions.
#
# Requests from the same zsh instance (a tmux pane, or a kitty window without
# tmux) share one opencode session, so the agent remembers earlier requests
# and its replies there. The session lives exactly as long as that zsh: a new
# zsh (also after exec zsh) gets a new session, and the session is deleted
# when the zsh exits. Requests from other windows (e.g. Firefox) each use a
# one-off session that is deleted after the reply. The full rules are sent
# only with the first request of a session; later requests send only what
# changed since (actions, context, nvim rule) and rely on the session history.
#
# In a tmux pane, opencode may instead hand the request over to an
# interactive chat (only when asked for, or when there is a lot of output to
# read; never for tasks that just perform an action): it replies with the request as a self-contained task, and this
# script starts an interactive opencode in a fresh session with that task as
# its first message, in a new tmux window directly after the current one.
#
# In a tmux pane at a zsh prompt, opencode may also reply with a command to
# run in that shell, as if the user had typed it and pressed Enter (or only
# typed it, to review first). It then runs in the user's shell, so cd,
# export, source etc. take effect there and its output shows in the
# terminal. This needs the ZLE widget from
# ~/.dotfiles/config/zsh/key-bindings/omniprompt.zsh: this script writes the
# command to a request file and presses the widget's key in the pane; the
# widget stashes any text already typed at the prompt (push-line, so it comes
# back at the next prompt) and enters the command. Shells without the widget
# (started before it existed, zsh -f, ...) just get printed output as before.
#
# Activity is logged to ~/.local/state/omniprompt.log.
#
# To add an action, add an entry to the action list matching its context.

SCRIPT_NAME="$(basename "$0")"

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

# Routes every request and does simple work itself
MODEL="claude-agent/haiku"
# Medium work (code changes, debugging) is delegated to this model
MEDIUM_MODEL="claude-agent/sonnet"
# Heavy work (large or multi-file changes, architecture) only, or when asked
HEAVY_MODEL="claude-agent/opus"

# Answers longer than this (in lines) go to an interactive chat when possible
LONG_OUTPUT_LINES=15

# Bump when the prompt changes, so sessions get the full new rules again
PROMPT_VERSION=7

FLAG_DIR="${XDG_RUNTIME_DIR:-/tmp}/hyprwhspr"
FLAG_FILE="$FLAG_DIR/omniprompt"
FLAG_MAX_AGE_MIN=2

LOG_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/omniprompt.log"

# One file per persistent session: its zsh and what was last sent to it
SESSION_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/omniprompt/sessions"

# Running commands in the user's zsh (see the header). Must match
# ~/.dotfiles/config/zsh/key-bindings/omniprompt.zsh: the widget marks its
# shell as ready with ready-<pid> and takes requests from request-<pid>.
SHELL_RUN_DIR="${XDG_RUNTIME_DIR:-/tmp}/omniprompt"
SHELL_RUN_KEYS_HEX=(18 1d) # ^X^]
SHELL_RUN_TIMEOUT_TICKS=40 # x 0.05s to wait for the widget to take a request

SELF="$(readlink -f "$0")"

# ---------------------------------------------------------------------------
# Output
#
# Output goes into the focused zsh pane when the request came from one (see
# detect_terminal), else to a popup. The pane is fixed when the request is
# made, so output still goes there after focus moves to another window, pane
# or tmux session.
#
# The result is shown by this script from opencode's structured reply. Only
# the start popup for long-running work is shown by opencode itself, with:
#   $NOTIFY '<text>'
# ---------------------------------------------------------------------------

NOTIFY=""

set_output_commands() {
  NOTIFY="$SELF --notify${PRINT_PANE:+ --pane $PRINT_PANE} short"
}

# ---------------------------------------------------------------------------
# Actions
#
# Each entry is "id|description". The description tells opencode how to
# perform the action and what to reply (see the reply format in
# build_prompt). It may span several lines; whitespace is collapsed before it
# is sent.
# ---------------------------------------------------------------------------

# Always available
GLOBAL_ACTIONS=(
  "toggle-audio|
    Toggle the audio output between headphones and speakers: run
    ~/bin/audio-output toggle. Reply short 'Toggled audio'; on failure, none."

  "run-command|
    Anything no other action covers: do the commands or file edits needed
    yourself (e.g. 'what is my git branch', 'restart waybar', 'add PORT=3000
    to .env'), using the context to resolve what the request refers to.
    Reply answer for information, else short (e.g. 'Restarted waybar')."
)

# Only when the focused kitty pane is a tmux pane at a zsh prompt whose shell
# has the omniprompt ZLE widget (see the header)
SHELL_ACTIONS=(
  "run-in-shell|
    Type a command at the user's zsh prompt (the focused terminal) and, with
    run true, press Enter, so it runs inside that shell. Use it ONLY when the
    request changes the shell's state (cd, export, source, venv, nix-shell,
    ...) or explicitly asks to run or type a command in the terminal;
    requests to print or show something use the other actions. Do not run the
    command yourself (read-only commands to work it out are fine). Reply
    {\"kind\": \"shell\", \"title\": \"<a few words>\", \"command\": \"<command line>\", \"run\": true};
    run false only types it, for when the user asks only to type it or it is
    destructive. Text already at the prompt is kept. Nothing else is shown."
)

# Only when the focused window is Firefox
FIREFOX_ACTIONS=(
  "google|
    'Google <query>' (speech-to-text may write 'Googled' etc.): run
    firefox --new-tab \"https://www.google.com/search?q=\$(jq -rn --arg q '<query>' '\$q|@uri')\"
    escaping single quotes in the query. Reply none."
)

# Only when nvim is the foreground app of the focused kitty pane and its
# current buffer path could be read
NVIM_ACTIONS=(
  "edit-buffer|
    Edit the nvim buffer as asked ('this file' is the buffer; 'this line',
    'here' is the cursor), keeping the change minimal. Reply short 'Edited',
    or fail 'Edit failed' with the reason."
)

# ---------------------------------------------------------------------------
# Context (filled in by detect_context)
# ---------------------------------------------------------------------------

ACTIVE_CLASS=""
ACTIVE_TITLE=""
WORKING_DIR=""
PANE_PID=""
PANE_CMD=""
PRINT_PANE=""  # tmux pane id (%N) of the focused zsh prompt, if any
TMUX_PANE_ID="" # tmux pane id (%N) of the focused pane, whatever runs in it
SHELL_PID=""   # the zsh instance of the focused pane or terminal window, if any
RUN_SHELL_PID="" # the zsh at the prompt of PRINT_PANE, if it can run commands
NVIM_BUFFER=""
NVIM_LINE=""    # cursor line in NVIM_BUFFER (1-based)
NVIM_COLUMN=""  # cursor column in NVIM_BUFFER (1-based, in characters)
NVIM_SOCKET=""
GIT_ROOT=""
WORKSPACE=""    # directory opencode runs in (see detect_project_context)
# Names of the action lists that apply (expanded after detection)
AVAILABLE_ACTIONS=()

# ---------------------------------------------------------------------------
# Session (filled in by detect_session and load_session_state)
# ---------------------------------------------------------------------------

SESSION_ID=""        # opencode session of SHELL_PID, else a one-off one
SESSION_ONE_OFF=0    # 1 when SESSION_ID is deleted after this request
SESSION_STATE=""     # state file of a persistent session
SESSION_NEW=1        # 1 when the session has not received the full rules yet
SHELL_START=""       # start time of SHELL_PID
SHELL_TOKEN=""       # token of the SHELL_PID instance from its ready file
SENT_DIR=""          # directory the session was last run in
SENT_ACTIONS=""      # action lists last sent
SENT_CONTEXT=""      # hash of the context last sent
SENT_NVIM_SOCKET=""  # nvim socket the nvim rule was last sent for
SENT_CHAT=""         # 1 when the chat rule was sent
SEND_ACTIONS=1       # send the actions with this request
SEND_CONTEXT=1       # send the context with this request
SEND_NVIM_RULE=1     # send the nvim rule with this request
SEND_CHAT_RULE=1     # send the chat rule with this request
CONTEXT_TEXT=""      # the context of this request (print_context)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

usage() {
  cat <<EOF
usage: $SCRIPT_NAME [PROMPT...]
       echo PROMPT | $SCRIPT_NAME
       $SCRIPT_NAME --hook      hyprwhspr post_transcription_hook mode
       $SCRIPT_NAME --arm       mark the next transcription as an omniprompt
       $SCRIPT_NAME --disarm    clear that mark
       $SCRIPT_NAME --list      list all actions
       $SCRIPT_NAME --notify [--pane PANE] short|answer|fail TITLE [BODY]
                                print into a tmux pane at a zsh prompt, else
                                show a popup (used by opencode for the
                                start popup)
       $SCRIPT_NAME --end-session PID TOKEN
                                end the session of a zsh that exits (used
                                by the zsh widget)
EOF
}

log() {
  mkdir -p "$(dirname "$LOG_FILE")"
  printf '%s %s\n' "$(date -Is)" "$*" >>"$LOG_FILE"
}

# Collapse newlines and runs of spaces into single spaces and trim.
one_line() {
  printf '%s' "$1" | tr -s '\n ' ' ' | sed -E 's/^ +| +$//g'
}

action_id() { printf '%s' "${1%%|*}"; }
action_description() { one_line "${1#*|}"; }

# ---------------------------------------------------------------------------
# Process helpers
# ---------------------------------------------------------------------------

# stat_field PID N
#
# Print field N of /proc/PID/stat, counted after the comm field (so 1 is the
# state, 2 the ppid, 20 the start time). comm may contain spaces, so skip
# past its closing ")" first.
stat_field() {
  local stat
  local -a fields
  stat="$(cat "/proc/$1/stat" 2>/dev/null)" || return 1
  read -ra fields <<<"${stat##*) }"
  printf '%s' "${fields[$2 - 1]}"
}

parent_pid() { stat_field "$1" 2; }

# is_ancestor ANCESTOR_PID PID
is_ancestor() {
  local pid="$2"
  while [ -n "$pid" ] && [ "$pid" -gt 1 ]; do
    [ "$pid" = "$1" ] && return 0
    pid="$(parent_pid "$pid")"
  done
  return 1
}

# outermost_zsh PID STOP_PID
#
# Print the outermost zsh among PID and its ancestors below STOP_PID (the
# login shell of a terminal window, not a nested one).
outermost_zsh() {
  local pid="$1" found=""
  while [ -n "$pid" ] && [ "$pid" -gt 1 ] && [ "$pid" != "$2" ]; do
    [ "$(cat "/proc/$pid/comm" 2>/dev/null)" = zsh ] && found="$pid"
    pid="$(parent_pid "$pid")"
  done
  printf '%s' "$found"
}

# Print PID and all of its descendants.
process_tree() {
  local pid="$1" child
  printf '%s\n' "$pid"
  for child in $(pgrep -P "$pid"); do
    process_tree "$child"
  done
}

# prompt_shell PANE_PID
#
# Print the pid of the zsh in the foreground of the pane's tty, if it has the
# omniprompt ZLE widget loaded (it is ready to run commands). With job
# control, the foreground process group of the tty (tpgid) is led by that
# shell while it is at its prompt, also for a zsh nested in the pane's one.
prompt_shell() {
  local pid
  pid="$(stat_field "$1" 6)" || return 1
  [[ "$pid" =~ ^[0-9]+$ ]] && [ "$pid" -gt 0 ] || return 1
  [ "$(cat "/proc/$pid/comm" 2>/dev/null)" = zsh ] || return 1
  [ -f "$SHELL_RUN_DIR/ready-$pid" ] || return 1
  printf '%s' "$pid"
}

# ---------------------------------------------------------------------------
# Context detection
#
# Detection is branched: each level is only inspected once the level above
# it is confirmed, and its actions are only offered at that point. So opencode
# never sees an action that is unavailable.
#
#   focused window ─┬─ kitty ── nvim
#                   └─ firefox
#
# Afterwards, if a working directory was found, the project context (git
# root and the directory opencode runs in) is detected from it.
# ---------------------------------------------------------------------------

detect_context() {
  AVAILABLE_ACTIONS=(GLOBAL_ACTIONS)

  detect_window_context
  detect_project_context
}

# The hyprwhspr service may have started before Hyprland exported its
# environment to systemd, so HYPRLAND_INSTANCE_SIGNATURE can be missing (then
# hyprctl fails and no context is found). Use the newest running instance.
find_hyprland_instance() {
  local dir sock
  [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] &&
    [ -S "${XDG_RUNTIME_DIR:-/run/user/$UID}/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock" ] &&
    return 0
  for dir in $(ls -td "${XDG_RUNTIME_DIR:-/run/user/$UID}"/hypr/*/ 2>/dev/null); do
    sock="$dir.socket.sock"
    [ -S "$sock" ] || continue
    export HYPRLAND_INSTANCE_SIGNATURE="$(basename "$dir")"
    return 0
  done
  log "no running Hyprland instance found"
}

detect_window_context() {
  local win

  command -v hyprctl >/dev/null 2>&1 || return 0
  find_hyprland_instance
  win="$(hyprctl activewindow -j 2>/dev/null)" || {
    log "hyprctl activewindow failed"
    return 0
  }

  ACTIVE_CLASS="$(jq -r '.class // empty' <<<"$win")"
  ACTIVE_TITLE="$(jq -r '.title // empty' <<<"$win")"

  case "$ACTIVE_CLASS" in
    kitty) detect_kitty_context "$(jq -r '.pid // empty' <<<"$win")" ;;
    firefox) detect_firefox_context ;;
  esac
}

# Sets GIT_ROOT to the closest git root (searched from the nvim buffer's
# directory when one is open, else from the working directory) and WORKSPACE
# to the directory opencode runs in: the working directory, or the git root
# when the working directory is not inside it (a buffer from another
# repository). opencode loads the AGENTS.md files from WORKSPACE up to the git
# root itself, so the closest git root's AGENTS.md is always included.
detect_project_context() {
  local start

  [ -n "$WORKING_DIR" ] || return 0
  WORKSPACE="$WORKING_DIR"

  start="$WORKING_DIR"
  [ -n "$NVIM_BUFFER" ] && [ -d "$(dirname "$NVIM_BUFFER")" ] &&
    start="$(dirname "$NVIM_BUFFER")"
  GIT_ROOT="$(git -C "$start" rev-parse --show-toplevel 2>/dev/null)"

  [ -n "$GIT_ROOT" ] || return 0
  case "$WORKING_DIR/" in
    "$GIT_ROOT"/*) ;;
    *) WORKSPACE="$GIT_ROOT" ;;
  esac
}

detect_firefox_context() {
  AVAILABLE_ACTIONS+=(FIREFOX_ACTIONS)
}

# detect_kitty_context TERMINAL_PID
detect_kitty_context() {
  local term_pid="$1"

  [ -n "$term_pid" ] || return 0
  detect_terminal "$term_pid"

  if [ -n "$PRINT_PANE" ] && RUN_SHELL_PID="$(prompt_shell "$PANE_PID")"; then
    AVAILABLE_ACTIONS+=(SHELL_ACTIONS)
  fi

  case "$PANE_CMD" in
    nvim) detect_nvim_context ;;
  esac
}

detect_nvim_context() {
  local job_pid

  [ -n "$PANE_PID" ] || return 0
  detect_nvim "$PANE_PID"

  # The current buffer is a terminal (e.g. yazi in a floating window), named
  # term://{cwd}//{pid}:{cmd}. tmux only sees nvim, so take the working
  # directory and command from the job running in it. Standalone apps (yazi
  # directly in the pane) are already reported correctly by tmux.
  if [[ "$NVIM_BUFFER" =~ ^term://.*//([0-9]+): ]]; then
    job_pid="${BASH_REMATCH[1]}"
    if [ -d "/proc/$job_pid" ]; then
      WORKING_DIR="$(readlink "/proc/$job_pid/cwd" 2>/dev/null || printf '%s' "$WORKING_DIR")"
      PANE_CMD="$(cat "/proc/$job_pid/comm" 2>/dev/null || printf '%s' "$PANE_CMD")"
    fi
    # Not a file, so the buffer actions do not apply
    NVIM_BUFFER=""
    NVIM_LINE=""
    NVIM_COLUMN=""
    return 0
  fi

  [ -n "$NVIM_BUFFER" ] || return 0
  AVAILABLE_ACTIONS+=(NVIM_ACTIONS)
}

# detect_terminal TERMINAL_PID
#
# Find the focused session inside the terminal: the active pane of the tmux
# client running in it, else the deepest descendant process of the terminal.
#
# Sets WORKING_DIR, PANE_PID (root process of the focused pane), PANE_CMD
# (its foreground command), SHELL_PID (the pane's or window's zsh, if any),
# for a tmux pane TMUX_PANE_ID and, if it is at a zsh prompt, PRINT_PANE.
# Must not be called in a subshell.
detect_terminal() {
  local term_pid="$1" client_pid client_tty pid child info pane_id

  if command -v tmux >/dev/null 2>&1; then
    while read -r client_pid client_tty; do
      [ -n "$client_pid" ] || continue
      is_ancestor "$term_pid" "$client_pid" || continue

      info="$(tmux display-message -c "$client_tty" -p \
        '#{pane_id}|#{pane_pid}|#{pane_current_command}|#{pane_current_path}')"
      IFS='|' read -r pane_id PANE_PID PANE_CMD WORKING_DIR <<<"$info"
      TMUX_PANE_ID="$pane_id"
      # At a zsh prompt: print output into this pane instead of popups
      [ "$PANE_CMD" = zsh ] && PRINT_PANE="$pane_id"
      [ "$(cat "/proc/$PANE_PID/comm" 2>/dev/null)" = zsh ] && SHELL_PID="$PANE_PID"
      return
    done < <(tmux list-clients -F '#{client_pid} #{client_tty}' 2>/dev/null)
  fi

  pid="$term_pid"
  while child="$(pgrep -P "$pid" | tail -n1)" && [ -n "$child" ]; do
    pid="$child"
  done

  PANE_PID="$term_pid"
  PANE_CMD="$(cat "/proc/$pid/comm" 2>/dev/null)"
  WORKING_DIR="$(readlink "/proc/$pid/cwd")"
  SHELL_PID="$(outermost_zsh "$pid" "$term_pid")"
}

# detect_nvim PANE_PID
#
# Find the nvim running under PANE_PID and set NVIM_SOCKET, NVIM_BUFFER (path
# of its current buffer), NVIM_LINE and NVIM_COLUMN (cursor position in it,
# 1-based; the column counts characters, not bytes). nvim listens on
# $XDG_RUNTIME_DIR/nvim.<pid>.0 (on the --embed child when a UI process is
# used), so try every process in the pane's tree. Must not be called in a
# subshell.
detect_nvim() {
  local pid sock path line column

  for pid in $(process_tree "$1"); do
    sock="${XDG_RUNTIME_DIR:-/run/user/$UID}/nvim.$pid.0"
    [ -S "$sock" ] || continue

    # One round trip: path, line and column on separate lines
    { IFS= read -r path; read -r line; read -r column; } < <(
      timeout 2 nvim --server "$sock" --remote-expr \
        'expand("%:p") .. "\n" .. line(".") .. "\n" .. charcol(".")' 2>/dev/null
      printf '\n'
    )
    if [ -n "$path" ]; then
      NVIM_SOCKET="$sock"
      NVIM_BUFFER="$path"
      [[ "$line" =~ ^[0-9]+$ ]] && NVIM_LINE="$line"
      [[ "$column" =~ ^[0-9]+$ ]] && NVIM_COLUMN="$column"
      return
    fi
  done
}

# ---------------------------------------------------------------------------
# Session
#
# Each zsh instance gets its own opencode session, identified by the boot id,
# the zsh's pid and the token in its ready file (written by the ZLE widget,
# new for every zsh instance, also after exec zsh). Shells without the widget
# use their start time instead (pids are reused). The state file records the
# zsh and what was last sent to the session, so follow-up requests only send
# what changed.
#
# A session never outlives its zsh: the widget runs --end-session when the zsh
# exits, and every request also ends the sessions of zsh instances that are
# gone (killed shells, reboots). Requests without a zsh use a one-off session
# that is deleted after the reply.
# ---------------------------------------------------------------------------

boot_id() { tr -d '-' </proc/sys/kernel/random/boot_id 2>/dev/null | cut -c1-8; }

# shell_token PID: the token in the ready file of zsh PID, if any
shell_token() {
  local token
  token="$(head -c 64 "$SHELL_RUN_DIR/ready-$1" 2>/dev/null)"
  [[ "$token" =~ ^[0-9]+$ ]] && printf '%s' "$token"
}

# session_id PID TOKEN_OR_START
session_id() { printf 'ses_omniprompt%s%sx%s' "$(boot_id)" "$1" "$2"; }

# state_get FILE KEY
state_get() { sed -n "s/^$2=//p" "$1" 2>/dev/null | head -n1; }

# shell_alive PID START TOKEN: the zsh instance is still running
shell_alive() {
  [[ "$1" =~ ^[0-9]+$ ]] && [ -n "$2" ] || return 1
  [ "$(stat_field "$1" 20)" = "$2" ] || return 1
  [ -z "$3" ] || [ "$(shell_token "$1")" = "$3" ]
}

# Sets SESSION_ID and SESSION_STATE when the focused window has a zsh.
detect_session() {
  [ -n "$SHELL_PID" ] || return 0
  SHELL_START="$(stat_field "$SHELL_PID" 20)" || return 0
  [ -n "$SHELL_START" ] || return 0
  SHELL_TOKEN="$(shell_token "$SHELL_PID")"

  SESSION_ID="$(session_id "$SHELL_PID" "${SHELL_TOKEN:-$SHELL_START}")"
  SESSION_STATE="$SESSION_STATE_DIR/$SESSION_ID"
}

# A fresh session for this request only, deleted after it.
use_one_off_session() {
  SESSION_ID="ses_omniprompt0x$(date +%s%N)"
  SESSION_ONE_OFF=1
  SESSION_STATE=""
}

# Sets SESSION_NEW and the SEND_* flags from the state file.
load_session_state() {
  [ -n "$SESSION_STATE" ] && [ -f "$SESSION_STATE" ] || return 0

  SENT_DIR="$(state_get "$SESSION_STATE" dir)"
  # Older prompt version: send everything again
  [ "$(state_get "$SESSION_STATE" version)" = "$PROMPT_VERSION" ] || return 0

  SESSION_NEW=0
  SENT_ACTIONS="$(state_get "$SESSION_STATE" actions)"
  SENT_CONTEXT="$(state_get "$SESSION_STATE" context)"
  SENT_NVIM_SOCKET="$(state_get "$SESSION_STATE" nvim)"
  SENT_CHAT="$(state_get "$SESSION_STATE" chat)"

  [ "${AVAILABLE_ACTIONS[*]}" != "$SENT_ACTIONS" ] || SEND_ACTIONS=0
  [ "$(context_hash)" != "$SENT_CONTEXT" ] || SEND_CONTEXT=0
  [ "$NVIM_SOCKET" != "$SENT_NVIM_SOCKET" ] || SEND_NVIM_RULE=0
  [ "$SENT_CHAT" != 1 ] || SEND_CHAT_RULE=0
}

context_hash() { printf '%s' "$CONTEXT_TEXT" | md5sum | cut -c1-16; }

# A session keeps the directory it was created in, also for later requests
# made elsewhere. Move it to this request's directory, so commands run there
# and opencode loads that directory's AGENTS.md files.
move_session() {
  [ -n "$SESSION_STATE" ] && [ -f "$SESSION_STATE" ] || return 0
  [ -n "$WORKSPACE" ] && [ "$WORKSPACE" != "$SENT_DIR" ] || return 0
  opencode api post "/api/session/$SESSION_ID/move"     -d "$(jq -cn --arg d "$WORKSPACE" '{directory: $d}')"     >/dev/null 2>>"$LOG_FILE" ||
    log "could not move session $SESSION_ID to $WORKSPACE"
}

# Record the zsh and what this request sent.
save_session_state() {
  local actions="$SENT_ACTIONS" context="$SENT_CONTEXT"
  local nvim="$SENT_NVIM_SOCKET" chat="$SENT_CHAT"

  [ -n "$SESSION_STATE" ] || return 0
  [ "$SEND_ACTIONS" = 1 ] && actions="${AVAILABLE_ACTIONS[*]}"
  [ "$SEND_CONTEXT" = 1 ] && context="$(context_hash)"
  [ "$SEND_NVIM_RULE" = 1 ] && [ -n "$NVIM_SOCKET" ] && nvim="$NVIM_SOCKET"
  [ "$SEND_CHAT_RULE" = 1 ] && chat_available && chat=1

  mkdir -p "$SESSION_STATE_DIR"
  printf '%s
' "version=$PROMPT_VERSION" "pid=$SHELL_PID" "start=$SHELL_START"     "token=$SHELL_TOKEN" "dir=${WORKSPACE:-$SENT_DIR}" "actions=$actions"     "context=$context" "nvim=$nvim" "chat=$chat" >"$SESSION_STATE"
}

# delete_session ID: delete the opencode session and its state
delete_session() {
  rm -f "$SESSION_STATE_DIR/$1" "$SESSION_STATE_DIR/.lock-$1"
  if opencode session delete "$1" >/dev/null 2>&1; then
    log "deleted session $1"
  fi
}

# end_session ID: delete a persistent session unless a request is using it
# (that request deletes it when it finishes, as its zsh is gone).
end_session() {
  local fd
  [ -f "$SESSION_STATE_DIR/$1" ] || return 0
  exec {fd}>>"$SESSION_STATE_DIR/.lock-$1"
  flock -n "$fd" && delete_session "$1"
  exec {fd}>&-
}

# End the sessions of zsh instances that are gone (also state files of older
# versions, which do not record their zsh).
sweep_sessions() {
  local file
  for file in "$SESSION_STATE_DIR"/ses_*; do
    [ -f "$file" ] || continue
    [ "$file" = "$SESSION_STATE" ] && continue
    shell_alive "$(state_get "$file" pid)" "$(state_get "$file" start)" \
      "$(state_get "$file" token)" && continue
    end_session "$(basename "$file")"
  done
}

# After the request: keep the session while its zsh runs, else delete it.
finish_session() {
  if [ "$SESSION_ONE_OFF" = 1 ]; then
    delete_session "$SESSION_ID"
  elif [ -n "$SESSION_STATE" ]; then
    if shell_alive "$SHELL_PID" "$SHELL_START" "$SHELL_TOKEN"; then
      [ "$1" = 0 ] && save_session_state
    else
      delete_session "$SESSION_ID"
    fi
  fi
}

# ---------------------------------------------------------------------------
# Prompt
#
# The first request of a session gets everything: intro, actions, context and
# rules. Follow-up requests in a persistent session get only what changed
# since it was last sent: the actions and context (they depend on the focused
# window), and the nvim and chat rules.
# ---------------------------------------------------------------------------

# build_prompt REQUEST
build_prompt() {
  local request="$1"

  if [ "$SESSION_NEW" = 1 ]; then
    print_intro
    print_actions
    printf '%s\n' "$CONTEXT_TEXT"
    print_rules
  else
    printf 'New request; same rules and reply format.\n'
    if [ "$SEND_ACTIONS" = 1 ]; then print_actions; else printf 'Actions: unchanged.\n'; fi
    if [ "$SEND_CONTEXT" = 1 ]; then printf '%s\n' "$CONTEXT_TEXT"; else printf 'Context: unchanged.\n'; fi
    local send_nvim=0 send_chat=0
    [ "$SEND_NVIM_RULE" = 1 ] && [ -n "$NVIM_SOCKET" ] && send_nvim=1
    [ "$SEND_CHAT_RULE" = 1 ] && chat_available && send_chat=1
    if [ "$send_nvim" = 1 ] || [ "$send_chat" = 1 ]; then
      printf '\nRules (replacing earlier ones that contradict them):\n'
      [ "$send_nvim" = 1 ] && print_nvim_rule
      [ "$send_chat" = 1 ] && print_chat_rule
    fi
  fi

  printf '\nRequest: %s\n' "$request"
}

print_intro() {
  cat <<EOF
You are the user's voice assistant on Linux (Hyprland). The request is
speech-to-text, so expect mishearings. Carry it out with your tools.
EOF
  [ "$SESSION_ONE_OFF" = 0 ] && cat <<EOF
Later requests from the same terminal shell continue this conversation: use
it to resolve references ('again', 'undo that', 'that file'), but never redo
earlier requests unasked. Each request comes with its own context.
EOF
  printf '\n'
}

print_actions() {
  local entry group

  printf 'Actions (use the matching one, else run-command):\n'
  for group in "${AVAILABLE_ACTIONS[@]}"; do
    local -n actions="$group"
    for entry in "${actions[@]}"; do
      printf -- '- %s: %s\n' "$(action_id "$entry")" "$(action_description "$entry")"
    done
    unset -n actions
  done
}

print_context() {
  printf '\nContext (focused when the request was made):\n'
  printf -- '- App: %s; window title: %s\n' "${ACTIVE_CLASS:-unknown}" "${ACTIVE_TITLE:-unknown}"
  [ -n "$WORKING_DIR" ] && printf -- '- Working directory: %s\n' "$WORKING_DIR"
  [ -n "$WORKSPACE" ] && [ "$WORKSPACE" != "$WORKING_DIR" ] &&
    printf -- '- Your shell starts in: %s\n' "$WORKSPACE"
  [ -n "$PANE_CMD" ] && printf -- '- Terminal app: %s\n' "$PANE_CMD"
  [ -n "$NVIM_BUFFER" ] && printf -- '- nvim buffer: %s, cursor line %s, column %s\n' \
    "$NVIM_BUFFER" "${NVIM_LINE:-?}" "${NVIM_COLUMN:-?}"
  [ -n "$GIT_ROOT" ] && printf -- '- Git root: %s\n' "$GIT_ROOT"
  return 0
}

print_rules() {
  cat <<EOF

Rules:
- Stay minimal to conserve tokens.
- Do the minimum: the fewest commands that finish the request, nothing the
  user did not ask for. Only edit files the request is about. Nothing
  destructive or hard to undo (deleting files, git push/reset, force, sudo,
  killing unrelated processes) unless asked for exactly that. If the request
  is unclear, do nothing and reply fail 'Not recognized' with a very short
  reason as body.
- Models: do simple work yourself. Delegate the rest with your subagent tool
  (agent general), giving it everything it needs (the request, paths,
  working directory) and telling it to show no popups. Model
  $MEDIUM_MODEL for medium work (writing, fixing or reviewing code,
  debugging, multi-step changes); $HEAVY_MODEL only for heavy work (large or
  multi-file changes, architecture, hard problems). A model the user names
  (e.g. 'use opus') wins.
- Popups: your final reply is shown as the result; show no other popups
  (no notify-send), except with $NOTIFY '<text>'
  (it prints nothing; never test or repeat it):
  - always before delegating, and before other work that may take more
    than a few seconds (builds, installs, tests, downloads), first say what
    you are about to do (e.g. 'Running tests');
  - output spread over time (e.g. 'say hi every 2 seconds'): each message
    when it happens, in a single shell command; then reply none.
- Reply: finish with exactly one JSON object and nothing else:
  {"kind": "...", "title": "...", "body": "...", "format": "..."}
  kind answer: information asked for (title a label, body the answer);
  short: confirms what was done (title one or two words, no body); fail:
  something failed (title what failed, body the reason; no workarounds);
  none: show nothing. format (optional): plain (default), code, list (one
  item per line) or table (columns separated by tabs). Word it plainly,
  outcome first; never claim success you did not verify.
EOF
  print_chat_rule
  print_nvim_rule
  return 0
}

# An interactive chat can be opened: the request came from a tmux pane, so
# there is a tmux window to open it next to.
chat_available() { [ -n "$TMUX_PANE_ID" ]; }

# Only when an interactive chat can be opened
print_chat_rule() {
  chat_available || return 0
  cat <<EOF
- Chat: reply kind chat to hand the request to a new interactive opencode
  chat in a tmux window, ONLY when the user asks for a chat, or the result
  is something to read that would be too long for a popup (over about
  $LONG_OUTPUT_LINES lines, e.g. research or listings; judge this before doing the
  work). Never for a task that just does something (edits, git, builds,
  multi-step or long-running work, however complex): do it, delegating as
  needed, and reply short or fail. For a chat, do not do the work: title a
  short label; body the
  request as a self-contained task in the user's words, with everything
  from the context and this conversation resolved (absolute paths, line
  numbers, the exact symbol meant by 'this'), and without the request to
  open a chat or anything about voice, popups or replies. The chat sees
  nothing else.
EOF
}

# Only when nvim is open: keep its buffers in sync with the files on disk
print_nvim_rule() {
  [ -n "$NVIM_SOCKET" ] || return 0
  cat <<EOF
- nvim is open. Before anything that may change files on disk (edits,
  formatters, fixers, generators, git checkout/stash/pull; also around
  delegated work), list buffers with unsaved changes:
  nvim --server '$NVIM_SOCKET' --remote-expr 'join(map(getbufinfo({"bufmodified": 1}), "v:val.name"), "\\n")'
  If a file that may change is listed, reply fail 'Unsaved changes' with
  the files as body and stop. Afterwards, reload the buffers:
  nvim --server '$NVIM_SOCKET' --remote-expr 'execute("checktime")'
EOF
}

# ---------------------------------------------------------------------------
# Output (--notify)
# ---------------------------------------------------------------------------

# print_to_pane PANE KIND TITLE [BODY]
#
# Print a message into a tmux pane that is at a zsh prompt, above the prompt
# line, without disturbing zle: the lines are inserted above the cursor row
# and the cursor is put back at the same column, so the prompt and anything
# typed after it stay intact (zle only moves the cursor relatively).
# Writes to the pane's tty, so it is display only and never runs as input.
# Fails (for a popup instead) if the pane is gone or no longer at a zsh
# prompt.
print_to_pane() {
  local pane="$1" kind="$2" title="$3" body="${4:-}"
  local info cmd tty x y h w alt color out line i n room scroll
  local -a lines

  info="$(tmux display-message -t "$pane" -p \
    '#{pane_current_command}|#{pane_tty}|#{cursor_x}|#{cursor_y}|#{pane_height}|#{pane_width}|#{alternate_on}' \
    2>/dev/null)" || return 1
  IFS='|' read -r cmd tty x y h w alt <<<"$info"
  [ "$cmd" = zsh ] && [ "$alt" = 0 ] && [ -w "$tty" ] || return 1
  [ "$h" -ge 3 ] && [ "$w" -ge 10 ] || return 1

  case "$kind" in
    fail) color='1;31' ;;
    answer) color='1;36' ;;
    *) color='1;34' ;;
  esac

  # Wrap to the pane width; keep at least one row for the prompt
  mapfile -t lines < <(
    printf '%s\n' "omniprompt: $title"
    [ -n "$body" ] && printf '%s\n' "$body"
  )
  mapfile -t lines < <(printf '%s\n' "${lines[@]}" | fold -s -w "$w")
  n=${#lines[@]}
  [ "$n" -lt "$h" ] || n=$((h - 1))

  out=""
  # Not enough rows below the prompt: scroll the screen up first
  room=$((h - 1 - y))
  if [ "$n" -gt "$room" ]; then
    scroll=$((n - room))
    out+=$(printf '\e[%d;1H' "$h")
    for ((i = 0; i < scroll; i++)); do out+=$'\n'; done
    y=$((y - scroll))
  fi
  # Insert blank rows at the prompt row, pushing the prompt down
  out+=$(printf '\e[%d;1H\e[%dL' $((y + 1)) "$n")
  for ((i = 0; i < n; i++)); do
    line="${lines[i]}"
    if [ "$i" -eq 0 ]; then
      # Colour the title line
      out+=$(printf '\e[%d;1H\e[%sm%s\e[0m' $((y + 1 + i)) "$color" "$line")
    else
      out+=$(printf '\e[%d;1H%s' $((y + 1 + i)) "$line")
    fi
  done
  # Back to where zle left the cursor, now n rows lower
  out+=$(printf '\e[%d;%dH' $((y + n + 1)) $((x + 1)))

  printf '%s' "$out" >"$tty"
}

# run_in_pane PANE MODE COMMAND
#   MODE: run (type it and press Enter) or type (only type it)
#
# Enter COMMAND at the zsh prompt of a tmux pane as if the user typed it,
# through the omniprompt ZLE widget: write the request file of the shell at
# the prompt, press the widget's key and wait until the widget took it.
# Unlike print_to_pane, this is real input that the shell runs. Fails (and
# withdraws the request) if the pane is no longer at a zsh prompt with the
# widget, or the widget does not take the request in time.
run_in_pane() {
  local pane="$1" mode="$2" command="$3"
  local info cmd pane_pid alt in_mode shell request tmp i

  info="$(tmux display-message -t "$pane" -p \
    '#{pane_current_command}|#{pane_pid}|#{alternate_on}|#{pane_in_mode}' \
    2>/dev/null)" || return 1
  IFS='|' read -r cmd pane_pid alt in_mode <<<"$info"
  # In copy mode the keys would go to tmux, not the shell
  [ "$cmd" = zsh ] && [ "$alt" = 0 ] && [ "$in_mode" = 0 ] || return 1
  shell="$(prompt_shell "$pane_pid")" || return 1

  # Written in one go, so the widget never reads a partial request
  request="$SHELL_RUN_DIR/request-$shell"
  tmp="$(mktemp "$SHELL_RUN_DIR/.request-XXXXXX")" || return 1
  printf '%s\n%s' "$mode" "$command" >"$tmp" && mv -f "$tmp" "$request" || {
    rm -f "$tmp"
    return 1
  }

  if tmux send-keys -t "$pane" -H "${SHELL_RUN_KEYS_HEX[@]}" 2>>"$LOG_FILE"; then
    for ((i = 0; i < SHELL_RUN_TIMEOUT_TICKS; i++)); do
      [ -e "$request" ] || return 0
      sleep 0.05
    done
  fi
  rm -f "$request"
  return 1
}

# notify [--pane PANE] KIND TITLE [BODY]
#   KIND: short (brief confirmation), answer (stays shown), fail (critical)
# Prints into PANE when it is still at a zsh prompt, else shows a popup.
notify() {
  local pane=""
  if [ "${1:-}" = --pane ]; then
    pane="$2"
    shift 2
  fi
  local kind="${1:-short}" title="${2:-}" body="${3:-}"

  [ -n "$pane" ] && print_to_pane "$pane" "$kind" "$title" "$body" && return 0

  case "$kind" in
    fail) notify-send -u critical -a omniprompt "$title" ${body:+"$body"} ;;
    answer) notify-send -a omniprompt "$title" ${body:+"$body"} ;;
    *) notify-send -a omniprompt -t 1500 "$title" ${body:+"$body"} ;;
  esac
}

# ---------------------------------------------------------------------------
# Reply (opencode's final structured reply)
# ---------------------------------------------------------------------------

# parse_reply TEXT
#
# Print the reply object (compact JSON) found in TEXT. The model is asked for
# a bare JSON object, but may wrap it in code fences or put text before it
# (stdout also holds any text it wrote between tool calls), so try each line
# containing "{", from the last one up, as the start of the object.
parse_reply() {
  local -a lines
  local i line candidate json

  mapfile -t lines < <(printf '%s\n' "$1" | sed -E '/^[[:space:]]*```/d')
  for ((i = ${#lines[@]} - 1; i >= 0; i--)); do
    line="${lines[i]}"
    [[ "$line" == *"{"* ]] || continue
    candidate="{${line#*\{}"$'\n'"$(printf '%s\n' "${lines[@]:i+1}")"
    json="$(jq -ec 'select(type == "object" and (.kind | type) == "string")' \
      <<<"$candidate" 2>/dev/null | tail -n1)"
    if [ -n "$json" ]; then
      printf '%s' "$json"
      return 0
    fi
  done
  return 1
}

# render_body FORMAT BODY
render_body() {
  local format="$1" body="$2"

  case "$format" in
    table)
      if [[ "$body" == *$'\t'* ]]; then
        column -t -s $'\t' <<<"$body"
      else
        column -t <<<"$body"
      fi
      ;;
    list) sed -E '/^[[:space:]]*$/d; s/^[[:space:]]*([-*•][[:space:]]+)?/• /' <<<"$body" ;;
    *) printf '%s' "$body" ;;
  esac
}

# show_reply TEXT EXIT_STATUS
#
# Show opencode's reply. Falls back to showing the raw text when it is not a
# reply object, and to a failure when opencode failed without replying.
show_reply() {
  local text="$1" status="$2" json kind title body format
  local -a pane=()
  [ -n "$PRINT_PANE" ] && pane=(--pane "$PRINT_PANE")

  if ! json="$(parse_reply "$text")"; then
    if [ -n "$(one_line "$text")" ]; then
      notify "${pane[@]}" answer Reply "$text"
    else
      notify "${pane[@]}" fail 'omniprompt failed' \
        "opencode exited with status $status and no reply; see $LOG_FILE"
    fi
    return
  fi

  kind="$(jq -r '.kind' <<<"$json")"
  title="$(jq -r '.title // empty | tostring' <<<"$json")"
  body="$(jq -r '.body // empty | tostring' <<<"$json")"
  format="$(jq -r '.format // "plain" | tostring' <<<"$json")"

  [ -n "$title" ] || title=omniprompt

  case "$kind" in
    none) return ;;
    chat)
      # The body is the chat's first message, sent as is
      if [ -n "$body" ] && open_chat "$body"; then
        notify "${pane[@]}" short "$title"
        return
      fi
      log "could not open a chat (pane=${TMUX_PANE_ID:-none})"
      kind=fail
      title="Could not open chat"
      ;;
    shell)
      # The command's output shows in the terminal, so nothing else is shown
      local command mode
      command="$(jq -r '.command // empty | tostring' <<<"$json")"
      mode="$(jq -r 'if .run == false then "type" else "run" end' <<<"$json")"
      if [ -n "$command" ] && [ -n "$PRINT_PANE" ] &&
        run_in_pane "$PRINT_PANE" "$mode" "$command"; then
        log "shell ($mode, pane $PRINT_PANE): $command"
        return
      fi
      log "could not run in shell (pane=${PRINT_PANE:-none}): $command"
      kind=fail
      title="Could not run in shell"
      body="$command"
      format=code
      ;;
    short | answer | fail) ;;
    *) kind=answer ;;
  esac
  [ -n "$body" ] && body="$(render_body "$format" "$body")"

  notify "${pane[@]}" "$kind" "$title" "$body"
}

# open_chat PROMPT
#
# Start an interactive opencode chat in a fresh session that is sent PROMPT
# right away, in a new tmux window directly after the window of the pane the
# request came from. The command is passed as separate arguments, so tmux
# runs it without a shell and PROMPT needs no quoting.
open_chat() {
  local window
  chat_available || return 1
  # new-window takes a window, not a pane
  window="$(tmux display-message -p -t "$TMUX_PANE_ID" '#{window_id}' 2>>"$LOG_FILE")" &&
    [ -n "$window" ] || return 1
  tmux new-window -a -t "$window" -c "${WORKSPACE:-$HOME}" \
    opencode --prompt "$1" 2>>"$LOG_FILE"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

# When started from the hyprwhspr service, the NixOS login environment has not
# been loaded. Load it now, so commands run as they would in a terminal.
# Otherwise every zsh started later (e.g. nix-shell --run "zsh -ic ...")
# loads it itself and puts the global profile in front of the nix-shell PATH,
# so projects get the wrong node, yarn, etc.
load_login_environment() {
  [ -z "${__NIXOS_SET_ENVIRONMENT_DONE-}" ] || return 0
  [ -r /etc/set-environment ] || return 0
  # shellcheck disable=SC1091
  . /etc/set-environment
}

# Commands should behave as in the user's zsh: import the environment of an
# interactive zsh (variables exported by zshrc and the local zshrc, e.g.
# GITHUB_TOKEN for gh, PATH additions). Run after load_login_environment, so
# that zsh sees __NIXOS_SET_ENVIRONMENT_DONE and keeps the PATH order. zshrc
# may print to the terminal, so the environment is read from fd 3.
load_zsh_environment() {
  local var name

  command -v zsh >/dev/null 2>&1 || return 0
  while IFS= read -r -d '' var; do
    name="${var%%=*}"
    case "$name" in
      # Shell bookkeeping, not configuration
      PWD | OLDPWD | SHLVL | _ | TERM) continue ;;
      '' | [0-9]* | *[!A-Za-z0-9_]*) continue ;;
    esac
    export "$var"
  done < <(cd "${WORKING_DIR:-$HOME}" 2>/dev/null &&
    timeout 5 zsh -ic 'env -0 >&3' 3>&1 </dev/null >/dev/null 2>/dev/null)
}

# handle_prompt TEXT
handle_prompt() {
  local request answer status

  request="$(one_line "$1")"
  [ -n "$request" ] || return 0

  load_login_environment
  detect_context
  CONTEXT_TEXT="$(print_context)"
  detect_session
  lock_session
  [ -n "$SESSION_ID" ] || use_one_off_session
  load_session_state
  load_zsh_environment
  set_output_commands
  log "prompt: $request" \
    "(class=$ACTIVE_CLASS cwd=$WORKING_DIR workspace=$WORKSPACE app=$PANE_CMD" \
    "buffer=$NVIM_BUFFER cursor=$NVIM_LINE:$NVIM_COLUMN" \
    "print_pane=$PRINT_PANE tmux_pane=$TMUX_PANE_ID run_shell=$RUN_SHELL_PID" \
    "git=$GIT_ROOT session=$SESSION_ID new=$SESSION_NEW one_off=$SESSION_ONE_OFF" \
    "send=actions:$SEND_ACTIONS,context:$SEND_CONTEXT)"

  # opencode runs the action itself, in the workspace when one is known
  [ -n "$WORKSPACE" ] && cd "$WORKSPACE" 2>/dev/null
  move_session

  # No popup here: opencode announces long-running work itself ($NOTIFY),
  # so instant requests only show the result

  answer="$(opencode run --auto --title omniprompt --model "$MODEL" \
    --session "$SESSION_ID" "$(build_prompt "$request")" 2>>"$LOG_FILE")"
  status=$?
  log "opencode (status $status): $(one_line "$answer")"

  show_reply "$answer" "$status"
  finish_session "$status"
  sweep_sessions
}

# One request at a time per session. When the session is busy (e.g. a long
# build or timed output from an earlier request), use a one-off session
# instead of waiting. The lock is held until the script exits.
lock_session() {
  local fd

  [ -n "$SESSION_ID" ] || return 0
  mkdir -p "$SESSION_STATE_DIR"
  exec {fd}>>"$SESSION_STATE_DIR/.lock-$SESSION_ID"
  flock -n "$fd" && return 0

  log "session $SESSION_ID busy; using a one-off session"
  exec {fd}>&-
  SESSION_ID=""
  SESSION_STATE=""
}

# hyprwhspr post_transcription_hook; stdin is the transcription.
#   Not armed: exit 0 with empty stdout so the text is typed as usual.
#   Armed:     route it to omniprompt and exit 77 so hyprwhspr skips typing.
run_hook() {
  local text
  text="$(cat)"

  if [ -n "$(find "$FLAG_FILE" -mmin "-$FLAG_MAX_AGE_MIN" 2>/dev/null)" ]; then
    rm -f "$FLAG_FILE"
    printf '%s' "$text" | setsid -f "$0" >/dev/null 2>&1
    exit 77
  fi

  rm -f "$FLAG_FILE"
  exit 0
}

list_actions() {
  local entry
  for entry in "${GLOBAL_ACTIONS[@]}" \
    "${SHELL_ACTIONS[@]}" "${NVIM_ACTIONS[@]}" "${FIREFOX_ACTIONS[@]}"; do
    action_id "$entry"
    printf '\n'
  done
}

case "${1:-}" in
  --help | -h) usage ;;
  --list) list_actions ;;
  --arm) mkdir -p "$FLAG_DIR" && touch "$FLAG_FILE" ;;
  --disarm) rm -f "$FLAG_FILE" ;;
  --hook) run_hook ;;
  --notify) shift && notify "$@" ;;
  --end-session)
    [[ "${2:-}" =~ ^[0-9]+$ ]] && [[ "${3:-}" =~ ^[0-9]+$ ]] &&
      end_session "$(session_id "$2" "$3")"
    ;;
  *)
    if [ $# -gt 0 ]; then
      handle_prompt "$*"
    else
      handle_prompt "$(cat)"
    fi
    ;;
esac
