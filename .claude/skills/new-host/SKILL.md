---
name: new-host
description: Scaffold a new NixOS host configuration for this flake repo, following the import-tree pattern
---

When the user invokes /new-host [name], create the directory
`modules/hosts/<name>/` with these three files:

**`modules/hosts/<name>/default.nix`:**
```nix
{ ... }:
{
  imports = [ ./configuration.nix ./hardware.nix ];
}
```

**`modules/hosts/<name>/hardware.nix`:**
```nix
{ config, lib, pkgs, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/REPLACE-WITH-ACTUAL-UUID";
    fsType = "ext4";
  };

  swapDevices = [ ];

  networking.hostName = "<name>";
  networking.networkmanager.enable = true;
}
```

**`modules/hosts/<name>/configuration.nix`:**
```nix
{ config, inputs, lib, pkgs, self, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    self.nixosModules.common
    self.nixosModules.shell
  ];

  system.stateVersion = "26.05";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.erik = { config, ... }: {
      home.stateVersion = "26.05";
      home.packages = with pkgs; [ ];
    };
  };
}
```

Then remind the user to:
- Replace `REPLACE-WITH-ACTUAL-UUID` in `hardware.nix` with the real disk UUID
  (run `lsblk -f` on the target machine to find it)
- For WSL hosts: remove the boot loader block and add instead:
  ```nix
  wsl = {
    enable = true;
    defaultUser = "erik";
  };
  ```
  and add `inputs.nixos-wsl.nixosModules.wsl` to the `imports` list in `configuration.nix`
- Add any additional feature modules to the `imports` list in `configuration.nix`
  (e.g. `self.nixosModules.niri` for the desktop compositor)

Finally, run `nfc` (nix flake check) to verify the host is syntactically valid.
