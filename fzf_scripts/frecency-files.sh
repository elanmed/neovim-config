#!/bin/bash
cwd="$1"
sorted_files_path="$2"

cat "$sorted_files_path" 2>/dev/null | parallel --keep-order --jobs="$(nproc)" "$(dirname "$0")/score-frecency-file.sh" "$cwd" {}
