---
title: nixxy Host
type: host
updated: 2026-05-01
sources:
  - modules/hosts/nixxy/default.nix
  - modules/hosts/nixxy/configuration.nix
  - modules/hosts/nixxy/hardware.nix
---

# nixxy

Bare-metal Intel machine. Full desktop environment: [[features/niri]] Wayland compositor, [[features/noctalia]] shell, PipeWire audio, Firefox.

## Flake Output

`flake.nixosConfigurations.nixxy`  
Directory: `modules/hosts/nixxy/`

## Imported Modules

```nix
imports = [
  self.nixosModules.nixxyHardware   # hardware.nix
  self.nixosModules.niri            # Wayland compositor + myNiri package
  self.nixosModules.common          # baseline (see [[modules/common]])
];
```

## User

- Username: `erik`
- Groups: `wheel`, `networkmanager`
- Description: "Erik Kowald"

## Boot

- Bootloader: `systemd-boot`
- EFI variables: writable (`canTouchEfiVariables = true`)

## Networking

- Hostname: `nixxy`
- Network manager: `networkmanager`
- SSH enabled (port 22), from [[modules/common]]

## Desktop Stack

| Layer | Package |
|---|---|
| Compositor | [[features/niri]] (`myNiri`, wrapper-modules) |
| Shell/bar | [[features/noctalia]] (`myNoctalia`, wrapper-modules) |
| Terminal | `kitty` (launched via niri keybind `Mod+Return`) |
| Browser | `firefox` (`programs.firefox.enable = true`) |

## Audio

PipeWire stack — no PulseAudio daemon:
```nix
services.pulseaudio.enable = false;
services.pipewire = {
  enable = true;
  alsa.enable = true;
  alsa.support32Bit = true;
  pulse.enable = true;        # PulseAudio compatibility layer
};
security.rtkit.enable = true; # real-time scheduling for pipewire
```

## Fonts

```nix
fonts.enableDefaultPackages = true;
fonts.packages = [ pkgs.noto-fonts pkgs.noto-fonts-emoji ];
```

## Hardware

- Platform: `x86_64-linux`
- CPU: Intel (kvm-intel module, microcode updates enabled)
- initrd modules: `xhci_pci`, `thunderbolt`, `nvme`, `usbhid`, `uas`, `sd_mod`

| Mountpoint | UUID | Type |
|---|---|---|
| `/` | `da2b9134-…` | ext4 |
| `/boot` | `7408-E917` | vfat (fmask/dmask 0077) |

Swap: uuid `df36f2f3-…`

## State Version

`system.stateVersion = "26.05"`
