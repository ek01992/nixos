---
name: update-inputs
description: Update flake inputs with visibility into what changed, then optionally build before switching
---

When the user invokes /update-inputs, follow this workflow:

## Step 1: Capture current state
```bash
cd ~/nixos
git stash list | head -3  # just for awareness
cp flake.lock flake.lock.bak 2>/dev/null || true
```

## Step 2: Update inputs
Run `nix flake update` (alias: `nfu`). Wait for it to complete.

## Step 3: Show what changed
```bash
cd ~/nixos && git diff flake.lock
```

Parse the diff to extract:
- Which inputs changed (e.g. `nixpkgs`, `home-manager`, `nix-on-droid`)
- Old vs new git revision for each

For `nixpkgs` changes specifically, use `mcp__nixos__nix` to look up what changed:
```
nix {"action":"channels"}
```
Then check key packages the user cares about (fish, helix, niri) via `mcp__nixos__nix_versions` if relevant.

## Step 4: Summarize and ask
Present a short summary:
- Which inputs updated
- Any notable package version changes found
- Ask: "Build both hosts before switching? (nix build .#nixosConfigurations.nixos-wsl.config.system.build.toplevel + nixxy)"

If user says yes, run the builds sequentially and report success/failure before suggesting `nrs`.
If user says no, remind them to run `nrs` and watch for errors.

## Important
- Never run `nrs` (sudo nixos-rebuild switch) automatically — always leave that to the user.
- Clean up `flake.lock.bak` after the workflow: `rm -f ~/nixos/flake.lock.bak`
