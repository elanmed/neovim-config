#!/bin/bash
source ~/.dotfiles/helpers.sh

usage="usage: ./bootstrap.sh -p brew|dnf|apt -d mate|gnome|macos|server"

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

if [[ $(uname -s) == "Linux" ]] && ! h_is_toolbox && ! h_is_podman; then
  h_echo error "bootstrap.sh must be run in a container or macos"
  exit 1
fi
if [[ -z $package_manager ]]; then
  h_echo error "$usage"
  exit 1
fi
if [[ -z $desktop_env ]]; then
  h_echo error "$usage"
  exit 1
fi

h_validate_package_manager "$package_manager"
h_validate_desktop_env "$desktop_env"

h_install_package "$package_manager" bat
h_install_package "$package_manager" fzf
h_install_package "$package_manager" ripgrep
h_install_package "$package_manager" fd
h_install_package "$package_manager" curl
h_install_package "$package_manager" jq

h_echo doing "installing nightly"
export PATH="$HOME/.local/bin:$PATH"
nvvm update

if [[ $desktop_env == "server" ]]; then
  exit 0
fi

h_echo doing "installing language servers from package.json"
pnpm install --yes --silent --prefix ~/.dotfiles/neovim/.config/nvim/language_servers/

h_echo doing "installing the lua language server binary"
latest_release=$(curl -s https://api.github.com/repos/LuaLS/lua-language-server/releases/latest)

if [[ "$(uname -s)" == "Linux" ]]; then
  os_pattern="lua-language-server-.*-linux-x64.tar.gz"
elif [[ "$(uname -m)" == "arm64" ]]; then
  os_pattern="lua-language-server-.*-darwin-arm64.tar.gz"
else
  os_pattern="lua-language-server-.*-darwin-x64.tar.gz"
fi

asset_name=$(echo "$latest_release" | jq --raw-output ".assets[] | select(.name | test(\"$os_pattern\")) | .name")
download_url=$(echo "$latest_release" | jq --raw-output ".assets[] | select(.name | test(\"$os_pattern\")) | .browser_download_url")
expected_sha=$(echo "$latest_release" | jq --raw-output ".assets[] | select(.name | test(\"$os_pattern\")) | .digest")

lua_ls_dir="$HOME/.dotfiles/neovim/.config/nvim/language_servers/lua-language-server-release"
lua_ls_tar="$HOME/.dotfiles/neovim/.config/nvim/language_servers/$asset_name"

rm -rf "$lua_ls_dir"
mkdir -p "$lua_ls_dir"

curl --silent --location --output "$lua_ls_tar" "$download_url"

actual_sha="sha256:$(shasum -a 256 "$lua_ls_tar" | cut -d ' ' -f 1)"

if [[ $actual_sha == "$expected_sha" ]]; then
  tar --extract --gzip --file "$lua_ls_tar" --directory "$lua_ls_dir"
else
  h_echo error "downloaded lua_ls sha _does not_ match the expected sha"
fi
