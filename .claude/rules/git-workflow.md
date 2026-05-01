# Git Workflow (NixOS repo)

## Commit Style

This repo uses short, informal commit messages — **not** conventional commits format.

| Prefix | When |
|--------|------|
| `fix` | iterative fixes (most common) |
| `feat: <desc>` | new capability |
| `rm <thing>` | removal |
| `lock` | flake.lock update only |
| `treefmt` | formatting pass only |
| `refactor: <desc>` | restructuring |

Keep messages short and direct. No body paragraph unless explaining a non-obvious decision.

## Pre-commit

1. `nix flake check`
2. `nixos-rebuild build --flake .#nixos-wsl`
3. `nixos-rebuild build --flake .#nixxy`
4. `nixfmt-tree`
