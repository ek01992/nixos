{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: {
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "uas"
        "usbhid"
        "sd_mod"
        "ahci"
      ];
      kernelModules = [ "kvm-intel" ];
      supportedFilesystems = [ "btrfs" ];
    };
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
      };
      efi.canTouchEfiVariables = true;
      timeout = 5;
    };
    kernelParams = [ "console=tty1" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-label/xps";
      fsType = "btrfs";
      options = [ "subvol=@" "compress=zstd" ];
    };

    "/nix" = {
      device = "/dev/disk/by-label/xps";
      fsType = "btrfs";
      options = [ "subvol=@nix" "noatime" "compress=zstd" ];
    };

    "/persist" = {
      device = "/dev/disk/by-label/xps";
      fsType = "btrfs";
      options = [ "subvol=@persist" "compress=zstd" ];
      neededForBoot = true;
    };

    "/swap" = {
      device = "/dev/disk/by-label/xps";
      fsType = "btrfs";
      options = [ "subvol=@swap" "noatime" ];
    };
  };

  swapDevices = [{
    device = "/swap/swapfile";
    size = 8196;
  }];

  nixpkgs.hostPlatform.system = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
} 