#!/bin/bash
set -euo pipefail

file="$1"

# Deleted file: show the deletion diff
if [[ ! -e $file ]]; then
  git diff HEAD -- "$file" 2>/dev/null | delta --file-style=omit
  exit 0
fi

# Modified file: show the diff
diff_output=$(git diff HEAD -- "$file" 2>/dev/null || true)
if [[ -n $diff_output ]]; then
  printf '%s\n' "$diff_output" | delta --file-style=omit
  exit 0
fi

# Untracked or unchanged: show the file itself
bat --style=numbers --color=always "$file"
