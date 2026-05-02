---
title: Default DevShell
type: module
updated: 2026-05-01
sources:
  - modules/devshells/default.nix
---

# Default DevShell

Exposes `perSystem.devShells.default` — a development shell for working on this NixOS flake config. Enter it with `nix develop` from the repo root.

## What It Provides

| Package | Purpose |
|---|---|
| `claude-code-nix` | Claude Code CLI (from `github:sadjow/claude-code-nix`) |
| `treefmt` | Multi-formatter runner |
| `nixfmt-tree` | Formats all `.nix` files in the tree |
| `nixfmt` | Nix formatter (used by nixfmt-tree) |
| `neovim` | Editor (sets `$EDITOR=nvim`) |
| `git` | Version control |
| `gh` | GitHub CLI |
| `nil` | Nix language server (LSP) |
| `ripgrep` | Fast grep |
| `fd` | Fast find |
| `jq` | JSON processor |

## Shell Hook Behaviour

On `nix develop`, the hook:
1. Sets `EDITOR=nvim`
2. Prepends `(nixos-dev)` to the shell prompt
3. Warns if `ANTHROPIC_API_KEY` is unset (Claude Code will not function without it)
4. Prints a reminder of the common workflow commands

## Usage

```bash
nix develop          # enter the devshell from repo root
```

Inside the shell, all packages above are on `PATH` and the shell hook runs automatically.

## Dependencies

- `claude-code-nix` flake input (`flake.nix`) — provides the Claude Code CLI package; follows `nixpkgs` to avoid duplicate closures
- All other packages come from `nixpkgs` directly

## Cross-References

- [[overview]] — lists this devshell in the Module Graph and Flake Inputs table
- [[concepts/dendritic-pattern]] — `perSystem.devShells.*` follows the same auto-discovery pattern as packages and NixOS modules
