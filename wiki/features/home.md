---
title: Home Manager Bridge
type: feature
updated: 2026-05-02
sources:
  - modules/features/home.nix
---

# Home Manager Bridge

Bridges home-manager into the NixOS module system. Must be imported by any host that uses `home-manager.users.erik.*` options (i.e., [[features/shell]] and [[features/editor]]).

## Exports

- `flake.nixosModules.home` — home-manager integration for user `erik`

Used by: [[hosts/nixxy]], [[hosts/nixos-wsl]] (imported as `self.nixosModules.home`)

## What It Configures

```nix
imports = [ inputs.home-manager.nixosModules.home-manager ];

home-manager = {
  useGlobalPkgs = true;      # shares nixpkgs from NixOS config; no separate pkgs instance
  useUserPackages = true;     # installs user packages into /etc/profiles (not ~/.nix-profile)
  backupFileExtension = "backup";  # renames conflicting files instead of failing
  users.erik = {
    home = {
      username = "erik";
      homeDirectory = "/home/erik";
      stateVersion = "26.05";
    };
  };
};
```

## Role in the Import Chain

This module is the home-manager entry point. The import order within a host's `configuration.nix`:

```
self.nixosModules.home      ← imports home-manager module, sets up users.erik namespace
self.nixosModules.shell     ← writes into home-manager.users.erik.programs.fish
self.nixosModules.editor    ← writes into home-manager.users.erik.programs.helix
```

NixOS merges all `home-manager.*` option assignments; order doesn't matter as long as `home` is in the imports.

## Input

Uses `inputs.home-manager` from `flake.nix` — `nix-community/home-manager` pinned to follow `nixpkgs`.

## Cross-references

- Required by: [[features/shell]], [[features/editor]]
- Active on: [[hosts/nixxy]], [[hosts/nixos-wsl]]
