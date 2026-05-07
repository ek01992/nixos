#!/usr/bin/env bash
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_use.input.file_path // empty')

if [[ "$file_path" == *"flake.lock" ]]; then
  echo '{"decision":"block","reason":"flake.lock is machine-generated. Use: nix flake update (all inputs) or nix flake lock --update-input <name> (one input)."}'
fi
