#!/usr/bin/env bash
#
# omniprompt: voice/text command router.
#
# Hold Alt+F in Hyprland to dictate; on release hyprwhspr transcribes the
# speech and hands the text to omniprompt (via --hook) instead of typing it.
#
# omniprompt detects the focused window and, depending on it, more context:
#   kitty    -> working directory, foreground app of the focused tmux pane
#     nvim   -> path of the current buffer
#   firefox  -> (no extra context)
# and, when a working directory is known, the closest git root plus the
# contents of AGENTS.md in the git root and the working directory.
#
# It then sends the request to opencode together with the context and the
# actions available in it. Actions are recipes for common tasks; anything else
# falls through to run-command, where opencode works out the commands itself.
# opencode runs everything (results and errors shown as popups) or shows
# "Not recognized". This script never executes actions.
#
# Activity is logged to ~/.local/state/omniprompt.log.
#
# To add an action, add an entry to the action list matching its context.

SCRIPT_NAME="$(basename "$0")"

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

# Routes the request and runs simple actions
MODEL="claude-agent/sonnet"
# Coding work is delegated to this model through a subagent
CODING_MODEL="claude-agent/opus"

FLAG_DIR="${XDG_RUNTIME_DIR:-/tmp}/hyprwhspr"
FLAG_FILE="$FLAG_DIR/omniprompt"
FLAG_MAX_AGE_MIN=2

LOG_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/omniprompt.log"

NOTIFY="notify-send -a omniprompt -t 1500"

# ---------------------------------------------------------------------------
# Actions
#
# Each entry is "id|description". The description tells opencode how to
# perform the action and may span several lines; whitespace is collapsed
# before it is sent.
# ---------------------------------------------------------------------------

# Always available
GLOBAL_ACTIONS=(
  "toggle-audio|
    Toggle the audio output between headphones and speakers.
    Run: ~/bin/audio-output toggle.
    If it succeeds, show a very short notification with the text
    'Toggled audio' using: $NOTIFY 'Toggled audio'.
    Show no notification on failure."

  "run-command|
    Fallback for any request that no other action covers: work out the
    shell commands or file edits needed and do them yourself, e.g. 'print my
    current git branch', 'how much disk space is left', 'restart waybar',
    'add a .env entry for PORT=3000'. Use the
    context (working directory, focused window, nvim buffer) to decide what
    the request refers to; the shell starts in the working directory when
    one is known. If the request asks for information, the answer popup is
    the only popup. Otherwise, once it succeeds, say what was done in one or
    two words (e.g. 'Restarted waybar'): $NOTIFY '<words>'."
)

# Only when the focused window is kitty
KITTY_ACTIONS=(
  "print-working-directory|
    Show a notification with the current working directory of the focused
    terminal, using: notify-send -a omniprompt '<directory>'."
)

# Only when the focused window is Firefox
FIREFOX_ACTIONS=(
  "google|
    Search Google in a new Firefox tab. The user says 'Google <query>'
    (speech-to-text may write it as 'google', 'Googled', etc.); the query is
    everything after that word, as spoken. Run:
    firefox --new-tab \"https://www.google.com/search?q=\$(jq -rn --arg q '<query>' '\$q|@uri')\"
    Escape any single quotes in <query> for the shell. Show no notification."
)

# Only when nvim is the foreground app of the focused kitty pane and its
# current buffer path could be read
NVIM_ACTIONS=(
  "print-buffer-path|
    Show a notification with the path of the current nvim buffer
    (see 'nvim current buffer' in the context),
    using: notify-send -a omniprompt '<path>'."

  "edit-buffer|
    Edit the file open in nvim as the user describes. 'This file' means the
    current buffer ('nvim current buffer' in the context), e.g. 'in this
    file, change X to Y'. Make the change (delegate it if it is coding work,
    see the coding rule), keeping it minimal, and follow the nvim rule.
    Then show: $NOTIFY 'Edited'. If the change cannot be made (e.g. the text
    is not in the file), show: $NOTIFY 'Edit failed'."
)

# ---------------------------------------------------------------------------
# Context (filled in by detect_context)
# ---------------------------------------------------------------------------

ACTIVE_CLASS=""
ACTIVE_TITLE=""
WORKING_DIR=""
PANE_PID=""
PANE_CMD=""
NVIM_BUFFER=""
NVIM_SOCKET=""
GIT_ROOT=""
AGENTS_FILES=()
AVAILABLE_ACTIONS=()

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

# is_ancestor ANCESTOR_PID PID
is_ancestor() {
  local pid="$2"
  while [ -n "$pid" ] && [ "$pid" -gt 1 ]; do
    [ "$pid" = "$1" ] && return 0
    # comm may contain spaces, so skip past its closing ")" before reading ppid
    pid="$(sed -E 's/^.*\) [^ ]+ ([0-9]+) .*$/\1/' "/proc/$pid/stat" 2>/dev/null)"
  done
  return 1
}

# Print PID and all of its descendants.
process_tree() {
  local pid="$1" child
  printf '%s\n' "$pid"
  for child in $(pgrep -P "$pid"); do
    process_tree "$child"
  done
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
# root and AGENTS.md files) is detected from it.
# ---------------------------------------------------------------------------

detect_context() {
  AVAILABLE_ACTIONS=("${GLOBAL_ACTIONS[@]}")

  detect_window_context
  detect_project_context
}

detect_window_context() {
  local win

  command -v hyprctl >/dev/null 2>&1 || return 0
  win="$(hyprctl activewindow -j 2>/dev/null)" || return 0

  ACTIVE_CLASS="$(jq -r '.class // empty' <<<"$win")"
  ACTIVE_TITLE="$(jq -r '.title // empty' <<<"$win")"

  case "$ACTIVE_CLASS" in
    kitty) detect_kitty_context "$(jq -r '.pid // empty' <<<"$win")" ;;
    firefox) detect_firefox_context ;;
  esac
}

# Sets GIT_ROOT to the closest git root (searched from the nvim buffer's
# directory when one is open, else from the working directory) and
# AGENTS_FILES to the AGENTS.md files in the git root and the working
# directory.
detect_project_context() {
  local start dir file

  [ -n "$WORKING_DIR" ] || return 0

  start="$WORKING_DIR"
  [ -n "$NVIM_BUFFER" ] && [ -d "$(dirname "$NVIM_BUFFER")" ] &&
    start="$(dirname "$NVIM_BUFFER")"
  GIT_ROOT="$(git -C "$start" rev-parse --show-toplevel 2>/dev/null)"

  for dir in "$GIT_ROOT" "$WORKING_DIR"; do
    [ -n "$dir" ] || continue
    file="$dir/AGENTS.md"
    [ -f "$file" ] || continue
    # skip duplicates (working directory is the git root)
    [[ " ${AGENTS_FILES[*]} " == *" $file "* ]] && continue
    AGENTS_FILES+=("$file")
  done
}

detect_firefox_context() {
  AVAILABLE_ACTIONS+=("${FIREFOX_ACTIONS[@]}")
}

# detect_kitty_context TERMINAL_PID
detect_kitty_context() {
  local term_pid="$1"

  AVAILABLE_ACTIONS+=("${KITTY_ACTIONS[@]}")

  [ -n "$term_pid" ] || return 0
  detect_terminal "$term_pid"

  case "$PANE_CMD" in
    nvim) detect_nvim_context ;;
  esac
}

detect_nvim_context() {
  [ -n "$PANE_PID" ] || return 0
  detect_nvim "$PANE_PID"

  [ -n "$NVIM_BUFFER" ] || return 0
  AVAILABLE_ACTIONS+=("${NVIM_ACTIONS[@]}")
}

# detect_terminal TERMINAL_PID
#
# Find the focused session inside the terminal: the active pane of the tmux
# client running in it, else the deepest descendant process of the terminal.
#
# Sets WORKING_DIR, PANE_PID (root process of the focused pane) and PANE_CMD
# (its foreground command). Must not be called in a subshell.
detect_terminal() {
  local term_pid="$1" client_pid client_tty pid child info

  if command -v tmux >/dev/null 2>&1; then
    while read -r client_pid client_tty; do
      [ -n "$client_pid" ] || continue
      is_ancestor "$term_pid" "$client_pid" || continue

      info="$(tmux display-message -c "$client_tty" -p \
        '#{pane_pid}|#{pane_current_command}|#{pane_current_path}')"
      IFS='|' read -r PANE_PID PANE_CMD WORKING_DIR <<<"$info"
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
}

# detect_nvim PANE_PID
#
# Find the nvim running under PANE_PID and set NVIM_SOCKET and NVIM_BUFFER
# (path of its current buffer). nvim listens on $XDG_RUNTIME_DIR/nvim.<pid>.0
# (on the --embed child when a UI process is used), so try every process in
# the pane's tree. Must not be called in a subshell.
detect_nvim() {
  local pid sock path

  for pid in $(process_tree "$1"); do
    sock="${XDG_RUNTIME_DIR:-/run/user/$UID}/nvim.$pid.0"
    [ -S "$sock" ] || continue

    path="$(timeout 2 nvim --server "$sock" --remote-expr 'expand("%:p")' 2>/dev/null)"
    if [ -n "$path" ]; then
      NVIM_SOCKET="$sock"
      NVIM_BUFFER="$path"
      return
    fi
  done
}

# ---------------------------------------------------------------------------
# Prompt
# ---------------------------------------------------------------------------

# build_prompt REQUEST
build_prompt() {
  local request="$1" entry file

  cat <<EOF
You are a voice assistant on the user's Linux desktop (Hyprland). The user
spoke the request below (speech-to-text, so expect typos and mishearings).
Carry it out by running the needed commands with your own tools.

Actions (use the specific one that matches the request; for anything else,
use run-command):
EOF
  for entry in "${AVAILABLE_ACTIONS[@]}"; do
    printf -- '- %s: %s\n' "$(action_id "$entry")" "$(action_description "$entry")"
  done

  cat <<EOF

Context (the window focused when the request was made):
- Focused application: ${ACTIVE_CLASS:-unknown}
- Window title: ${ACTIVE_TITLE:-unknown}
EOF
  [ -n "$WORKING_DIR" ] && printf -- '- Working directory: %s\n' "$WORKING_DIR"
  [ -n "$PANE_CMD" ] && printf -- '- Current application in the terminal: %s\n' "$PANE_CMD"
  [ -n "$NVIM_BUFFER" ] && printf -- '- nvim current buffer: %s\n' "$NVIM_BUFFER"
  [ -n "$NVIM_SOCKET" ] && printf -- '- nvim server socket: %s\n' "$NVIM_SOCKET"
  [ -n "$GIT_ROOT" ] && printf -- '- Git root: %s\n' "$GIT_ROOT"

  for file in "${AGENTS_FILES[@]}"; do
    printf '\nProject instructions from %s (follow them when they apply;\n' "$file"
    printf 'pass them to any subagent working in this project):\n\n'
    cat "$file"
    printf '\n'
  done

  cat <<EOF

Rules:
- Do only the minimum work needed to finish the request: the fewest commands
  that get the answer or make the change. No extra exploration, checks,
  cleanup or follow-up work the user did not ask for.
- Show exactly one popup per request: the answer, the confirmation an
  action names, or the failure. No progress or "doing X" popups, and never
  both an answer and a failure popup.
- The user cannot see your reply, only notifications. If the request asks
  for information (print, show, what is, how many...), show the answer in a
  notification without a timeout so it can be read:
  notify-send -a omniprompt '<title>' '<answer>'
- If a command fails, show a short reason:
  notify-send -u critical -a omniprompt 'Failed' '<reason>'
  Do not try workarounds the user did not ask for.
- If you cannot tell what the request means, do nothing except show:
  $NOTIFY 'Not recognized'. Then reply with: none
- Only edit files the request asks you to change.
- Never do anything destructive or hard to undo (deleting files, git push,
  reset, force operations, killing unrelated processes, sudo) unless the
  request explicitly asks for exactly that.
- Coding work (writing, changing, refactoring, fixing or reviewing code) must
  be delegated, never done yourself: use your subagent tool with model
  $CODING_MODEL. A subagent starts with no context, so give it everything it
  needs: the request, the file paths and the working directory. Popups,
  checks and plain commands such as git status or a formatter are not coding
  work; do those yourself.
- Keep any reply to one short line.
EOF

  # Only when nvim is open: keep its buffers in sync with the files on disk
  if [ -n "$NVIM_SOCKET" ]; then
    cat <<EOF
- nvim rule: nvim is open, so files may be shown in its buffers. This
  applies to anything you do that may change files on disk: direct edits
  and also commands such as formatters, linters with --fix, code
  generators, git checkout/stash/pull, and so on.
  1. Before: list the files with unsaved changes in nvim:
     nvim --server '$NVIM_SOCKET' --remote-expr 'join(map(getbufinfo({"bufmodified": 1}), "v:val.name"), "\\n")'
     If a file that may change is listed, do not go ahead; show:
     $NOTIFY 'Unsaved changes' and stop.
  2. After: if you think any file may have changed, reload nvim's buffers:
     nvim --server '$NVIM_SOCKET' --remote-expr 'execute("checktime")'
  Skip both steps for commands that only read (git status, ls, ...).
EOF
  fi

  printf '\nRequest: %s\n' "$request"
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

# handle_prompt TEXT
handle_prompt() {
  local request answer

  request="$(one_line "$1")"
  [ -n "$request" ] || return 0

  load_login_environment
  detect_context
  log "prompt: $request" \
    "(class=$ACTIVE_CLASS cwd=$WORKING_DIR app=$PANE_CMD buffer=$NVIM_BUFFER" \
    "git=$GIT_ROOT agents=${AGENTS_FILES[*]})"

  # opencode runs the action itself; start it in the working directory if known
  [ -n "$WORKING_DIR" ] && cd "$WORKING_DIR" 2>/dev/null

  answer="$(opencode run --auto --title omniprompt --model "$MODEL" \
    "$(build_prompt "$request")" 2>>"$LOG_FILE")"
  log "opencode: $(one_line "$answer")"
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
  for entry in "${GLOBAL_ACTIONS[@]}" "${KITTY_ACTIONS[@]}" \
    "${NVIM_ACTIONS[@]}" "${FIREFOX_ACTIONS[@]}"; do
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
  *)
    if [ $# -gt 0 ]; then
      handle_prompt "$*"
    else
      handle_prompt "$(cat)"
    fi
    ;;
esac
