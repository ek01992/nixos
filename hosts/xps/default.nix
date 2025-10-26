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
  mySystem = {
    enable = true;
    enableAutoUpgrade = true;
    autoUpgradeDates = "weekly";
    allowReboot = true;
    stateVersion = "25.11";
    enableFirmware = true;
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
  # IMPORTANT: bridgeInterface assumes Anker USB-C adapter
  # in specific USB-C port. Name changes if hardware changes.
  # Verify with: ip link show
  myNetworking = {
    enable = true;
    hostId = "ea997198";
    hostName = "xps";
    enableFirewall = false;
    enableDhcp = false;
    bridgeName = "externalbr0";
    bridgeInterface = "enp0s20f0u6u1i5";
    bridgeMacAddress = "02:f6:ad:d9:9e:d1";
    enableTailscale = true;
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
    extraGroups = [ "wheel" "incus-admin" ];
    sshKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICdtT76ryXgblv68mqVfrcRVp4tRvhl81vwFKDLEF0MP desktop@erik-dev.io"
    ];
  };
}
