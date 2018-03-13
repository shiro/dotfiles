#!/bin/bash

export OS_RELEASE=$(awk -F= '/^NAME/{print $2}' /etc/os-release | sed 's/"//g')
export KERNEL_TYPE=$(uname -r)


echo "installing applications..."
echo "system release: $OS_RELEASE"

for file in ${DOTFILES}/scripts/install/*; do
  [[ "$file" == */_* ]] && continue # ingore _*
  source "$file"
done
