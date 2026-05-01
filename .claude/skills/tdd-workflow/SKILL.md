---
name: tdd-workflow
description: NixOS config validation workflow — define intent, build, verify on system
---

# NixOS Config Validation Workflow

NixOS configs don't have unit tests. Validation = build + eval + (optionally) VM test.

## Step 1: Define Intent

State what the change should produce:
- Which hosts are affected?
- What option/package/service is being added or changed?
- What's the observable effect on the running system?

## Step 2: Evaluate (fast feedback)
```bash
nix eval .#nixosConfigurations.<host>.config.<option>
```
Quick check that the option evaluates to the expected value.

## Step 3: Build
```bash
nixos-rebuild build --flake .#<host>
```
Full derivation build without switching. Catches missing packages, bad references.

## Step 4: VM Test (for service-level changes)
```bash
nixos-rebuild build-vm --flake .#<host>
```
Boot a throwaway VM to verify services start correctly.

## Step 5: Apply & Verify
```bash
sudo nixos-rebuild switch --flake .#<host>
```
Only on the target host. Confirm the service/package behaves as intended.

## Step 6: Format + Commit
```bash
nixfmt-tree
git add <changed files>
git commit -m "feat: <description>"
```
