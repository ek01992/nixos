---
title: nixos-wsl Host
type: host
updated: 2026-05-01
sources:
  - modules/hosts/wsl/default.nix
  - modules/hosts/wsl/configuration.nix
  - modules/hosts/wsl/hardware.nix
---

# nixos-wsl

WSL2 host running on Windows. Headless — no display server, no GUI packages beyond the baseline.

## Flake Output

`flake.nixosConfigurations.nixos-wsl`  
Directory: `modules/hosts/wsl/` (note: dir name is `wsl`, flake key is `nixos-wsl`)

## Imported Modules

```nix
imports = [
  self.nixosModules.nixos-wslHardware    # hardware.nix
  inputs.nixos-wsl.nixosModules.default  # WSL2 NixOS integration
  self.nixosModules.common               # baseline (see [[modules/common]])
];
```

Does **not** import [[features/niri]] or [[features/noctalia]] — display stack is Windows-side.

## User

- Username: `erik`
- Groups: `wheel` (sudo)
- Description: "Erik Kowald"

WSL default user is set via `wsl.defaultUser = "erik"`.  
`wsl.interop.includePath = false` — Windows PATH is not injected into the Linux environment.

## Networking

- Hostname: `nixos-wsl`
- Network managed by WSL2 (no `networkmanager`)
- SSH enabled (port 22 open), from [[modules/common]]

## Filesystem

| Mountpoint | Device | Type | Notes |
|---|---|---|---|
| `/` | uuid `662019ff-…` | ext4 | main disk |
| `/mnt/wsl` | none | tmpfs | WSL shared memory |
| `/usr/lib/wsl/drivers` | `drivers` | 9p | Windows GPU drivers |
| `/shared` | `/mnt/d/wsl/shared` | bind | shared folder with Windows host |

Swap: uuid `fd82a5ac-…`

## Platform

`x86_64-linux`  
No custom kernel modules needed (WSL2 manages the kernel).

## State Version

`system.stateVersion = "26.05"`
