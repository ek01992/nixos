{ config, lib, pkgs, modulesPath, inputs, ... }: 
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
      inputs.nixos-hardware.nixosModules.dell-xps-13-9315
    ];

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "uas" "sd_mod" ];
      kernelModules = [ ];
    };
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi = {
        canTouchEfiVariables = true;
      };
    };
    kernelModules = [ "kvm-intel" ];
    blacklistedKernelModules = [ "psmouse" ];
    extraModulePackages = [ ];
    kernelParams = [ "i915.enable_psr=0" ];
  };

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    
  
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/a4f2ee31-d059-4bdd-8ded-8c0a9da26b80";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/5085-7E42";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/3bf3ac89-468c-4007-856a-d18ed360def8";
    }
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}