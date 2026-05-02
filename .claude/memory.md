# Project Memory: NixOS Config

## Hosts

- `nixos-wsl` (dir: `modules/hosts/wsl/`) — WSL2, headless, no display server
- `nixxy` (dir: `modules/hosts/nixxy/`) — bare-metal desktop, greetd + niri Wayland, pipewire

## Key Architectural Decisions

**home-manager as NixOS module, not standalone** — avoids double-activation. Import via `flake.nixosModules.home`, not `home-manager.nixosModules.home-manager`.

**import-tree auto-discovery** — every `.nix` file under `modules/` is automatically loaded as a flake-parts module. No manual registration needed. After adding a new file: `git add <file>` before `nix flake check`.

**noctalia config via JSON** — `modules/features/noctalia/noctalia.json` holds all bar/widget settings. Edit the JSON directly; the `.nix` reads it at build time.

**Shell aliases on both hosts** — `nrb`, `nrs`, `nfc`, `nfu` defined in `modules/common.nix`.

## Skill Quick Reference

| Situation | Skill |
|---|---|
| Any structural/pattern question | `/nixos-patterns` |
| Scaffold new host/feature/devshell | `/nixos-scaffold` |
| Source file changed → update wiki | `/wiki-update <file>` |
| Before ANY commit | `/verification-loop` |
| Update flake inputs | `/nix-update` |
| Periodic wiki hygiene | `/wiki-lint` |
| Comprehensive config audit | `/nixos-audit` |

## ECC Overrides (enforced in CLAUDE.md)

- No code-reviewer/security-reviewer/tdd-guide for `.nix` edits
- No 80% test coverage or TDD — validate with `nix flake check` + builds
- No development-workflow research phase — use `nixos` MCP tool instead
