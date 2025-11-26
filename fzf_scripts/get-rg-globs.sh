#!/bin/bash
q="$1"
echo "rg $(nvim --headless -i NONE -c "lua io.write(require('rg-glob-builder').build('$q'))" +q)"
