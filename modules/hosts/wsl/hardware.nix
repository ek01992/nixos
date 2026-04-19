{ self, inputs, ... }: {

  flake.nixosModules.nixos-wslHardware = { config, lib, pkgs, modulesPath, ... }: {
    imports = [];

    boot = {
      initrd = {
        availableKernelModules = [];
        kernelModules = [];
      };
      kernelModules = [ "kvm-intel" ];
      extraModulePackages = [];
    };

    swapDevices =
        [ { device = "/dev/disk/by-uuid/fd82a5ac-a68d-4ecb-b50d-ddcc66a96bde"; }
        ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}
