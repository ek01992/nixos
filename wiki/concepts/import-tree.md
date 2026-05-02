---
title: import-tree
type: concept
updated: 2026-05-01
sources:
  - flake.nix
  - CLAUDE.md
---

# import-tree

Auto-discovers and imports every `.nix` file under a directory as a [[concepts/flake-parts]] module.  
Input: `github:vic/import-tree`

## How It Works

```nix
outputs = inputs:
  inputs.flake-parts.lib.mkFlake { inherit inputs; }
    (inputs.import-tree ./modules);
```

`inputs.import-tree ./modules` recursively finds all `.nix` files under `modules/`, imports each one, and returns them as a list that `mkFlake` merges. The result is identical to manually listing every file in an `imports = [ ... ]` array — but automatic.

## Adding a New Module

1. Create the file under `modules/` (any subdirectory)
2. `git add <file>` — flakes require files to be tracked by Git
3. `nix flake check` — the file is now included

No registration step. No import list to update.

## Removal / Rename

Removing a file from `modules/` automatically un-includes it from the flake after the next build. Just `git rm` or move the file and re-stage.

## Pure Eval Constraint

Nix's pure evaluation mode (enforced by flakes) ignores untracked files. This is the most common footgun: create a file, run `nix flake check`, get "module not found" — because the file wasn't staged. `git add` first, always.

## See Also

- [[concepts/flake-parts]] — the framework import-tree feeds into
- [[concepts/dendritic-pattern]] — the architectural pattern this enables
