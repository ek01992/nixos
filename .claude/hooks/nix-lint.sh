#!/usr/bin/env bash
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_use.input.file_path // empty')

if [[ -n "$file_path" && "$file_path" == *.nix ]]; then
  repo_root="/home/erik/nixos"
  deadnix_out=$(deadnix "$repo_root" 2>&1)
  statix_out=$(statix check "$repo_root" 2>&1)

  if [[ -n "$deadnix_out" || -n "$statix_out" ]]; then
    echo "=== nix lint ==="
    [[ -n "$deadnix_out" ]] && echo "deadnix: $deadnix_out"
    [[ -n "$statix_out" ]] && echo "statix: $statix_out"
  fi
fi
