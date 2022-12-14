#!/bin/bash
function cecho(){
    tput setaf $2;
    echo $1;
    tput sgr0;
}

function hasHomebrewPackage() {
  if [ "$(brew ls --versions "$1")" == "" ]; then echo 0; else echo 1; fi
}

function maybeInstallPackage() {
  if [ "$(hasHomebrewPackage "$1")" == 1 ]; then
    cecho "$1 already installed" 4
  else
    cecho "installing $1" 2
    if [ "$1" == "neovim" ]; then brew install --HEAD "$1"; else brew install "$1"; fi
  fi
}

if [ "$(command -v brew)" == "" ]; then
    cecho "installing hombrew" 2
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  cecho "homebrew already installed" 4
fi

maybeInstallPackage neovim
maybeInstallPackage ripgrep
maybeInstallPackage fzf
maybeInstallPackage watchman

packer_directory="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"
if [ ! -d "$packer_directory" ]; then
  cecho "installing packer, packages" 2
  nvim $HOME/.config/nvim/lua/settings/plugins/packer.lua
else
  cecho "packer already installed" 4
fi

# increase num allowed open fd
ulimit -n 1024
nvim $HOME/.config/nvim/lua/settings/plugins/packer.lua -c "w"
