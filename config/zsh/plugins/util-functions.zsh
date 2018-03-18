# path conversions {{{
upath() {
    echo "$1"  | sed -r -e 's/\\/\//g' -e 's/^([^:]+):/\/\1/'
}

wpath() {
    if [ ${#} -eq 0 ]; then
        : skip
    elif [ -f "$1" ]; then
        local dirname=$(dirname "$1")
        local basename=$(basename "$1")
        echo "$(cd "$dirname" && pwd)/$basename" | sed -e 's|/|\\|g'
    elif [ -d "$1" ]; then
        echo "$(cd "$1" && pwd)" | sed 's|/|\\|g'
    else
        echo "$1" \
        | sed -e 's|^/\(.\)/|\1:\\|g' -e 's|/|\\|g'
    fi
}
# }}}

