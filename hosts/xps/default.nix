{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
    ../../modules/networking
    ../../modules/services
    ../../modules/virtualization
    ../../modules/users
    inputs.nixos-hardware.nixosModules.dell-xps-13-9315
  ];

  # System configuration
  mySystem = {
    enable = true;
  };

  # Core system settings
  mySystem.core = {
    enable = true;
    stateVersion = "25.11";
    enableFirmware = true;
  };

  # System upgrade settings
  mySystem.upgrade = {
    enable = true;
    dates = "weekly";
    allowReboot = true;
  };

  # Boot configuration
  mySystem.boot = {
    enable = true;
    enableSystemdBoot = true;
    enableEfiVariables = true;
    enableZfsSupport = true;
    enableKvmOptions = true;
  };

  # Locale configuration
  mySystem.locale = {
    enable = true;
    timezone = "America/Chicago";
    defaultLocale = "en_US.UTF-8";
    keyMap = "us";
  };

  # Services configuration
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

  # Networking configuration
  myNetworking = {
    enable = true;
  };

  # Core networking settings
  myNetworking.core = {
    enable = true;
    hostId = "ea997198";
    hostName = "xps";
    enableDhcp = false;
  };

  # Bridge configuration
  # MAC address matches USB Ethernet adapter for consistent interface naming
  # Allows Incus containers to receive static DHCP leases based on bridge MAC
  myNetworking.bridge = {
    enable = true;
    name = "externalbr0";
    interface = "enp0s20f0u6u1i5";
    macAddress = "02:f6:ad:d9:9e:d1";
  };

  # Firewall configuration
  # Disabled for development environment - system protected by Tailscale VPN
  myNetworking.firewall = {
    enable = false;
  };

  # Nftables firewall configuration
  # Required for Incus containers to receive static DHCP leases based on bridge MAC
  myNetworking.nftables = {
    enable = true;
  };

  # Tailscale VPN
  myNetworking.tailscale = {
    enable = true;
  };

  # Virtualization configuration
  myVirtualization = {
    enable = true;
  };

  # KVM-GT configuration
  myVirtualization.kvmgt.enable = true;

  # Incus configuration
  myVirtualization.incus = {
    enable = true;
    enableUi = true;
    storagePool = "tank/incus";
    internalBridge = "internalbr0";
    externalBridge = "externalbr0";
  };

  # Users configuration
  myUsers = {
    enable = true;
  };

  # Erik user configuration
  myUsers.erik = {
    enable = true;
    description = "Erik Kowald";
    extraGroups = ["wheel" "incus-admin"];
    sshKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICdtT76ryXgblv68mqVfrcRVp4tRvhl81vwFKDLEF0MP desktop@erik-dev.io"
    ];
  };

  # System packages
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
