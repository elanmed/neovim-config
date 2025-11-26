#!/bin/bash
q="$1"
flags=$(nvim --headless -i NONE -c "lua io.write(require('rg-glob-builder').build('$q'))" +q)
eval "rg --field-match-separator='|' --column --hidden --color=never -g '!.git/**/*' $flags"
