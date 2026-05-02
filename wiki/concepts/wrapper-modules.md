---
title: wrapper-modules (BirdeeHub)
type: concept
updated: 2026-05-01
sources:
  - flake.nix
  - modules/features/niri.nix
  - modules/features/noctalia/noctalia.nix
---

# wrapper-modules

A Nix library by BirdeeHub for declaratively wrapping applications with their configuration baked into the derivation.  
Input: `github:BirdeeHub/nix-wrapper-modules`  
Follows `nixpkgs` from the main flake (no duplicate nixpkgs in closure).

## The Problem It Solves

Most apps read config from `~/.config/<app>/` at runtime. This creates a dependency on the user's home directory and requires Home Manager or dotfiles management. `wrapper-modules` eliminates this by bundling the configuration *inside the package* at build time — making the app "homeless" (no dotfile dependency).

## How It Works

Each supported application has a `wrappers.<app>.wrap` function:

```nix
packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
  inherit pkgs;
  settings = { /* config attrset */ };
};
```

The wrapper:
1. Takes a settings attrset (or JSON, depending on the wrapper)
2. Generates the app's native config format at build time (KDL for niri, JSON for noctalia)
3. Produces a derivation that wraps the original binary, pointing it to the generated config
4. The result is a standard Nix package — buildable, cacheable, system-agnostic

## Applications Wrapped in This Repo

| Package | Wrapper | Config source |
|---|---|---|
| [[features/niri]] (`myNiri`) | `wrappers.niri.wrap` | Nix attrset in `niri.nix` |
| [[features/noctalia]] (`myNoctalia`) | `wrappers.noctalia-shell.wrap` | `noctalia.json` (read at build time) |

## Key Utilities

`lib.getExe`: resolves an executable path and makes it a runtime dependency of the wrapper. Used in niri to reference noctalia and kitty:
```nix
spawn-at-startup = [ (lib.getExe self'.packages.myNoctalia) ];
"Mod+Return".spawn-sh = lib.getExe pkgs.kitty;
```

This ensures those programs are in niri's closure — they don't need to be separately installed.

## Benefits Over Home Manager

- Config is version-controlled alongside the system config (in this flake)
- No activation scripts; changes take effect on next `nixos-rebuild switch`
- Packages are portable: `nix build .#myNiri` works on any x86_64-linux machine
- App config follows the package, not the user's home directory

## See Also

- [[features/niri]] — niri wrapper usage
- [[features/noctalia]] — noctalia wrapper + JSON config workflow
- [[concepts/dendritic-pattern]] — architectural context
