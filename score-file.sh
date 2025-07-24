#!/bin/bash
cwd="$1"
abs_path="$2"

rel_path="${abs_path#"$cwd"/}"
prefix=$(nvim --headless --noplugin -i NONE -c "lua io.write(require('fzf-lua-frecency.algo').get_score_prefix('$abs_path'))" +q)
echo "$prefix:$rel_path"
