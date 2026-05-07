#!/usr/bin/env bash
# Run a quick flake eval check if any .nix files were modified since HEAD.
cd /home/erik/nixos || exit 0

if ! git diff --name-only HEAD 2>/dev/null | grep -q '\.nix$'; then
  exit 0
fi

eval_out=$(nix eval .#nixosConfigurations --apply builtins.attrNames 2>&1)
if [[ $? -ne 0 ]]; then
  echo "=== flake eval warning ==="
  echo ".nix files were modified and nix eval .#nixosConfigurations failed."
  echo "Fix before running nrs:"
  echo "$eval_out"
fi
