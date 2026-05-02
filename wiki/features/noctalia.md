---
title: Noctalia Shell
type: feature
updated: 2026-05-01
sources:
  - modules/features/noctalia/noctalia.nix
  - modules/features/noctalia/noctalia.json
---

# Noctalia

Minimal, "quiet by design" Wayland shell built with Quickshell. Provides the status bar, app launcher, control center, notifications, and lock screen for [[hosts/nixxy]].

## Exports

- `perSystem.packages.myNoctalia` — the wrapped noctalia package with embedded settings

Consumed by: [[features/niri]] (spawned at compositor startup, also used for the launcher keybind)

## Package: myNoctalia

```nix
packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
  inherit pkgs;
  settings = (builtins.fromJSON (builtins.readFile ./noctalia.json)).settings;
};
```

`noctalia.json` is read at **build time** via `builtins.readFile` + `builtins.fromJSON`. Edit the JSON file directly; no `.nix` changes needed. The `.settings` key is passed to the wrapper.

## Configuration File

`modules/features/noctalia/noctalia.json` — the canonical settings source. Configure via the Noctalia GUI settings panel, export the JSON, paste here.

Settings version: `59`

## Bar

Position: top | Style: simple with capsule | Opacity: 0.93 | Gaps: 4px vertical, 4px horizontal | Frame radius: 12

### Widgets (left → right)

**Left:**
| Widget | Config |
|---|---|
| Launcher | rocket icon, opens app launcher |
| Clock | `HH:mm ddd, MMM dd` format |
| SystemMonitor | CPU usage + temp, memory %, network stats (compact mode) |
| ActiveWindow | max 145px, hover scroll, icon + text |
| MediaMini | album art, artist first, progress ring, max 145px |

**Center:**
| Widget | Config |
|---|---|
| Workspace | index label, bold, pill indicator, shows badge |

**Right:**
| Widget | Config |
|---|---|
| Tray | drawer enabled |
| NotificationHistory | unread badge (primary color) |
| Battery | graphic-clean display, hidden if not detected |
| Volume | on-hover, middle-click opens `pwvucontrol || pavucontrol` |
| Brightness | on-hover |
| ControlCenter | noctalia icon, right-click opens panel |

## App Launcher

- Position: center
- Terminal: `kitty`
- Sort: most used first
- View: list with categories
- Clipboard history: disabled

## Color Scheme

- Theme: Catppuccin Lavender
- Mode: dark
- Wallpaper colors: disabled (uses predefined scheme)
- GTK sync: enabled

## Wallpaper

- Source: `~/Pictures/Wallpapers`
- Fill mode: crop
- Rotation: random, every 300 seconds
- Transitions: fade, disc, stripes, wipe, pixelate, honeycomb

## Location / Weather

- Location: zip 78216 (San Antonio, TX)
- Units: Fahrenheit, 12-hour clock
- Weather: enabled in bar calendar panel

## Dock

- Position: bottom | Style: floating | Display: auto-hide

## Notifications

- Location: top-right | Duration: low 3s, normal 8s, critical 15s
- Battery toast: enabled | Keyboard layout toast: enabled

## Cross-references

- Launched by: [[features/niri]]
- Active on: [[hosts/nixxy]]
- Wrapping mechanism: [[concepts/wrapper-modules]]
