#!/usr/bin/env zsh
# This script will take a commit hash, perform a non-interactive rebase to edit the commit, and then reset HEAD to put changes into the working tree.
# It then waits for user input and finally creates two commits based on the changes.

# set -e


# # Trap INT and TERM signals to abort the rebase when the script is terminated
abort_rebase() {
  echo "Aborting rebase..."
  git rebase --abort
  exit 1
}
trap abort_rebase INT TERM

COMMIT_HASH=$(git rev-parse HEAD)

# Start a non-interactive rebase and edit the specified commit
GIT_SEQUENCE_EDITOR="sed -i 's/^pick $COMMIT_HASH/edit $COMMIT_HASH/'" git rebase --interactive --autostash $COMMIT_HASH^
git reset --soft HEAD^

# Wait for user input after reset
echo "Changes moved to working directory. Please make your changes and press Enter to continue."
read -r

# Extract the original commit message
ORIGINAL_MESSAGE=$(git log -1 --pretty=%B $COMMIT_HASH)

# Commit user changes
if [ -z "$(git diff)" ]; then
  echo "no changes made, aborting"
  git rebase --abort
  exit
fi

git add .
git commit -m "$ORIGINAL_MESSAGE"

NEW_COMMIT_HASH=$(git rev-parse HEAD)

git checkout "$COMMIT_HASH" .

if [ -n "$(git diff --cached)" ]; then
  git commit -m "[split]: $ORIGINAL_MESSAGE"
fi

git rebase --continue

git rebase -i $NEW_COMMIT_HASH~
