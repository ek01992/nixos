{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      <nixos-hardware/dell/xps/13-9315>
    ];

  # Enable flakes and CLI tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.extraModprobeConfig = ''
    options kvm ignore_msrs=1 report_ignored_msrs=0
  '';

  fileSystems."/" = {
    device = "tank/root";
    fsType = "zfs";
    };
  fileSystems."/nix" = {
    device = "tank/nix";
    fsType = "zfs";
    };
  fileSystems."/var" = {
    device = "tank/var";
    fsType = "zfs";
    };
  fileSystems."/home" = {
    device = "tank/home";
    fsType = "zfs";
    };

  # Networking
  networking = {
    hostId = "ea997198";
    hostName = "nixos";
    tempAddresses = "disabled";
    nftables.enable = true;
    firewall.enable = false;
    useDHCP = false;
    bridges = {
      externalbr0 = {
        interfaces = [ "enp0s20f0u6u1i5" ];
      };
    };
    interfaces = {
      externalbr0 = {
        useDHCP = true;
        macAddress = "03:f6:ad:d9:9e:d1";
      };
    };
  };

  # System Settings
  time.timeZone = "America/Chicago";
  console.keyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";
  system.stateVersion = "25.11";
  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
    allowReboot = true;
  };

  # Environment Packages
  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    htop
    vi
    tree
  ];

  # Services
  services = {

    # ZFS
    zfs = {
      autoScrub.enable = true;
      trim.enable = true;
    };

    # Dell Firmware Upgrades
    fwupd.enable = true;

    # Tailscale
    tailscale.enable = true;

    # OpenSSH
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };

# Virtualisation
  virtualisation = {

    # GPU virtualisation (Intel GVT-g)
    kvmgt.enable = true;

    # Incus (Virtual Machine and System Container management)
    incus = {
      enable = true;
      ui.enable = true;
      package = pkgs.incus;
      preseed = {
        networks = [
          {
            name = "internalbr0";
            type = "bridge";
            description = "Internal/NATted bridge";
            config = {
              "ipv4.address" = "auto";
              "ipv4.nat" = "true";
              "ipv6.address" = "auto";
              "ipv6.nat" = "true";
            };
          }
        ];
        profiles = [
          {
            name = "default";
            description = "Default Incus Profile";
            devices = {
              eth0 = {
                name = "eth0";
                network = "internalbr0";
                type = "nic";
              };
              root = {
                path = "/";
                pool = "default";
                type = "disk";
              };
            };
          }
          {
            name = "bridged";
            description = "Instances bridged to LAN";
            devices = {
              eth0 = {
                name = "eth0";
                nictype = "bridged";
                parent = "externalbr0";
                type = "nic";
              };
              root = {
                path = "/";
                pool = "default";
                type = "disk";
              };
            };
          }
        ];
        storage_pools = [
          {
            name = "default";
            driver = "zfs";
            config = {
              source = "tank/incus";
            };
          }
        ];
      };
    };
  };

  users.users.erik = {
    isNormalUser = true;
    description = "Erik Kowald";
    extraGroups = [ "wheel" "incus-admin" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICdtT76ryXgblv68mqVfrcRVp4tRvhl81vwFKDLEF0MP desktop@erik-dev.io"
    ];
  };
}
