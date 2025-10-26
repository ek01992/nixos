# Justfile for NixOS Personal Homelab

# Set shell to bash for consistency
set shell := ["bash", "-c"]

# Define flake path (current directory)
flake_path := "."

# Default task: list all available tasks
default:
    @just --list

# Build system configuration
build:
    nix build .#nixosConfigurations.xps.config.system.build.toplevel

# Switch to new configuration
switch:
    sudo nixos-rebuild switch --flake {{flake_path}}

# Update flake inputs
update:
    nix flake update

# Check Nix syntax and structure
check:
    nix flake check

# Format all .nix files
fmt:
    nix fmt

# Clean old generations and garbage collect
clean:
    sudo nix-collect-garbage --delete-old

# Git operations
branch name:
    git checkout -b {{name}}

commit message:
    git commit -m "{{message}}"

push:
    git push

pull:
    git pull

# Install packages
install package:
    nix-env -iA nixpkgs.{{package}}

# Show system information
info:
    nix flake show

# Test configuration without applying
test:
    nix build .#nixosConfigurations.xps.config.system.build.toplevel --dry-run
