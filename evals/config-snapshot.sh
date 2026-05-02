#!/usr/bin/env bash
# Smoke-test: eval key config attributes to verify they evaluate correctly
set -euo pipefail

echo "==> nixos-wsl stateVersion"
nix eval .#nixosConfigurations.nixos-wsl.config.system.stateVersion

echo "==> nixxy stateVersion"
nix eval .#nixosConfigurations.nixxy.config.system.stateVersion

echo "==> nixxy hostname"
nix eval .#nixosConfigurations.nixxy.config.networking.hostName

echo "==> nixos-wsl hostname"
nix eval .#nixosConfigurations.nixos-wsl.config.networking.hostName

echo "==> all evals passed"
