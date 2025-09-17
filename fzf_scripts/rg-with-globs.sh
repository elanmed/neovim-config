#!/bin/bash
q="$1"
echo "$q" >"$(dirname "$0")/prev-rg-query.txt"
eval "rg --field-match-separator='|' --column --hidden --color=never -g '!.git/**/*' $(nvim --headless -c "lua io.write(require('rg-glob-builder').build('$q'))" +q)"
