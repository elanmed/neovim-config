#!/bin/bash
# unescapes the {q}
eval "rg --field-match-separator='|' --column --hidden --color=never -g '!.git/**/*' $1"
