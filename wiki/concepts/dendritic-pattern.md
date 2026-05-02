---
title: Dendritic Pattern
type: concept
updated: 2026-05-01
sources:
  - flake.nix
---

# Dendritic Pattern

The structural philosophy behind this flake: every `.nix` file in `modules/` is a [[concepts/flake-parts]] module that exports outputs directly to the flake's top level.

## Core Properties

**No manual import lists.** [[concepts/import-tree]] auto-discovers and merges every `.nix` file under `modules/`. Adding a new file automatically includes it — just `git add` it first (flakes ignore unstaged files).

**No relative imports.** Modules cross-reference each other via `self.nixosModules.<name>` (for NixOS modules) and `self'.packages.<name>` (for packages in the same system). No `../sibling.nix` paths.

**Every file is an output.** Modules export to `flake.nixosModules.*` or `perSystem.packages.*` rather than being internal implementations. This makes configs shareable externally.

## Standard Module Boilerplate

```nix
{ self, inputs, ... }: {
  perSystem = { config, self', inputs', pkgs, system, ... }: {
    # system-specific outputs (packages, devShells)
  };
  flake = {
    # top-level outputs (nixosConfigurations, nixosModules)
  };
}
```

`self` = the whole flake's outputs (use for `self.nixosModules.*`)  
`self'` = outputs for the current system (use for `self'.packages.*` inside `perSystem`)  
`inputs` = all flake inputs

## Cross-referencing Examples

```nix
# Inside perSystem — reference a package on the same system
spawn-at-startup = [ (lib.getExe self'.packages.myNoctalia) ];

# Inside flake.* — reference a package (must specify system)
package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
```

## Pure Eval Gotcha

Flakes use pure evaluation and only see files tracked by Git. After creating a new `.nix` file:
```bash
git add modules/my-new-module.nix   # must do this BEFORE nix flake check
nix flake check
```

## Why "Dendritic"

Like dendrites in neurons — each module is a self-contained branch that connects to the whole via a consistent interface, with flake-parts doing the merging at the center.

## See Also

- [[concepts/flake-parts]] — the merging framework
- [[concepts/import-tree]] — the auto-discovery mechanism
- [[overview]] — how the pattern is applied in this repo
