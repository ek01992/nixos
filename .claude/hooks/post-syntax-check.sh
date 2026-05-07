#!/usr/bin/env bash
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_use.input.file_path // empty')

if [[ -n "$file_path" && "$file_path" == *.nix ]]; then
  parse_out=$(nix-instantiate --parse "$file_path" 2>&1 >/dev/null)
  if [[ -n "$parse_out" ]]; then
    echo "=== nix syntax error ==="
    echo "$parse_out"
    echo "Fix required: file does not parse."
  fi
fi
