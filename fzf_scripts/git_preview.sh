#!/bin/bash
set -euo pipefail

file="$1"

# Deleted file, show the version from HEAD
if [[ ! -e $file ]]; then
  git show HEAD:"$file" 2>/dev/null | bat --file-name="$file" --style=numbers --color=always
  exit 0
fi

# If there are changes against HEAD, show the diff (skip the 4-line header)
diff_output=$(git diff --color=always HEAD "$file" 2>/dev/null || true)
if [[ -n $diff_output ]]; then
  printf '%s\n' "$diff_output" | tail -n +5
  exit 0
fi

# Untracked or unchanged: show the file itself
bat --style=numbers --color=always "$file"
