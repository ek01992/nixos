# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Build (dry-run, no switch)
nix build .#nixosConfigurations.nixos-wsl.config.system.build.toplevel
nix build .#nixosConfigurations.nixxy.config.system.build.toplevel
# or with alias:
nrb                          # nixos-rebuild build --flake $HOME/nixos

# Switch (requires sudo)
nrs                          # sudo nixos-rebuild switch --flake $HOME/nixos

# Flake
nfc                          # nix flake check
nfu                          # nix flake update

# Dev shell (includes nil, deadnix, statix, nixfmt, treefmt, claude-code-nix)
nix develop

# Format
nixfmt-tree .               # or treefmt

# Lint
deadnix .                   # find dead code
statix check .              # find anti-patterns
nil diagnostics             # LSP-based checks
```

## Architecture

**Framework:** `flake-parts` + `import-tree` — every `.nix` file under `modules/` is auto-discovered and merged into flake outputs. No manual imports needed; adding a file is sufficient.

**Module shape:** Each file exports flake-parts-style attrs:
- `flake.nixosModules.NAME = { ... }` — NixOS module (system + home-manager config together)
- `perSystem = { pkgs, ... }: { ... }` — per-arch outputs (packages, devShells)
- `config.systems = [ "x86_64-linux" ]` — flake-parts config (`modules/parts.nix`)

**Hosts:**
- `nixos-wsl` — WSL2, NVIDIA CUDA, no SSH/firewall, shared mount at `/mnt/d/wsl/shared`
- `nixxy` — desktop, Intel, systemd-boot EFI, Niri Wayland compositor, PipeWire, greetd+tuigreet

**Host layout** (`modules/hosts/<name>/`): three files — `default.nix` (imports), `hardware.nix` (boot/filesystems/hostname), `configuration.nix` (home-manager + system config). Dirs: `wsl/`, `nixxy/`.

**Feature modules** (`modules/features/`): Each is a self-contained NixOS module that configures both system and `home-manager.users.erik` in one place.
- `home.nix` — bootstraps home-manager (`useGlobalPkgs`, `useUserPackages`)
- `shell.nix` — Fish shell + Starship; defines shell aliases (`nrb`, `nrs`, `nfc`, `nfu`)
- `editor.nix` — sets Helix as `$EDITOR`
- `niri.nix` — builds custom niri package via `wrapper-modules.niri.wrap` (keybindings, layout, workspaces); also enables system-level niri + polkit

**Common module** (`modules/common.nix`): shared across all hosts — experimental nix features, base packages, git config, SSH hardening, timezone/locale, firewall.

**Adding a new feature:** Use `/new-feature` skill, or manually create `modules/features/myfeature.nix` exporting `flake.nixosModules.myfeature` and add to host `imports`.

**Devshells** (`modules/devshells/`): perSystem devShells via `pkgs.mkShell`. Each shell is a separate `.nix` file; auto-discovered by import-tree.

**Nix channel:** `nixpkgs` tracks `nixos-unstable`. State version: `26.05`.

## Tool Reference

**Search:** Use `mgrep "natural language query"` — never raw `grep`. Web lookups: `mgrep --web --answer "query"`.
**Nix packages/options:** Use `mcp__nixos__nix` MCP tool — faster and more current than web search.
**Memory:** `mem-search` skill for cross-session context; `ctx_search` for current session only.
**File reads:** Use the `Read` tool — not `cat` via Bash.
**Scaffolding skills:** `/new-feature`, `/new-host`, `/new-devenv` — scaffold new modules following repo patterns; `/update-inputs` — safe flake input updates with diff preview.

**Planning skills:**
- `writing-plans` — use when you have a spec/requirements for a multi-step implementation task
- `pathfinder` — use for codebase architecture exploration and navigation
- `make-plan` — use when a plan needs to persist across sessions (stores in memory system)

**Exploration strategy (most to least token-efficient):**
1. Single known symbol/path → `mgrep "query"` via Bash (no agent, no context bloat)
2. Multi-command research → `ctx_batch_execute` (bundles commands, auto-indexes, keeps output sandboxed)
3. Follow-up questions on indexed data → `ctx_search` (no new agent spawn)
4. Open-ended cross-file discovery → Explore agent with breadth `"quick"` for narrow scope, `"medium"` otherwise
