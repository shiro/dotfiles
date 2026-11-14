#!/usr/bin/env zsh
# Refresh opencode's cached models.dev catalog.
#
# The opencode-serve service runs with OPENCODE_DISABLE_MODELS_FETCH=1 (see
# nixos/shared/ai.nix) so cold starts don't block on the fetch. It still reads
# the catalog cached in opencode.db, so this starts a throwaway server with
# fetching enabled, lets its startup refresh write the cache, and stops it.

setopt err_exit pipe_fail

unset OPENCODE_DISABLE_MODELS_FETCH
export OPENCODE_SERVER_PASSWORD=$(head -c 24 /dev/urandom | base64 | tr -d '/+=')

log=$(mktemp -t opencode-model-list-update.XXXXXX)
pid=
cleanup() {
    if [[ -n $pid ]]; then
        kill $pid 2> /dev/null && wait $pid 2> /dev/null
    fi
    rm -f $log
}
trap cleanup EXIT INT TERM

opencode serve --port 0 --print-logs --log-level info > $log 2>&1 &
pid=$!

url=
for i in {1..100}; do
    url=$(grep -oE 'server listening on http://[^ ]+' $log | awk '{print $4}') || true
    [[ -n $url ]] && break
    kill -0 $pid 2> /dev/null || { cat $log >&2; echo "opencode server exited early" >&2; exit 1 }
    sleep 0.1
done
[[ -z $url ]] && { echo "opencode server did not start" >&2; exit 1 }

# The first request for a location loads the catalog and starts the refresh.
curl -sf -o /dev/null -u opencode:$OPENCODE_SERVER_PASSWORD "$url/api/provider?directory=$HOME" ||
    { echo "request to $url failed" >&2; exit 1 }

# Fetch timeout is 10s; a second provider.updated means a new catalog was stored.
for i in {1..150}; do
    if grep -q 'Failed to fetch models.dev' $log; then
        grep 'Failed to fetch models.dev' $log >&2
        exit 1
    fi
    if (( $(grep -c 'event.type=provider.updated' $log) >= 2 )); then
        echo "model list updated"
        echo "restart the service to use it: systemctl --user restart opencode-serve"
        exit 0
    fi
    sleep 0.1
done

echo "model list already up to date (or refreshed in the last 5 minutes)"
