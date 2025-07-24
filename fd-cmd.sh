#!/bin/bash
cwd="$1"
sorted_files_path="$2"

uniq_paths=$(cat <(cat "$sorted_files_path" 2>/dev/null) <(fd --absolute-path --hidden --type f --exclude node_modules --exclude .git --exclude dist) | awk '!seen[$0]++')
echo "$uniq_paths" | parallel --keep-order --jobs="$(nproc)" "$(dirname "$0")/score-file.sh" "$cwd" {}
