# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A NixOS flake configuration for two hosts (`nixos-wsl` and `nixxy`), built with `flake-parts` and `import-tree`. Every `.nix` file under `modules/` is automatically loaded as a flake-parts module — no explicit import list to maintain.

## Common Commands

```bash
# Validate the flake (check for evaluation errors)
nix flake check

# Build a host configuration (without switching)
nixos-rebuild build --flake .#nixos-wsl
nixos-rebuild build --flake .#nixxy

# Apply configuration to the running system
sudo nixos-rebuild switch --flake .#nixos-wsl   # on WSL
sudo nixos-rebuild switch --flake .#nixxy        # on nixxy

# Build a specific package
nix build .#packages.x86_64-linux.myNiri
nix build .#packages.x86_64-linux.myNoctalia

# Format all Nix files
nixfmt-tree

# Evaluate a specific config option interactively
nix repl
# then inside repl: :lf .

# Debug a specific option value
nix eval .#nixosConfigurations.nixxy.config.<option>
```

## Architecture

### Flake structure

`flake.nix` is intentionally minimal — it passes everything to `flake-parts`, which uses `import-tree` to auto-discover and merge every `.nix` file under `modules/` as a flake-parts module. Adding a new file to `modules/` automatically includes it; no registration step needed.

`modules/parts.nix` sets `systems = ["x86_64-linux" "aarch64-linux"]` — the only file that needs changing to add a new supported architecture.

### Module conventions

Each `.nix` file receives `{ self, inputs, ... }` (flake-parts module args) and exposes outputs under `flake.*` or `perSystem`. The common patterns used here:

- **`flake.nixosModules.<name>`** — a NixOS module, importable by any `nixosConfiguration`
- **`perSystem.packages.<name>`** — a per-architecture package (e.g., wrapped niri, noctalia)

Cross-referencing packages from within modules:
- Inside `perSystem`: use `self'.packages.myTool` (auto-resolves to current system)
- Inside `flake.*` (system-agnostic context): use `self.packages.${pkgs.stdenv.hostPlatform.system}.myTool`

> **Pure eval gotcha**: flakes ignore unstaged files. After creating a new `.nix` file under `modules/`, run `git add <file>` before `nix flake check` or any build will see it.

### Host layout (`modules/hosts/<dir>/`)

Note: the directory name (`wsl`, `nixxy`) differs from the flake output name (`nixos-wsl`, `nixxy`).

| File | Role |
|---|---|
| `default.nix` | Defines `flake.nixosConfigurations.<host>`, wires together the modules |
| `configuration.nix` | Defines `flake.nixosModules.<host>Configuration` — imports hardware + features, sets users/packages/services |
| `hardware.nix` | Defines `flake.nixosModules.<host>Hardware` — boot, filesystems, swap, platform |

Hosts currently defined: `nixos-wsl` (WSL2, no display server, dir: `wsl/`) and `nixxy` (bare metal, niri Wayland, pipewire, dir: `nixxy/`).

### Shared modules (`modules/`)

- **`common.nix`** — `flake.nixosModules.common`: baseline settings imported by every host (nix flakes enabled, core packages, openssh, timezone, locale)
- **`parts.nix`** — sets supported `systems` for all `perSystem` outputs

### Feature modules (`modules/features/`)

Reusable features exposed as `flake.nixosModules.<feature>` and imported by host configurations:

- **`niri.nix`** — defines both `flake.nixosModules.niri` (enables the compositor) and `perSystem.packages.myNiri` (the wrapped niri package with keybinds, layout, and startup of myNoctalia); configures xwayland-satellite and kitty as terminal
- **`noctalia/noctalia.nix`** — defines `perSystem.packages.myNoctalia`; reads `noctalia.json` with `builtins.fromJSON` at build time and passes `.settings` to the `wrapper-modules` noctalia wrapper

### Key inputs

| Input | Purpose |
|---|---|
| `nixpkgs` | Package set — tracking **nixos-unstable** |
| `flake-parts` | Modular flake composition |
| `import-tree` | Auto-imports all `.nix` files in `modules/` |
| `nixos-wsl` | WSL2 NixOS support (pinned to `2511.7.1`) |
| `wrapper-modules` (BirdeeHub) | Wraps niri and noctalia with declarative settings |

### Noctalia configuration

`modules/features/noctalia/noctalia.json` holds all bar/widget settings. Edit the JSON directly; the `.nix` file reads it at build time.

## Claude Code Guidance

- **Package lookups**: Use the `nixos` MCP server (available in this session) — faster and more current than `nix search` or manual nixpkgs browsing.
- **Repo patterns**: Run `/nixos-patterns` to recall structural conventions, module templates, and commit style before making changes.
- **Deeper reference**: See `ARCHITECTURE.md` for background on the dendritic pattern, flake-parts internals, and wrapper-modules design.
