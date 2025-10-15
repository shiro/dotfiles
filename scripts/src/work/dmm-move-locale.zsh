#!/usr/bin/env zsh

# surround each part between "." delimiters with double quotes
parts=(${(s:.:)1})
from="$(printf '"%s".' "${parts[@]}" | sed 's/\.$//')"

parts=(${(s:.:)2})
to="$(printf '"%s".' "${parts[@]}" | sed 's/\.$//')"

# apply to each locale
for locale in config/locales/*.json; do
    match="$(jq ".$from" $locale)"
    if [[ "$match" == "null" ]]; then
        continue
    fi
    jq ".$to += .$from | del(.$from)" $locale | sponge $locale
done
