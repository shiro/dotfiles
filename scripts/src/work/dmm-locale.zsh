#!/usr/bin/env zsh

# surround each part between "." delimiters with double quotes
parts=(${(s:.:)1})
escaped_query="$(printf '"%s".' "${parts[@]}" | sed 's/\.$//')"

jq ".$escaped_query" config/locales/$2.json
