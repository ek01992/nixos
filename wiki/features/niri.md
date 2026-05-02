---
title: Niri Compositor
type: feature
updated: 2026-05-01
sources:
  - modules/features/niri.nix
---

# Niri

Scrollable tiling Wayland compositor. Configured as a wrapped package via [[concepts/wrapper-modules]] — the configuration lives inside the derivation, not in `~/.config`.

## Exports

- `flake.nixosModules.niri` — enables the compositor system-wide
- `perSystem.packages.myNiri` — the wrapped niri package with embedded config

Used by: [[hosts/nixxy]] (imported as `self.nixosModules.niri`)

## NixOS Module

```nix
programs.niri = {
  enable = true;
  package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
};
```

The system-level `programs.niri.enable` hooks niri into PAM, session management, and the system path.

## Package: myNiri

Built with `inputs.wrapper-modules.wrappers.niri.wrap`. Settings baked in at build time:

### Startup

```nix
spawn-at-startup = [ (lib.getExe self'.packages.myNoctalia) ];
```

[[features/noctalia]] (`myNoctalia`) is declared as a runtime dependency and launched on compositor start. Using `lib.getExe` ensures niri's closure includes noctalia.

### Input

```nix
input.keyboard.xkb.layout = "us";
```

### Layout

```nix
layout.gaps = 5;
```

### Xwayland

```nix
xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
```

Niri doesn't handle Xwayland itself. `xwayland-satellite` bridges X11 apps into the Wayland session.

### Keybinds

| Keybind | Action |
|---|---|
| `Mod+Return` | spawn `kitty` terminal |
| `Mod+Q` | close focused window |
| `Mod+S` | toggle noctalia launcher (`myNoctalia ipc call launcher toggle`) |

`Mod` is the Super/Windows key by default in niri.

## Cross-references

- Runtime dependency: [[features/noctalia]]
- Only active on: [[hosts/nixxy]]
- Wrapping mechanism: [[concepts/wrapper-modules]]
