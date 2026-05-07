#!/usr/bin/env bash
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_use.input.file_path // empty')

if [[ -n "$file_path" && "$file_path" == *.nix ]]; then
  parse_out=$(nix-instantiate --parse "$file_path" 2>&1 >/dev/null)
  if [[ -n "$parse_out" ]]; then
    echo "=== pre-edit syntax warning ==="
    echo "File already had parse errors before this edit:"
    echo "$parse_out"
    echo "(These are pre-existing — not caused by the current edit.)"
  fi
fi
