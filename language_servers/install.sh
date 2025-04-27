#!/bin/bash
# shellcheck source=/dev/null

source ~/.dotfiles/helpers.sh

h_echo --mode=doing "installing language servers from package.json"
npm install

h_echo --mode=doing "installing the lua language server binary"
LUA_LS_RELEASES="$(curl -s "https://api.github.com/repos/LuaLS/lua-language-server/releases/latest")"

if h_is_linux; then
  LUA_LS_FILE_PATTERN="lua-language-server-.*-linux-x64.tar.gz"
else
  LUA_LS_FILE_PATTERN="lua-language-server-.*-darwin-arm64.tar.gz"
fi

LUA_LS_FILE=$(echo "$LUA_LS_RELEASES" | jq --raw-output --arg pattern "$LUA_LS_FILE_PATTERN" '.assets[] | select(.name | test($pattern)) | .name')
LUA_LS_URL=$(echo "$LUA_LS_RELEASES" | jq --raw-output --arg pattern "$LUA_LS_FILE_PATTERN" '.assets[] | select(.name | test($pattern)) | .browser_download_url')

LUA_LS_DIR="lua-language-server-release"

if ! [[ -e $LUA_LS_FILE ]]; then
  wget --quiet "$LUA_LS_URL"
  rm --recursive --force "$LUA_LS_DIR"
  mkdir "$LUA_LS_DIR"
  tar --extract --gzip --file "$LUA_LS_FILE" --directory "$LUA_LS_DIR"
fi
