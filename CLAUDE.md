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

# Shell aliases (defined in modules/common.nix, available on both hosts)
# nrb  → nixos-rebuild build --flake $HOME/nixos
# nrs  → sudo nixos-rebuild switch --flake $HOME/nixos
# nfc  → nix flake check
# nfu  → nix flake update

# Evaluate a specific config option interactively
nix repl
# then inside repl: :lf .

# Debug a specific option value
nix eval .#nixosConfigurations.nixxy.config.<option>
```

## Scaffolding

Generate boilerplate for new components — templates match exact repo conventions:

```bash
# New host (creates modules/hosts/<hostname>/{default,configuration,hardware}.nix)
./scripts/new-host.sh <hostname> [bare-metal|wsl]

# New feature module
./scripts/new-feature.sh <name> [--nixos-module-only|--package-only|--both|--wrapped <wrapper>]

# New devShell (creates modules/devshells/<name>.nix)
./scripts/new-devshell.sh <name>
```

Scripts `git add` new files automatically and print exact next steps. Use `/nixos-scaffold` for guided usage.

## Architecture

### Flake structure

`flake.nix` is intentionally minimal — it passes everything to `flake-parts`, which uses `import-tree` to auto-discover and merge every `.nix` file under `modules/` as a flake-parts module. Adding a new file to `modules/` automatically includes it; no registration step needed.

`modules/parts.nix` sets `systems = ["x86_64-linux"]` — the only file that needs changing to add a new supported architecture.

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
- **Architecture concepts**: See [[concepts/dendritic-pattern]], [[concepts/flake-parts]], and [[concepts/wrapper-modules]] in the wiki for background on structural patterns.
- **Wiki**: See `wiki/wiki-schema.md` for how to maintain and query the wiki. Read `wiki/index.md` first on any wiki query.
- **Wiki maintenance**: `/wiki-lint` — validate the wiki (broken links, stale dates, missing coverage). `/wiki-update <file>` — ingest a changed source file into the wiki.
- **Scaffolding**: `/nixos-scaffold` — generate a new host, feature module, or devShell from repo-pattern templates. Faster than reconstructing boilerplate from scratch.

## ECC Overrides (NixOS-specific)

This is a NixOS flake config repo, not a software project. The following global ECC behaviors do **not** apply here:

- **No code-reviewer, security-reviewer, or tdd-guide agents** for `.nix` file edits — they add cost without actionable output on config files. Config correctness is validated by `nix flake check` and `nixos-rebuild build`.
- **No 80% test coverage or TDD requirements** — NixOS configs don't have unit tests. Use `nix flake check` + build validation instead.
- **No development-workflow research phase** (gh search, library docs, package registries) for Nix module changes — the `nixos` MCP tool is the correct lookup path.
- **Wiki-first lookups**: For any question about host configs, module structure, feature details, or architecture — read `wiki/index.md` first and navigate to the relevant page. Read source files directly only when the wiki page is insufficient or marked stale.
