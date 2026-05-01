---
name: verification-loop
description: NixOS flake verification — flake check, host builds, format
---

# NixOS Verification Loop

Run after any .nix change, before committing.

## Phase 1: Flake Structural Check
```bash
nix flake check
```
Catches evaluation errors, missing outputs, type errors.

## Phase 2: Host Builds
```bash
nixos-rebuild build --flake .#nixos-wsl
nixos-rebuild build --flake .#nixxy
```
Confirms both hosts build successfully without switching.

## Phase 3: Format
```bash
nixfmt-tree
```
Formats all .nix files. Re-stage if any files change.

## Phase 4: Diff Review
```bash
git diff --stat
```
Review for unintended changes.

## Output

```
VERIFICATION REPORT
===================
Flake check:   [PASS/FAIL]
WSL build:     [PASS/FAIL]
nixxy build:   [PASS/FAIL]
Format:        [CLEAN/CHANGED]
Diff:          [X files changed]

Overall: [READY / NOT READY] to commit
```
