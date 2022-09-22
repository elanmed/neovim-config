#!/bin/bash
function cecho(){
    tput setaf $2;
    echo "$1";
    tput sgr0;
}

function hasHomebrewPackage() {
  if [ "$(brew ls --versions "$1")" == "" ]; then echo 0; else echo 1; fi
}

function hasAptPackage() {
  echo $(dpkg-query -W -f='${Status}' nano 2>/dev/null | grep -c "ok installed");
}

function maybeInstallPackage() {
  if [ "$(uname)" == "Darwin" ]; then
    if [ "$(hasHomebrewPackage "$1")" == 1 ]; then
      cecho "$1 already installed" 4
    else
      cecho "installing $1" 2
      if [ "$1" == "neovim" ]; then brew install --HEAD "$1"; else brew install "$1"; fi
    fi
  else
    if [ "$(hasAptPackage "$1")" == 1]; then
      cecho "$1 already installed" 4
    else
      cecho "installing $1" 2
      apt install "$1"
    fi
  fi
}

maybeInstallPackage neovim
maybeInstallPackage ripgrep
maybeInstallPackage fzf

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
