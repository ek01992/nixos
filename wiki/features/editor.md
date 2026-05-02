---
title: Editor (Helix)
type: feature
updated: 2026-05-02
sources:
  - modules/features/editor.nix
---

# Editor (Helix)

Configures Helix as the default editor for user `erik` via home-manager. Requires [[features/home]] (the home-manager bridge) to be imported by the host.

## Exports

- `flake.nixosModules.editor` — enables and sets Helix as the default editor

Used by: [[hosts/nixxy]], [[hosts/nixos-wsl]] (imported as `self.nixosModules.editor`)

## What It Configures

```nix
home-manager.users.erik.programs.helix = {
  enable = true;
  defaultEditor = true;
};
```

`defaultEditor = true` sets the `EDITOR` environment variable to `hx`, making Helix the default for tools that respect `$EDITOR` (git commit messages, etc.).

## Dependencies

Requires [[features/home]] to be imported first — that module imports `inputs.home-manager.nixosModules.home-manager` and sets up the `home-manager.users.erik` namespace that this module writes into.

## Cross-references

- Depends on: [[features/home]]
- Active on: [[hosts/nixxy]], [[hosts/nixos-wsl]]
