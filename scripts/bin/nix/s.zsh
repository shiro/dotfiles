#!/usr/bin/env zsh

command="$1"
shift


POSITIONAL_ARGS=()


select-generation() {
    lines=("${(@f)$(nixos-rebuild list-generations)}")
    header="$lines[1]"
    lines[1]=()
    printf '%s\n' "${lines[@]}" | fzf --header "$header" --bind enter:accept-non-empty | read target
    [ -z "$target" ] && echo "no revision selected" && exit 1
    echo $target | cut -d' ' -f1
}


case "$command" in
    new)
        # while [[ $# -gt 0 ]]; do
        #   case $1 in
        #     -c|--comment)
        #       shift
        #       export NIXOS_LABEL_VERSION=" $1"
        #       shift
        #       ;;
        #   esac
        # done
        tmp="/tmp/nixos-label"
        vim "$tmp"
        NIXOS_LABEL="`date +'%Y.%m.%d-%H:%M'` `cat \"$tmp\"`"
        NIXOS_LABEL="${NIXOS_LABEL// /_}"
        export NIXOS_LABEL

        echo "$NIXOS_LABEL"
        set -e
        sudo -E nixos-rebuild switch --flake "path:.#default" --impure
        set +e
        rm "$tmp"
        ;;
    list)
        nixos-rebuild list-generations
        ;;
    select)
        target="`select-generation`"
        sudo -E "/nix/var/nix/profiles/system-$target-link/bin/switch-to-configuration" test
        ;;
    use)
        target="`select-generation`"
        sudo -E "/nix/var/nix/profiles/system-$target-link/bin/switch-to-configuration" switch
        ;;
    default)
        target="`select-generation`"
        sudo -E "/nix/var/nix/profiles/system-$target-link/bin/switch-to-configuration" boot
        ;;
esac

# se nix-env --switch-generation 26 -p /nix/var/nix/profiles/system
# /run/current-system/bin/switch-to-configuration boot
