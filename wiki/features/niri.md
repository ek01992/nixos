---
title: Niri Compositor
type: feature
updated: 2026-05-02
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

`programs.niri.enable` automatically wires up a set of system-level services (sourced from `nixos/modules/programs/wayland/niri.nix` in nixpkgs):

| What | How |
|---|---|
| xdg.portal | gnome + gtk portals configured; screencast support enabled |
| gnome-keyring | enabled by default (required for portal Secret interface) |
| polkit daemon | `security.polkit.enable = true` (from `wayland-session.nix`) |
| dconf | `programs.dconf.enable = true` |
| session registration | niri appears in `services.displayManager.sessionPackages` |
| graphical-desktop | `services.graphical-desktop.enable = true` |
| XDG autostart | `services.xserver.desktopManager.runXdgAutostartIfNone = true` |

Note: `programs.niri` explicitly sets `enableXWayland = false` — X11 is handled by `xwayland-satellite` instead (see below).

## System Packages

The `nixosModules.niri` module also installs:

```nix
environment.systemPackages = with pkgs; [
  xwayland-satellite  # must be on PATH; wrapper config references it via lib.getExe
  polkit_gnome        # graphical auth agent; autostarted via XDG autostart in user session
];
```

`polkit_gnome` ships an XDG autostart `.desktop` file. With `runXdgAutostartIfNone = true` set by `programs.niri`, it is launched automatically when the niri session starts.

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

`Mod` is the Super/Windows key.

**Apps**

| Keybind | Action |
|---|---|
| `Mod+Return` | spawn `kitty` terminal |
| `Mod+Q` | close focused window |
| `Mod+S` | toggle noctalia launcher (`myNoctalia ipc call launcher toggle`) |

**Navigation**

| Keybind | Action |
|---|---|
| `Mod+Left` | focus column left |
| `Mod+Right` | focus column right |
| `Mod+Up` | focus window up |
| `Mod+Down` | focus window down |
| `Mod+Shift+Left` | move column left |
| `Mod+Shift+Right` | move column right |

**Resize**

| Keybind | Action |
|---|---|
| `Mod+Minus` | shrink column width by 10% |
| `Mod+Equal` | grow column width by 10% |

**Window state**

| Keybind | Action |
|---|---|
| `Mod+F` | fullscreen focused window |
| `Mod+Shift+F` | toggle floating |

**System**

| Keybind | Action |
|---|---|
| `Mod+Shift+L` | lock screen (`waylock`) |
| `Print` | screenshot selection → clipboard (grim + slurp → wl-copy) |

**Workspaces** (generated dynamically via `lib.range 1 9`)

| Keybind | Action |
|---|---|
| `Mod+1` – `Mod+9` | focus workspace N |
| `Mod+Shift+1` – `Mod+Shift+9` | move focused window to workspace N |

## Cross-references

- Runtime dependency: [[features/noctalia]]
- Only active on: [[hosts/nixxy]]
- Wrapping mechanism: [[concepts/wrapper-modules]]
