#! /bin/bash

source ~/.dotfiles/helpers.sh

h_validate_num_args --num=1 "$@"
h_validate_package_manager $1

h_install_package $1 neovim
if [[ $1 == "--pm=dnf" ]]
then
  h_install_package $1 python3-neovim
fi

h_install_package $1 fzf
h_install_package $1 ripgrep
h_install_package $1 watchman

# increase num allowed open fd
ulimit -n 1024
h_cecho --doing "opening nvim"
$(which nvim) -u ~/.dotfiles/neovim/.config/nvim/+feature_complete.lua ~/.config/nvim/lua/feature_complete/packer.lua -c "w"
