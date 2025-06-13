{ config, lib, pkgs, modulesPath, inputs, ... }: 
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
      inputs.nixos-hardware.nixosModules.dell-xps-13-9315
    ];

  boot = {
    consoleLogLevel = 3;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
      "i915.enable_psr=0"
    ];
    initrd = {
      availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "uas" "sd_mod" ];
      kernelModules = [ ];
      verbose = false;
    };
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      timeout = 0;
      efi.canTouchEfiVariables = true;
    };
    kernelModules = [ "kvm-intel" ];
    blacklistedKernelModules = [ "psmouse" ];
    extraModulePackages = [ ];
    plymouth = {
      enable = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
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
  environment.systemPackages = [ pkgs.alsa-ucm-conf pkgs.pulseaudio ];
  environment.etc = {
    "wireplumber/main.lua.d/51-set-default-sink.lua" = {
      text = ''
        rule = {
          matches = {
            {
              -- Replace this with the name of your laptop speakers from `pactl list sinks`
              { "node.name", "equals", "alsa_output.pci-0000_00_1f.3-platform-sof_sdw.HiFi__Speaker__sink" },
            },
          },
          apply_properties = {
            -- A higher priority makes this device the default.
            -- External devices often get a priority around 1000.
            ["priority.driver"] = 1001,
            ["priority.session"] = 1001,
          },
        }
        table.insert(alsa_monitor.rules, rule)
      '';
    };
  };
  hardware = {
    firmware = with pkgs; [
      sof-firmware
    ];
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };
}