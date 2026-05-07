#!/usr/bin/env bash
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_use.input.file_path // empty')

if [[ -n "$file_path" && "$file_path" == *.nix ]]; then
  nixfmt "$file_path" 2>/dev/null || true
fi
