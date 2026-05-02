---
title: Scaffolding System
type: concept
updated: 2026-05-01
sources:
  - CLAUDE.md
  - scripts/new-host.sh
  - scripts/new-feature.sh
  - scripts/new-devshell.sh
  - .claude/skills/nixos-scaffold/SKILL.md
---

# Scaffolding System

Three bash scripts that generate boilerplate for new flake components. Templates match the exact repo conventions — correct module headers, naming patterns, and git staging included. Designed for AI agent use during development workflows to reduce token consumption and avoid reconstructing patterns from scratch.

Agent interface: `/nixos-scaffold` skill (routes to the correct script with guided output).

## Scripts

### `scripts/new-host.sh <hostname> [bare-metal|wsl]`

Creates `modules/hosts/<hostname>/` with three files:

| File | Content |
|---|---|
| `default.nix` | `flake.nixosConfigurations.<hostname>` — wires `nixosSystem` to the Configuration module |
| `configuration.nix` | `flake.nixosModules.<hostname>Configuration` — imports, user `erik`, stateVersion |
| `hardware.nix` | `flake.nixosModules.<hostname>Hardware` — boot, filesystems, swap with TODO UUID placeholders |

**bare-metal** variant: systemd-boot, networkmanager, Intel microcode, `/boot` (vfat) + `/` (ext4) stubs.  
**wsl** variant: `inputs.nixos-wsl.nixosModules.default`, `wsl.enable`, WSL-specific filesystem mounts (`/mnt/wsl` tmpfs, `/usr/lib/wsl/drivers` 9p).

Required post-scaffold edits: replace `TODO-ROOT-UUID`, `TODO-BOOT-UUID`, `TODO-SWAP-UUID` with real UUIDs (`lsblk -o NAME,UUID`).

### `scripts/new-feature.sh <name> [mode]`

Default mode: `--both`

| Mode | Output |
|---|---|
| `--nixos-module-only` | `modules/features/<name>.nix` with `flake.nixosModules.<name>` only |
| `--package-only` | `modules/features/<name>.nix` with `perSystem.packages.<name>` (mkDerivation stub) |
| `--both` | Both sections in one file — NixOS module + package (niri.nix pattern) |
| `--wrapped <wrapper>` | `modules/features/<name>/` dir with `<name>.nix` (wrapper-modules call) + `<name>.json` stub |

For `--wrapped`, the wrapper name is passed to `inputs.wrapper-modules.wrappers.<wrapper>.wrap`. See [[concepts/wrapper-modules]] for available wrappers.

To enable a feature on a host: add `self.nixosModules.<name>` to imports in `modules/hosts/<hostname>/configuration.nix`.

### `scripts/new-devshell.sh <name>`

Creates `modules/devshells/<name>.nix` with `perSystem.devShells.<name>` using `pkgs.mkShell`. The `modules/devshells/` directory is auto-discovered by [[concepts/import-tree]] — no registration needed.

Enter the shell: `nix develop .#<name>`

## Post-Scaffold Checklist

All scripts:
1. Git-stage their output automatically — no manual `git add` needed
2. Print exact next steps

Always after scaffolding:
1. Edit all `# TODO` markers in generated files
2. `nixfmt-tree` — normalize formatting
3. `nix flake check` — verify evaluation
4. `nixos-rebuild build --flake .#<hostname>` — verify full host build

## Module Naming Conventions

Derived from the `<hostname>` or `<name>` argument:

| Artifact | Pattern |
|---|---|
| `flake.nixosConfigurations.<hostname>` | matches hostname arg |
| `flake.nixosModules.<hostname>Configuration` | hostname + `Configuration` |
| `flake.nixosModules.<hostname>Hardware` | hostname + `Hardware` |
| `flake.nixosModules.<name>` | feature name |
| `perSystem.packages.<name>` | feature/package name |
| `perSystem.devShells.<name>` | devshell name |

## See Also

- [[concepts/dendritic-pattern]] — module structure these scripts generate
- [[concepts/import-tree]] — why new files are auto-discovered
- [[concepts/wrapper-modules]] — used by `--wrapped` mode
