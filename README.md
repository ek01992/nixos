# nixos

Declarative NixOS flake configuration for two machines, built with `flake-parts` and `import-tree`. Every `.nix` file under `modules/` is auto-discovered — no import list to maintain.

## Hosts

| Host | Type | Display | Notable |
|------|------|---------|---------|
| `nixos-wsl` | WSL2 on Windows 11 | headless | shared `/mnt/d/wsl/shared`, systemd enabled |
| `nixxy` | bare-metal Intel desktop | Niri (Wayland) | greetd + tuigreet, Pipewire, Firefox, xwayland-satellite |

## Features & Packages

| Name | Kind | What it does |
|------|------|--------------|
| `myNiri` | wrapped package | Niri compositor with keybinds, layout, and startup of `myNoctalia` baked in at build time |
| `myNoctalia` | wrapped package | Shell bar/launcher; reads `noctalia.json` at build time — edit the JSON to change widgets |
| `common` | NixOS module | Baseline for all hosts: flakes, core packages, git config, shell aliases, SSH, firewall, locale |
| `devShells.default` | dev shell | Claude Code CLI + Nix dev tools (nil, nixfmt, treefmt, ripgrep, fd, jq, gh); enter with `nix develop` |

## Architecture

`flake.nix` is intentionally minimal — it hands everything to `flake-parts`, which uses `import-tree` to merge every `.nix` under `modules/` as a module. Three patterns drive the design:

- **Auto-discovery** — drop a `.nix` in `modules/` and `git add` it; it's included automatically, no registration needed.
- **Wrapper-modules** — application config (niri keybinds, noctalia bar layout) is bundled into derivations at build time via [BirdeeHub/wrapper-modules](https://github.com/BirdeeHub/wrapper-modules), not managed by dotfiles or Home Manager.
- **Dendritic modules** — each file exposes outputs under `flake.*` or `perSystem`; hosts compose features by importing `self.nixosModules.<name>`.

Pure eval note: flakes ignore unstaged files. After creating a new `.nix`, run `git add` before `nix flake check`.

## Quick Reference

### Common commands

```bash
# Validate
nix flake check

# Build (without switching)
nixos-rebuild build --flake .#nixos-wsl
nixos-rebuild build --flake .#nixxy

# Apply to running system
sudo nixos-rebuild switch --flake .#nixos-wsl   # WSL
sudo nixos-rebuild switch --flake .#nixxy        # nixxy

# Build a specific package
nix build .#packages.x86_64-linux.myNiri
nix build .#packages.x86_64-linux.myNoctalia

# Format all .nix files
nixfmt-tree

# Enter the dev shell
nix develop
```

Shell aliases (available on both hosts after switching):

```
nrb   nixos-rebuild build --flake $HOME/nixos
nrs   sudo nixos-rebuild switch --flake $HOME/nixos
nfc   nix flake check
nfu   nix flake update
```

### Scaffolding

Scripts generate boilerplate matching repo conventions and `git add` the files automatically.

```bash
# New host
./scripts/new-host.sh <hostname> [bare-metal|wsl]

# New feature module
./scripts/new-feature.sh <name> [--nixos-module-only|--package-only|--both|--wrapped <wrapper>]

# New devShell
./scripts/new-devshell.sh <name>
```

## Further Reading

- [`wiki/overview.md`](wiki/overview.md) — full system synthesis, module graph, decision log
- [`wiki/concepts/flake-parts.md`](wiki/concepts/flake-parts.md) — how `flake-parts` and `perSystem` work here
- [`wiki/concepts/dendritic-pattern.md`](wiki/concepts/dendritic-pattern.md) — the auto-discovery module pattern
- [`wiki/concepts/wrapper-modules.md`](wiki/concepts/wrapper-modules.md) — how app config is bundled into derivations
- [`wiki/concepts/scaffolding.md`](wiki/concepts/scaffolding.md) — scaffolding scripts in detail
