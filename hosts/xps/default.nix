{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/server
    inputs.nixos-hardware.nixosModules.dell-xps-13-9315
  ];

  # Host-specific configuration
  profiles.server.enable = true;

  # System configuration
  system = {
    enable = true;
    enableBoot = true;
    enableLocale = true;
    enableAutoUpgrade = true;
    autoUpgradeDates = "weekly";
    allowReboot = true;
    stateVersion = "25.11";
    enableFirmware = true;
  };

  # Boot configuration
  system.boot = {
    enable = true;
    enableSystemdBoot = true;
    enableEfiVariables = true;
    enableZfsSupport = true;
    enableKvmOptions = true;
  };

  # Locale configuration
  system.locale = {
    enable = true;
    timezone = "America/Chicago";
    defaultLocale = "en_US.UTF-8";
    keyMap = "us";
  };

  # Networking configuration
  networking = {
    enable = true;
    hostId = "ea997198";
    hostName = "xps";
    enableFirewall = false;
    enableDhcp = false;
    bridgeName = "externalbr0";
    bridgeInterface = "enp0s20f0u6u1i5";
    bridgeMacAddress = "03:f6:ad:d9:9e:d1";
    enableTailscale = true;
  };

  # Services configuration
  services = {
    enable = true;
    enableZfs = true;
    enableSsh = true;
    enableFirmware = true;
  };

  # ZFS services
  services.zfs = {
    enable = true;
    enableScrub = true;
    enableTrim = true;
  };

  # SSH configuration
  services.ssh = {
    enable = true;
    port = 22;
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
    permitRootLogin = "no";
  };

  # Virtualisation configuration
  virtualisation = {
    enable = true;
    enableKvmgt = true;
    enableIncus = true;
  };

  # Incus configuration
  virtualisation.incus = {
    enable = true;
    enableUi = true;
    storagePool = "tank/incus";
    internalBridge = "internalbr0";
    externalBridge = "externalbr0";
  };

  # Users configuration
  users = {
    enable = true;
    enableErik = true;
  };

  # Erik user configuration
  users.erik = {
    enable = true;
    description = "Erik Kowald";
    extraGroups = [ "wheel" "incus-admin" ];
    sshKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICdtT76ryXgblv68mqVfrcRVp4tRvhl81vwFKDLEF0MP desktop@erik-dev.io"
    ];
  };

  # ZFS filesystem mounts (host-specific)
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
}