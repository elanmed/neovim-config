#!/bin/bash
source ~/.dotfiles/helpers.sh

package_manager=""
server=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --server)
      server=true
      shift
      ;;
    --package-manager)
      package_manager="$2"
      shift 2
      ;;
    *)
      h_echo error "usage: ./bootstrap.sh --package-manager <pm> [--server]"
      exit 1
      ;;
  esac
done

if [[ -z $package_manager ]]; then
  h_echo error "missing required argument: --package-manager"
  exit 1
fi
h_validate_package_manager "$package_manager"

h_install_package "$package_manager" bat
h_install_package "$package_manager" fzf
h_install_package "$package_manager" ripgrep
h_install_package "$package_manager" fd
h_install_package "$package_manager" cargo
h_install_package "$package_manager" curl
h_install_package "$package_manager" jq

h_echo doing "installing bob"
export PATH="$HOME/.cargo/bin:$PATH"
cargo install bob-nvim

h_echo doing "installing nightly"
bob install nightly
bob use nightly

h_echo doing "installing language servers from package.json"
source ~/.nvm/nvm.sh
npm install --prefix ~/.dotfiles/neovim/.config/nvim/language_servers/

h_echo doing "installing the lua language server binary"
latest_release=$(curl -s https://api.github.com/repos/LuaLS/lua-language-server/releases/latest)

if [[ "$(uname -s)" == "Linux" ]]; then
  os_pattern="lua-language-server-.*-linux-x64.tar.gz"
else
  os_pattern="lua-language-server-.*-darwin-arm64.tar.gz"
fi

asset_name=$(echo "$latest_release" | jq --raw-output ".assets[] | select(.name | test(\"$os_pattern\")) | .name")
download_url=$(echo "$latest_release" | jq --raw-output ".assets[] | select(.name | test(\"$os_pattern\")) | .browser_download_url")
expected_sha=$(echo "$latest_release" | jq --raw-output ".assets[] | select(.name | test(\"$os_pattern\")) | .digest")

lua_ls_dir="$HOME/.dotfiles/neovim/.config/nvim/language_servers/lua-language-server-release"
lua_ls_tar="$HOME/.dotfiles/neovim/.config/nvim/language_servers/$asset_name"

rm -rf "$lua_ls_dir"
mkdir -p "$lua_ls_dir"

curl --location --output "$lua_ls_tar" "$download_url"

actual_sha="sha256:$(sha256sum "$lua_ls_tar" | cut --delimiter ' ' --field 1)"

if [[ $actual_sha == "$expected_sha" ]]; then
  h_echo doing "downloaded lua_ls sha matches the expected sha"
  tar --extract --gzip --file "$lua_ls_tar" --directory "$lua_ls_dir"
else
  h_echo error "downloaded lua_ls sha _does not_ match the expected sha"
fi
