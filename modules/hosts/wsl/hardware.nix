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
      imports = [ ];

      boot = {
        initrd = {
          availableKernelModules = [ ];
          kernelModules = [ ];
        };
        kernelModules = [ "kvm-intel" ];
        extraModulePackages = [ ];
      };

      fileSystems = {
        "/lib/modules/6.6.87.2-microsoft-standard-WSL2" = {
          device = "none";
          fsType = "overlay";
        };

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

      swapDevices = [ { device = "/dev/disk/by-uuid/fd82a5ac-a68d-4ecb-b50d-ddcc66a96bde"; } ];
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    };
}
