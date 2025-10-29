#!/bin/bash
q="$1"
echo "rg $(nvim --headless -c "lua io.write(require('rg-glob-builder').build('$q'))" +q)"
