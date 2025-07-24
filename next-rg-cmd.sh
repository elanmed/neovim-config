#!/bin/bash
q="$1"
echo "$q" >"prev-rg-query.txt"
eval "rg --column --hidden --color=always $(nvim --headless --noplugin -c "lua io.write(require('rg-glob-builder').build('$q'))" +q)"
