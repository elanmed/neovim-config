#!/bin/bash
cwd="$1"
sorted_files_path="$2"
padding_width=4
cat \
  <(cat "$sorted_files_path" 2>/dev/null) \
  <(fd --absolute-path --hidden --type f --exclude node_modules --exclude .git --exclude dist | awk '{print ":" $0}') |
  awk '!seen[substr($0, index($0, ":") + 1)]++' |
  while read -r abs_path; do
    # from the right (%), remove the longest match (two %) using the pattern :*
    # i.e. from 1.99:path/to/file remove :path/to/file
    number_part="${abs_path%%:*}"

    # from the left (#), remove the shortest match (one #) matching the pattern *:
    # i.e. from 1.99:path/to/file remove 1.99
    file_path="${abs_path#*:}"

    padded_number=$(printf "%*s" "$padding_width" "$number_part")
    # => printf "%4s" "$number_part"
    # pad $number_part with 4 spaces

    # from the left (#), remove the shortest match (one #) matching the pattern "$cwd"/
    # i.e. from path/to/file remove path/to/
    rel_path="${file_path#"$cwd"/}"

    echo "${padded_number}:${rel_path}"
  done
