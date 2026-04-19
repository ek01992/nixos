# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

```bash
# Deploy to bare-metal machine
nixos-rebuild switch --flake .#nixxy

# Deploy to WSL environment
nixos-rebuild switch --flake .#nixos-wsl

# Build without switching (dry-run deploy)
nix build .#nixosConfigurations.nixxy.config.system.build.toplevel

# Validate the flake
nix flake check

# Update all flake inputs
nix flake update

# Update a specific input
nix flake update nixpkgs
```

## Architecture

This is a NixOS flake managed with **flake-parts** and **import-tree**. All `.nix` files under `modules/` are automatically discovered and loaded by import-tree — no manual imports required.

### Hosts

| Host | Type | Features |
|------|------|---------|
| `nixxy` | Bare-metal x86_64 | Niri (Wayland WM) + Noctalia shell |
| `nixos-wsl` | WSL2 | Minimal, no desktop |

### Three-Tier Module Pattern

Each host is composed of three layers:

1. **Hardware** (`modules/hosts/{host}/hardware.nix`) — boot loader, filesystems, kernel modules, drivers
2. **System** (`modules/hosts/{host}/configuration.nix`) — users, services, system packages, networking
3. **Features** (`modules/features/`) — composable, reusable modules imported by hosts

The host `default.nix` ties these layers together and imports relevant features.

### Feature Modules

- `modules/features/niri.nix` — Niri Wayland compositor config (keybinds, gaps, xwayland)
- `modules/features/noctalia.nix` — Noctalia desktop shell; loads settings from `noctalia.json`

Both features use the **wrapper-modules** pattern (`BirdeeHub/nix-wrapper-modules`) to inject JSON configuration into the wrapped program.

### Key Flake Inputs

| Input | Source | Purpose |
|-------|--------|---------|
| `nixpkgs` | nixos-unstable | Package set |
| `flake-parts` | hercules-ci/flake-parts | Modular flake structure |
| `import-tree` | vic/import-tree | Auto-load modules from directory |
| `nixos-wsl` | nix-community/NixOS-WSL | WSL host support |
| `wrapper-modules` | BirdeeHub/nix-wrapper-modules | Wrap Niri/Noctalia with config |

### Adding a New Host

1. Create `modules/hosts/{hostname}/hardware.nix`, `configuration.nix`, `default.nix`
2. Export `flake.nixosConfigurations.{hostname}` from `default.nix`
3. import-tree picks it up automatically — no edits to `flake.nix` needed

### Adding a New Feature Module

1. Create `modules/features/{name}.nix`
2. Export as `flake.nixosModules.{name}` if it needs to be referenced by hosts
3. Import it in the relevant host's `default.nix`
