#!/usr/bin/env zsh

# git-explore.zsh - Clone a git repository to a temporary directory and open it in vim
# Usage: git-explore.zsh <git-url>

# Check if URL argument is provided
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <git-url>" >&2
    echo "Example: $0 https://github.com/user/repo.git" >&2
    exit 1
fi

URL="$1"

# Validate that the URL looks like a git repository
if [[ ! "$URL" =~ ^(https?://|git@|ssh://git@) ]]; then
    echo "Error: Invalid git URL format. Expected https://, git@, or ssh://git@ URL." >&2
    exit 1
fi

# Extract repository name from URL
# Handle various URL formats: https://github.com/user/repo.git, git@github.com:user/repo.git, etc.
REPO_NAME=$(basename "$URL" .git)

# Create temporary directory with only repo name
TARGET_DIR="/tmp/${REPO_NAME}"

# Function to get local HEAD commit hash
get_local_commit() {
    if [[ -d "$TARGET_DIR/.git" ]]; then
        cd "$TARGET_DIR" && git rev-parse HEAD 2>/dev/null
    fi
}

# Function to get remote HEAD commit hash
get_remote_commit() {
    git ls-remote "$URL" HEAD 2>/dev/null | cut -f1
}

# Check if repository needs to be cloned/updated
NEEDS_CLONE=1

if [[ -d "$TARGET_DIR/.git" ]]; then
    LOCAL_COMMIT=$(get_local_commit)
    REMOTE_COMMIT=$(get_remote_commit)

    if [[ -n "$LOCAL_COMMIT" && -n "$REMOTE_COMMIT" && "$LOCAL_COMMIT" == "$REMOTE_COMMIT" ]]; then
        NEEDS_CLONE=0
    fi
fi

if [[ "$NEEDS_CLONE" == "1" ]]; then
    # Remove existing directory if it exists
    if [[ -d "$TARGET_DIR" ]]; then
        echo "Removing existing directory: $TARGET_DIR"
        rm -rf "$TARGET_DIR"
    fi

    echo "Cloning repository to: $TARGET_DIR"

    if ! git clone "$URL" "$TARGET_DIR"; then
        echo "Error: Failed to clone repository from $URL"
        exit 1
    fi
fi

cd "$TARGET_DIR" || {
    echo "Error: Failed to change to directory $TARGET_DIR"
    exit 1
}

OPEN_LAST=1 nvim
