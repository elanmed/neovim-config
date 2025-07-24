#!/bin/bash
cwd="$1"
sorted_files_path="$2"

cat \
  <(cat "$sorted_files_path" 2>/dev/null | awk '{print "◉ :" $0}') \
  <(fd --absolute-path --hidden --type f --exclude node_modules --exclude .git --exclude dist | awk '{print "◌ :" $0}') |
  awk '!seen[substr($0, 4)]++' |
  while read -r abs_path; do
    first_three_chars="${abs_path:0:3}"
    without_first_three_chars="${abs_path:3}"
    rel_path="${without_first_three_chars#"$cwd"/}"
    echo "${first_three_chars}${rel_path}"
  done
