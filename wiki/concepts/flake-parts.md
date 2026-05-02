---
title: flake-parts
type: concept
updated: 2026-05-01
sources:
  - flake.nix
  - modules/parts.nix
---

# flake-parts

The modular flake composition framework used by this config.  
Input: `github:hercules-ci/flake-parts`

## What It Does

`flake-parts` turns a flake into a **module system** — the same NixOS-style option evaluation, but for flake outputs.

- **`perSystem`**: abstracts over system architectures. Code inside `perSystem` runs once per system (`x86_64-linux`, `aarch64-linux`, …), producing system-scoped outputs like `packages.x86_64-linux.myNiri`.
- **Merging**: multiple files can define `perSystem.packages.*` and `flake.nixosModules.*` — flake-parts merges them, just like `environment.systemPackages` merges across NixOS modules.
- **Type safety**: standard flake attributes are defined as typed options, so misconfigured outputs get clear error messages instead of cryptic Nix eval failures.

## Entry Point

```nix
# flake.nix
outputs = inputs:
  inputs.flake-parts.lib.mkFlake { inherit inputs; }
    (inputs.import-tree ./modules);
```

`mkFlake` takes a module (or list of modules, or in this case the output of [[concepts/import-tree]]) and produces the standard flake `outputs` attrset.

## Systems Configuration

`modules/parts.nix` is the only place that sets supported architectures:

```nix
{ config = { systems = [ "x86_64-linux" ]; }; }
```

Currently only `x86_64-linux`. Adding a new architecture: edit just this file.

## Module Args

Each module in `modules/` receives:
- `self` — the flake's full output (all `flake.*` exports)
- `inputs` — all flake inputs
- `config`, `lib` — standard module system args

Inside `perSystem`, additional args:
- `pkgs` — nixpkgs for the current system
- `self'` — flake outputs scoped to the current system
- `system` — the current system string

## See Also

- [[concepts/dendritic-pattern]] — how this config uses flake-parts
- [[concepts/import-tree]] — feeds modules into flake-parts
