{ self, inputs, ... }:
{

  flake.nixosModules.nixos-wslHardware =
    {
      config,
      lib,
      pkgs,
      modulesPath,
      ...
    }:
    {
      boot = {
        initrd = {
          availableKernelModules = [ ];
          kernelModules = [ ];
        };
        kernelModules = [ ];
        extraModulePackages = [ ];
      };

      fileSystems = {
        "/mnt/wsl" = {
          device = "none";
          fsType = "tmpfs";
        };

        "/usr/lib/wsl/drivers" = {
          device = "drivers";
          fsType = "9p";
        };

        "/" = {
          device = "/dev/disk/by-uuid/662019ff-5cc2-4a40-a7cf-a3f395f242b4";
          fsType = "ext4";
        };

        "/shared" = {
          device = "/mnt/d/wsl/shared";
          fsType = "none";
          options = [
            "bind"
            "nofail"
          ];
        };
      };

      boot.kernel.sysctl = {
        "vm.swappiness" = 10;
        "vm.dirty_ratio" = 15;
        "vm.dirty_background_ratio" = 5;
        "kernel.sched_autogroup_enabled" = 1;
      };

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    };
}
