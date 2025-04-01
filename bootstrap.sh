#!/bin/bash
# shellcheck source=/dev/null

source ~/.dotfiles/helpers.sh

server_flag=false
package_manager=""

for arg in "$@"; do
  case "$arg" in
    --server)
      server_flag=true
      shift
      ;;
    --pm=*)
      package_manager="$arg"
      shift
      ;;
    *)
      h_format_error "--pm={brew,pacman,dnf,apt} --server"
      ;;
  esac
done

h_validate_package_manager "$package_manager"

h_install_package "$package_manager" neovim
h_install_package "$package_manager" fzf
h_install_package "$package_manager" ripgrep
h_install_package "$package_manager" fd

if $server_flag; then
  h_echo --mode=noop "SKIPPING: running :PlugInstall"
else
  h_echo --mode=doing "running :PlugInstall"
  nvim --headless "+PlugInstall" +qa
fi
