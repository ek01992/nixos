#!/usr/bin/env bash
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_use.input.file_path // empty')

if [[ "$file_path" == */modules/hosts/* ]]; then
  echo "Architecture note: modules/hosts/ should only contain host-specific hardware config, hostname, and imports — not feature configuration. Prefer creating a module in modules/features/<name>.nix and adding it to the host's imports list."
fi
