#!/bin/bash
# unescapes the {q}
eval "rg --field-match-separator='|' --column --hidden --color=never --ignore-case -g '!.git/**/*' $1"
