#!/bin/bash
q="$1"
eval "rg --column --hidden --color=always $(nvim --headless --noplugin -c "lua io.write(require('rg-glob-builder').build('$q'))" +q)"
