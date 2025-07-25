#!/bin/bash
cwd="$1"
rel_path="$2"

abs_path="$cwd/$rel_path"
nvim --headless --noplugin -i NONE -c "lua io.write(require('fzf-lua-frecency.algo').update_file_score('$abs_path'))" +q
