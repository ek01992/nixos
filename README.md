# nixos

Personal NixOS flake for two machines: `nixxy` (desktop) and `nixos-wsl` (WSL2 dev box).

## Hosts

| Host | Platform | Purpose |
|------|----------|---------|
| `nixxy` | x86_64-linux, EFI | Desktop workstation — Niri Wayland, PipeWire, greetd |
| `nixos-wsl` | x86_64-linux, WSL2 | Development environment — NVIDIA/CUDA, no SSH/firewall |

## Architecture

Built on [flake-parts](https://github.com/hercules-ci/flake-parts) + [import-tree](https://github.com/vic/import-tree). Every `.nix` file under `modules/` is auto-discovered and merged — no manual imports needed.

**Module shapes:**
- `flake.nixosModules.NAME` — NixOS module (system + home-manager config in one file)
- `perSystem = { pkgs, ... }: { ... }` — per-arch outputs (packages, devShells)

**Host layout** (`modules/hosts/<name>/`):
- `default.nix` — imports list
- `hardware.nix` — boot, filesystems, hostname
- `configuration.nix` — home-manager + system config

## Feature Modules

| Module | Purpose |
|--------|---------|
| `common.nix` | Shared baseline — nix settings, base packages, git, SSH hardening, timezone/locale, firewall |
| `home.nix` | Bootstraps home-manager (`useGlobalPkgs`, `useUserPackages`) |
| `shell.nix` | Fish shell + Starship prompt; defines `nrb`/`nrs`/`nfc`/`nfu` aliases |
| `editor.nix` | Sets Helix as `$EDITOR` |
| `niri.nix` | Niri Wayland compositor — keybindings, xwayland-satellite, polkit |

## Usage

```bash
# Build (dry-run)
nix build .#nixosConfigurations.nixos-wsl.config.system.build.toplevel
nix build .#nixosConfigurations.nixxy.config.system.build.toplevel
# or: nrb

# Switch
sudo nixos-rebuild switch --flake ~/nixos
# or: nrs

# Check flake
nix flake check   # or: nfc

# Update inputs
nix flake update  # or: nfu

# Format
nixfmt-tree .

# Lint
deadnix .
statix check .
```

## Dev Shell

```bash
nix develop
```

Provides: `claude-code`, `nil`, `deadnix`, `statix`, `nixfmt`, `treefmt`, `neovim`, `git`, `gh`, `bun`, `nodejs`, `mgrep`, `ripgrep`, `fd`, `jq`, `python3`

## Flake Inputs

| Input | Purpose |
|-------|---------|
| `nixpkgs` | nixos-unstable channel |
| `flake-parts` | Modular flake framework |
| `import-tree` | Auto-discovery of `modules/` |
| `nixos-wsl` | WSL2 NixOS support (v2511.7.1) |
| `home-manager` | User environment management |
| `wrapper-modules` | Nix wrapper abstractions (used by niri) |
| `claude-code-nix` | Claude Code CLI package |

All inputs follow `nixpkgs` to avoid duplicate evaluations.
