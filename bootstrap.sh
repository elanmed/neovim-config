#!/bin/bash
# shellcheck source=/dev/null

source ~/.dotfiles/helpers.sh

server_flag=0
package_manager=""

for arg in "$@"; do
  case "$arg" in
    --server)
      server_flag=1
      shift
      ;;
    --pm=*)
      package_manager="$arg"
      shift
      ;;
    *)
      h_format_error "--pm={brew,dnf,apt} --server"
      ;;
  esac
done

h_validate_package_manager "$package_manager"

h_install_package "$package_manager" neovim
h_is_linux && h_install_package "$package_manager" python3-neovim

h_install_package "$package_manager" fzf
h_install_package "$package_manager" ripgrep
h_install_package "$package_manager" watchman

if h_is_linux; then
  h_install_package "$package_manager" fd-find
else
  h_install_package "$package_manager" fd
fi

if [[ $server_flag -eq 1 ]]; then
  h_echo --mode=noop "SKIPPING: running :PlugInstall"
else
  h_echo --mode=doing "running :PlugInstall"
  nvim --headless "+PlugInstall" +qa
fi
