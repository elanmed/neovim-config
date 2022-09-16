#!/bin/bash
function cecho(){
    tput setaf $2;
    echo $1;
    tput sgr0;
}

if [ "$(uname)" != "Darwin" ]; then
  cecho "sorry! this script only supports macos" 1
  exit 1
fi

if [ "$(command -v brew)" == "" ]; then
    cecho "installing hombrew" 2
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  cecho "homebrew already installed" 4
fi

# https://github.com/neovim/neovim/wiki/Installing-Neovim#homebrew-on-macos-or-linux  
# nightly build
if [ "$(brew ls --versions neovim)" == "" ]; then
  cecho "installing neovim" 2
  brew install --HEAD neovim
else
  cecho "neovim already installed" 4
fi

if [ "$(brew ls --versions ripgrep)" == "" ]; then
  cecho "installing ripgrep" 2
  brew install ripgrep
else
  cecho "ripgrep already installed" 4
fi

if [ "$(brew ls --versions fzf)" == "" ]; then
  cecho "installing fzf" 2
  brew install fzf
else
  cecho "fzf already installed" 4
fi

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
