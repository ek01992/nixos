---
name: new-host
description: Scaffold a new NixOS host configuration for this flake repo, following the import-tree pattern
---

When the user invokes /new-host [name], create the directory
`modules/hosts/<name>/` with these three files:

**`modules/hosts/<name>/default.nix`** — flake output entry point:
```nix
{ self, inputs, ... }:
{
  flake.nixosConfigurations.<name> = inputs.nixpkgs.lib.nixosSystem {
    modules = [ self.nixosModules.<name>Configuration ];
  };
}
```

**`modules/hosts/<name>/hardware.nix`** — hardware/filesystem module:
```nix
{ self, inputs, ... }:
{
  flake.nixosModules.<name>Hardware =
    { config, lib, modulesPath, ... }:
    {
      imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/REPLACE-ROOT-UUID";
        fsType = "ext4";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/REPLACE-BOOT-UUID";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      swapDevices = [ ];
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    };
}
```

**`modules/hosts/<name>/configuration.nix`** — system + home-manager config:
```nix
{ self, inputs, ... }:
{
  flake.nixosModules.<name>Configuration =
    { config, pkgs, lib, ... }:
    {
      imports = [
        self.nixosModules.<name>Hardware
        inputs.home-manager.nixosModules.home-manager
        self.nixosModules.common
        self.nixosModules.home
        self.nixosModules.shell
      ];

      networking.hostName = "<name>";

      users.users.erik = {
        isNormalUser = true;
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        packages = with pkgs; [ ];
      };

      system.stateVersion = "26.05";
    };
}
```

Then remind the user to:
- Replace `REPLACE-ROOT-UUID` and `REPLACE-BOOT-UUID` in `hardware.nix` with real UUIDs
  (run `lsblk -f` on the target machine to find them)
- For WSL hosts: replace the `hardware.nix` fileSystems block and `default.nix` nixosConfigurations
  with WSL equivalents, and replace `configuration.nix` imports with:
  ```nix
  imports = [
    self.nixosModules.<name>Hardware
    inputs.nixos-wsl.nixosModules.default
    self.nixosModules.common
    self.nixosModules.home
    self.nixosModules.shell
  ];
  ```
  and add the wsl block:
  ```nix
  wsl = {
    enable = true;
    defaultUser = "erik";
  };
  ```
- Add any additional feature modules to the `imports` list in `configuration.nix`
  (e.g. `self.nixosModules.niri` for the Wayland compositor)

Finally, run `nfc` (nix flake check) to verify the host is syntactically valid.

Then invoke the `nix-reviewer` subagent on the new configuration files to check for convention issues.
