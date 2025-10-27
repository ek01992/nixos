{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware
    ../../modules
    inputs.nixos-hardware.nixosModules.dell-xps-13-9315
    inputs.agenix.nixosModules.default
  ];

  mySystem = {
    enable = true;
    core = {
      enable = true;
      stateVersion = "25.11";
      enableFirmware = true;
    };
    upgrade = {
      enable = true;
      dates = "weekly";
      allowReboot = true;
    };
    boot = {
      enable = true;
      enableSystemdBoot = true;
      enableEfiVariables = true;
      enableZfsSupport = true;
      enableKvmOptions = true;
    };
    locale = {
      enable = true;
      timezone = "America/Chicago";
      defaultLocale = "en_US.UTF-8";
      keyMap = "us";
    };
  };

  myServices = {
    enable = true;

    firmware = {
      enable = true;
    };

    zfs = {
      enable = true;
      enableScrub = true;
      enableTrim = true;
    };

    ssh = {
      enable = true;
      port = 22;
      passwordAuthentication = false;
      kbdInteractiveAuthentication = false;
      permitRootLogin = "no";
    };
  };

  myNetworking = {
    enable = true;
    core = {
      enable = true;
      hostId = "ea997198";
      hostName = "xps";
      enableDhcp = false;
    };
    bridge = {
      enable = true;
      name = "externalbr0";
      interface = "enp0s20f0u6u1i5";
      macAddress = "02:f6:ad:d9:9e:d1";
    };
    firewall = {
      enable = true;
    };
    tailscale = {
      enable = true;
    };
  };

  myVirtualization = {
    enable = true;

    kvmgt = {
      enable = true;
    };

    incus = {
      enable = true;
      enableUi = true;
      storagePool = "tank/incus";
      internalBridge = "internalbr0";
      externalBridge = "externalbr0";
    };
  };

  myUsers = {
    enable = true;

    erik = {
      enable = true;
      description = "Erik Kowald";
      extraGroups = ["wheel" "incus-admin"];
      sshKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICdtT76ryXgblv68mqVfrcRVp4tRvhl81vwFKDLEF0MP desktop@erik-dev.io"
      ];
    };
  };

  age.identityPaths = ["/var/lib/agenix/key.txt"];

  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    htop
    vim
    tree
    alejandra
    just
  ];
}
