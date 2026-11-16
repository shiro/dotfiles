#!/usr/bin/env bash
# new-bottle <name> [path]
#
# Create a new Bottles bottle by copying the template bottle.
#   <name>  display name, e.g. "For The King II"
#   [path]  optional storage dir (e.g. /mnt/ssd1/wine); the bottle is created
#           there and symlinked into ~/wine. Without it, it's created in ~/wine.
#
# Env overrides: BOTTLES_DIR (default ~/wine),
#                BOTTLE_TEMPLATE (default $BOTTLES_DIR/Bottles-Gaming-Template)
set -euo pipefail
shopt -s extglob

BOTTLES_DIR="${BOTTLES_DIR:-$HOME/wine}"
TEMPLATE="${BOTTLE_TEMPLATE:-$BOTTLES_DIR/Bottles-Gaming-Template}"

die() { printf 'new-bottle: %s\n' "$*" >&2; exit 1; }

usage() {
    printf 'usage: %s <name> [path]\n' "${0##*/}" >&2
    exit 2
}

[[ $# -ge 1 && $# -le 2 && -n "$1" ]] || usage
[[ "$1" == -h || "$1" == --help ]] && usage

name="$1"
store="${2:-}"

[[ -f "$TEMPLATE/bottle.yml" ]] || die "template not found: $TEMPLATE"

# Directory name, the way Bottles derives it: drop characters invalid in
# filenames on any platform (\ / : * ? " < > | and control chars), trim, then
# turn every space into '-'.
#   "Granblue Fantasy: Relink"                       -> Granblue-Fantasy-Relink
#   "FINAL FANTASY TACTICS - The Ivalice Chronicles" -> FINAL-FANTASY-TACTICS---The-Ivalice-Chronicles
to_path() {
    local s="$1"
    s="${s//[\\\/:*?\"<>|]/}"
    s="$(printf '%s' "$s" | tr -d '\000-\037\177')"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    s="${s%%+(.)}"
    printf '%s' "${s// /-}"
}

# Name as a YAML scalar, matching PyYAML's output: plain when possible,
# otherwise single-quoted (e.g. 'STAR WARS: Galactic Racer').
yaml_scalar() {
    local s="$1" lower indicators='-?:,[]{}#&*!|>'\''"%@`'
    lower="${s,,}"
    if [[ -z "$s" \
        || "$indicators" == *"${s:0:1}"* \
        || "$s" == *': '* || "$s" == *' #'* || "$s" == *':' \
        || "$s" =~ ^[[:space:]] || "$s" =~ [[:space:]]$ \
        || "$lower" =~ ^(y|n|yes|no|on|off|true|false|null|~)$ \
        || "$s" =~ ^[-+]?([0-9][0-9_]*)?\.?[0-9]*([eE][-+]?[0-9]+)?$ \
        || "$s" =~ ^0[xob] ]]; then
        printf "'%s'" "${s//\'/\'\'}"
    else
        printf '%s' "$s"
    fi
}


dir="$(to_path "$name")"
[[ -n "$dir" ]] || die "name '$name' produces an empty directory name"

link=""
if [[ -n "$store" ]]; then
    store="${store%/}"
    [[ -d "$store" ]] || die "path does not exist: $store"
    dest="$store/$dir"
    link="$BOTTLES_DIR/$dir"
    [[ -e "$link" || -L "$link" ]] && die "already exists: $link"
else
    dest="$BOTTLES_DIR/$dir"
fi
[[ -e "$dest" || -L "$dest" ]] && die "already exists: $dest"

# ---------------------------------------------------------------- progress bar
is_tty=0 B="" C="" G="" R=""
[[ -t 2 ]] && is_tty=1 B=$'\033[1m' C=$'\033[36m' G=$'\033[32m' R=$'\033[0m'

draw_bar() { # <done> <total>
    local done=$1 total=$2 pct cols width filled i bar=""
    (( total > 0 )) || total=1
    (( done > total )) && done=$total
    pct=$(( done * 100 / total ))
    if (( ! is_tty )); then
        # non-interactive: only print every 10%
        (( pct / 10 != ${last_decile:--1} )) || return 0
        last_decile=$(( pct / 10 ))
        printf 'copying: %3d%%\n' "$pct" >&2
        return 0
    fi
    cols="${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}"
    width=$(( cols - 30 ))
    (( width > 50 )) && width=50
    (( width < 10 )) && width=10
    filled=$(( done * width / total ))
    for (( i = 0; i < filled; i++ )); do bar+="█"; done
    for (( i = filled; i < width; i++ )); do bar+="░"; done
    printf '\r\033[K  copying  %s%s%s %3d%%  %s/%s' \
        "$C" "$bar" "$R" "$pct" "$(human "$done")" "$(human "$total")" >&2
}

human() {
    local b=$1
    if   (( b >= 1073741824 )); then printf '%d.%dG' $(( b / 1073741824 )) $(( b % 1073741824 * 10 / 1073741824 ))
    elif (( b >= 1048576 ));    then printf '%dM' $(( b / 1048576 ))
    else                             printf '%dK' $(( b / 1024 ))
    fi
}

size_of() { du -sb --apparent-size -- "$1" 2>/dev/null | cut -f1; }

# ------------------------------------------------------------------- copy
cp_pid=""
cleanup() {
    local rc=$?
    [[ -n "$cp_pid" ]] && kill "$cp_pid" 2>/dev/null && wait "$cp_pid" 2>/dev/null
    if (( rc != 0 )); then
        (( is_tty )) && printf '\r\033[K' >&2
        printf 'new-bottle: aborted, removing partial bottle\n' >&2
        rm -rf -- "$dest"
        [[ -n "$link" && -L "$link" ]] && rm -f -- "$link"
    fi
    (( is_tty )) && printf '\033[?25h' >&2
    return 0
}
trap cleanup EXIT
trap 'exit 130' INT TERM

printf 'Creating bottle %s%s%s\n  dir: %s\n' "$B" "$name" "$R" "$dest" >&2
[[ -n "$link" ]] && printf '  link: %s\n' "$link" >&2

total=$(size_of "$TEMPLATE")
(( is_tty )) && printf '\033[?25l' >&2

cp -a --reflink=auto -- "$TEMPLATE" "$dest" &
cp_pid=$!
while kill -0 "$cp_pid" 2>/dev/null; do
    draw_bar "$(size_of "$dest" || echo 0)" "$total"
    sleep 0.25
done
wait "$cp_pid" || { cp_pid=""; die "copy failed"; }
cp_pid=""
draw_bar "$total" "$total"
(( is_tty )) && printf '\n' >&2

# ------------------------------------------------------------ bottle.yml
now="$(date '+%F %T.%6N')"
NAME="$(yaml_scalar "$name")" PATHV="$(yaml_scalar "$dir")" NOW="'$now'" \
awk '
    /^Name: /          { print "Name: " ENVIRON["NAME"]; next }
    /^Path: /          { print "Path: " ENVIRON["PATHV"]; next }
    /^Creation_Date: / { print "Creation_Date: " ENVIRON["NOW"]; next }
    /^Update_Date: /   { print "Update_Date: " ENVIRON["NOW"]; next }
    { print }
' "$TEMPLATE/bottle.yml" > "$dest/bottle.yml"

# ------------------------------------------------------------ dosdevices
# keep only c: (drop z: -> / and the com ports)
if [[ -d "$dest/dosdevices" ]]; then
    find "$dest/dosdevices" -mindepth 1 -maxdepth 1 ! -name 'c:' -exec rm -rf -- {} +
fi

# ---------------------------------------------------------- template.yml
# fresh uuid per bottle
if [[ -f "$TEMPLATE/template.yml" ]]; then
    UUID="$(cat /proc/sys/kernel/random/uuid)" \
    awk '/^uuid: / { print "uuid: " ENVIRON["UUID"]; next } { print }' \
        "$TEMPLATE/template.yml" > "$dest/template.yml"
fi

# ------------------------------------------------------------------ link
[[ -n "$link" ]] && ln -s -- "$dest" "$link"

printf '%s✔%s %s ready at %s\n' "$G" "$R" "$name" "${link:-$dest}" >&2
