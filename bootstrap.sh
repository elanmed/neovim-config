#!/bin/bash
# set -euo pipefail
source "$HOME/.dotfiles/_helpers.sh"

usage="usage: ./bootstrap.sh -p brew|dnf|apt -d mate|gnome|macos|headless"

desktop_envs=("gnome" "mate" "macos" "headless")
package_managers=("brew" "dnf" "apt")

package_manager=""
desktop_env=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p)
      if [[ -z ${2:-} ]]; then
        h_echo error "$usage"
        exit 1
      fi
      package_manager="$2"
      shift 2
      ;;
    -d)
      if [[ -z ${2:-} ]]; then
        h_echo error "$usage"
        exit 1
      fi
      desktop_env="$2"
      shift 2
      ;;
    *)
      h_echo error "$usage"
      exit 1
      ;;
  esac
done

if [[ -z $package_manager ]]; then
  h_echo error "$usage"
  exit 1
fi

if [[ -z $desktop_env ]]; then
  h_echo error "$usage"
  exit 1
fi

if ! h_array_includes "$desktop_env" "${desktop_envs[@]}"; then
  h_echo error "$usage"
  exit 1
fi

if ! h_array_includes "$package_manager" "${package_managers[@]}"; then
  h_echo error "$usage"
  exit 1
fi

h_install_package "$package_manager" bat
h_install_package "$package_manager" fzf
h_install_package "$package_manager" ripgrep
h_install_package "$package_manager" fd
h_install_package "$package_manager" curl
h_install_package "$package_manager" jq

h_echo doing "installing nightly"
export PATH="$HOME/.local/bin:$PATH"
nvvm update
nvim --headless -c "packupdate\!" -c "qa"

if [[ $desktop_env == "headless" ]]; then
  exit 0
fi

h_echo doing "installing language servers from package.json"
pnpm install --yes --silent --prefix "$HOME/.dotfiles/neovim/.config/nvim/language_servers/"

h_echo doing "installing rustup"
# https://rustup.rs/
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# https://github.com/EmmyLuaLs/emmylua-analyzer-rust
h_echo doing "installing emmylua_ls"
cargo install emmylua_ls

h_echo doing "installing emmylua_formatter"
cargo install emmylua_formatter

h_echo doing "installing emmylua_check"
cargo install emmylua_check
