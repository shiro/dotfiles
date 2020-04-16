#!/bin/zsh

dot_idea_dir="$DOTFILES/idea"

setopt +o nomatch

config_dirs=( \
  "$HOME/.PhpStorm"* \
  "$HOME/.IntelliJIdea"* \
  "$HOME/.Rider"* \
  "$HOME/.GoLand"* \
  "$HOME/.DataGrip"* \
  "$HOME/.CLion"* \
)

# set -e

for config_dir in ${config_dirs[@]}; do
  [ -d "$config_dir" ] || continue;

  echo -n "[LINK] $config_dir"

  for option_dir in keymaps colors codestyles; do
    rm -r "$config_dir/config/$option_dir" 2>/dev/null
    ln -s "$dot_idea_dir/$option_dir" "$config_dir/config/$option_dir"
  done

  for option_file in "$dot_idea_dir/options"/*; do
    option_name="$(basename "$option_file")"

    rm "$config_dir/config/options/$option_name" 2>/dev/null
    ln -s "$option_file" "$config_dir/config/options/$option_name"
  done

  echo " DONE"
done
