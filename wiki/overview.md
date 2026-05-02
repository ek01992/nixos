---
title: System Overview
type: overview
updated: 2026-05-01
sources:
  - flake.nix
  - CLAUDE.md
---

# System Overview

A NixOS flake configuration for two machines, built with [[concepts/flake-parts]] and [[concepts/import-tree]]. Every `.nix` file under `modules/` is automatically discovered and merged — no explicit import list to maintain.

## Hosts

| Host | Type | Display | Key features |
|---|---|---|---|
| [[hosts/nixos-wsl]] | WSL2 on Windows | None | headless, shared `/mnt/d/wsl/shared` |
| [[hosts/nixxy]] | Bare metal (Intel) | Niri Wayland | pipewire, firefox, [[features/niri]], [[features/noctalia]] |

## Flake Inputs

| Input | Pin | Purpose |
|---|---|---|
| `nixpkgs` | nixos-unstable | Primary package set |
| `flake-parts` | latest | Modular flake composition |
| `import-tree` | latest | Auto-discovers `modules/` |
| `nixos-wsl` | 2511.7.1 (pinned) | WSL2 NixOS support |
| `wrapper-modules` (BirdeeHub) | latest | Declarative app wrappers |

`nixos-wsl` and `wrapper-modules` both follow `nixpkgs` to avoid duplicate copies of nixpkgs in the closure.

## Module Graph

```
flake.nix
└── import-tree → modules/
    ├── parts.nix           (systems: x86_64-linux, aarch64-linux)
    ├── common.nix          → flake.nixosModules.common
    ├── hosts/wsl/          → flake.nixosConfigurations.nixos-wsl
    │   ├── default.nix
    │   ├── configuration.nix
    │   └── hardware.nix
    ├── hosts/nixxy/        → flake.nixosConfigurations.nixxy
    │   ├── default.nix
    │   ├── configuration.nix
    │   └── hardware.nix
    └── features/
        ├── niri.nix        → flake.nixosModules.niri + perSystem.packages.myNiri
        └── noctalia/
            ├── noctalia.nix → perSystem.packages.myNoctalia
            └── noctalia.json (bar/widget settings)
```

## Architectural Pattern

This config uses the [[concepts/dendritic-pattern]]: every `.nix` file is a `flake-parts` module that exports outputs directly to the flake's top level. Modules cross-reference each other via `self.nixosModules.<name>` and `self'.packages.<name>` — no relative imports needed.

Application configs are bundled into wrapped packages ([[concepts/wrapper-modules]]) rather than managed by Home Manager or dotfiles. `myNiri` and `myNoctalia` carry their configs inside the package derivation, making them portable and reproducible.

## Common Commands

```bash
nix flake check                          # validate flake
nixos-rebuild build --flake .#nixos-wsl  # build (no switch)
nixos-rebuild build --flake .#nixxy
sudo nixos-rebuild switch --flake .#nixos-wsl
sudo nixos-rebuild switch --flake .#nixxy
nixfmt-tree                              # format all .nix files
nix build .#packages.x86_64-linux.myNiri
nix build .#packages.x86_64-linux.myNoctalia
```

Shell aliases (from [[modules/common]]): `nrb`, `nrs`, `nfc`, `nfu`.
