#!/bin/bash
set -euo pipefail

file="$1"
row="$2"

# Deleted file, show the version from HEAD
if [[ ! -e $file ]]; then
  git show HEAD:"$file" 2>/dev/null | bat --file-name="$file" --style=numbers --color=always
  exit 0
fi

# If there are changes against HEAD, show the file + line number
diff_output=$(git diff HEAD "$file" 2>/dev/null || true)
if [[ -n $diff_output ]]; then
  bat --style=numbers --color=always "$file" --highlight-line "$row"
  exit 0
fi

# Untracked or unchanged: show the file itself
bat --style=numbers --color=always "$file"
