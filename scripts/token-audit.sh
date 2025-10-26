#!/bin/bash
find .cursor/rules -name "*.mdc" -exec wc -w {} + | tail -1
for file in .cursor/rules/*.mdc; do
  words=$(wc -w < "$file")
  tokens=$((words * 13 / 10))
  printf "%s: ~%d tokens\n" "$(basename "$file")" "$tokens"
done | sort -t: -k2 -n

total_words=$(find .cursor/rules -name "*.mdc" -exec cat {} + | wc -w)
echo "Estimated total: ~$((total_words * 13 / 10)) tokens"
