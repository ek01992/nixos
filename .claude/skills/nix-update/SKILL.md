---
name: nix-update
description: Update all flake inputs, verify both hosts build, then commit flake.lock — the complete lock update workflow
version: 1.0.0
source: project-local
---

# Nix Update

Updates all flake inputs and verifies the result before committing.

## Trigger Phrases

- `/nix-update`
- `"Update flake inputs"`
- `"Update flake.lock"`
- `"Run nix flake update"`
- `"Update nixpkgs"`

## Workflow

### 1. Update all inputs

```bash
nix flake update
```

This regenerates `flake.lock` with the latest commits for all inputs.

To update a single input instead:

```bash
nix flake update nixpkgs
```

### 2. Verify both hosts build

```bash
nix flake check
nixos-rebuild build --flake .#nixos-wsl
nixos-rebuild build --flake .#nixxy
```

If either build fails, report the error. Do **not** commit a broken lock file. Common failure: a nixpkgs update breaks a package version — check `nix log` and note which package.

### 3. Commit only flake.lock

```bash
git add flake.lock
git commit -m "lock"
```

Stage only `flake.lock`. Do not stage unrelated changes. The commit message is always `lock` — this is the repo convention for lock-only updates.

## Output

```
NIX UPDATE REPORT
=================
Inputs updated:  [list changed inputs from flake.lock diff]
Flake check:     [PASS/FAIL]
WSL build:       [PASS/FAIL]
nixxy build:     [PASS/FAIL]
Committed:       [yes / no — reason if no]
```

## Notes

- If only one host fails, report it and ask whether to commit anyway or revert
- After committing, offer to run `sudo nixos-rebuild switch` on the current host if the build succeeded
- Format (`nixfmt-tree`) is not needed — `flake.lock` is not a Nix source file
