---
title: common module
type: module
updated: 2026-05-01
sources:
  - modules/common.nix
---

# common

Baseline NixOS module imported by every host.  
Export: `flake.nixosModules.common`

Used by: [[hosts/nixos-wsl]], [[hosts/nixxy]]

## Nix Settings

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

Enables the flakes and `nix` CLI features universally.

## System Packages

```nix
environment.systemPackages = with pkgs; [
  wget curl bat fastfetch nixfmt nixfmt-tree
];
```

| Package | Purpose |
|---|---|
| `wget`, `curl` | HTTP downloads |
| `bat` | `cat` with syntax highlighting |
| `fastfetch` | system info display |
| `nixfmt`, `nixfmt-tree` | Nix file formatting |

## Git

```nix
programs.git = {
  enable = true;
  config.user = { name = "Erik"; email = "erik@cyberworkforce.com"; };
  config.init.defaultBranch = "main";
};
```

Git is configured globally at the system level — no per-user config needed.

## Shell Aliases

| Alias | Expands to |
|---|---|
| `nrb` | `nixos-rebuild build --flake $HOME/nixos` |
| `nrs` | `sudo nixos-rebuild switch --flake $HOME/nixos` |
| `nfc` | `nix flake check` |
| `nfu` | `nix flake update` |

Applied to bash. `$HOME/nixos` assumes the flake repo is at `~/nixos`.

## Networking

```nix
services.openssh.enable = true;
networking.firewall = { enable = true; allowedTCPPorts = [ 22 ]; };
```

SSH daemon on port 22, firewall enabled everywhere.

## Locale / Timezone

- Timezone: `America/Chicago` (CT)
- Locale: `en_US.UTF-8` for all `LC_*` variables

## Misc

```nix
nixpkgs.config.allowUnfree = true;
```

Unfree packages allowed globally — required for things like proprietary GPU drivers or closed-source apps.
