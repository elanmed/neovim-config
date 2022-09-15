#!/bin/bash
function coloredEcho(){
    local exp=$1;
    local color=$2;
    if ! [[ $color =~ '^[0-9]$' ]] ; then
       case $(echo $color | tr '[:upper:]' '[:lower:]') in
        black) color=0 ;;
        red) color=1 ;;
        green) color=2 ;;
        yellow) color=3 ;;
        blue) color=4 ;;
        magenta) color=5 ;;
        cyan) color=6 ;;
        white|*) color=7 ;; # white or invalid color
       esac
    fi
    tput setaf $color;
    echo $exp;
    tput sgr0;
}

if [ "$(uname)" != "Darwin" ]; then
  coloredEcho "sorry! this script only supports macos" red
  exit 1
fi

if [ "$(command -v brew)" == "" ]; then
    coloredEcho "installing hombrew" green
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  coloredEcho "homebrew already installed" blue
fi

# https://github.com/neovim/neovim/wiki/Installing-Neovim#homebrew-on-macos-or-linux  
# nightly build
if [ "$(brew ls --versions neovim)" == "" ]; then
  coloredEcho "installing neovim" green
  brew install --HEAD neovim
else
  coloredEcho "neovim already installed" blue
fi

if [ "$(brew ls --versions ripgrep)" == "" ]; then
  coloredEcho "installing ripgrep" green
  brew install ripgrep
else
  coloredEcho "ripgrep already installed" blue
fi

if [ "$(brew ls --versions fzf)" == "" ]; then
  coloredEcho "installing fzf" green
  brew install fzf
else
  coloredEcho "fzf already installed" blue
fi

packer_directory="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"
if [ ! -d "$packer_directory" ]; then
  coloredEcho "installing packer, packages" green
  nvim $HOME/.config/nvim/lua/elan/plugins/packer.lua
else
  coloredEcho "packer already installed" blue
fi

# increase num allowed open fd
ulimit -n 1024
nvim $HOME/.config/nvim/lua/elan/plugins/packer.lua -c "w"
