#!/bin/bash
eval "rg --field-match-separator='|' --column --hidden --color=never -g '!.git/**/*' $1"
