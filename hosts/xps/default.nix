# XPS-specific configuration
# Common settings are in hosts/common/core/
# Only host-specific values and imports belong here
# Verification: nixos-rebuild dry-build --flake '.#xps'
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Hardware configuration
    ./hardware-configuration.nix
    # Optional features for this host
    ../common/optional/virtualization.nix
    ../common/optional/zfs.nix
    ../common/optional/tailscale.nix
  ];

  # Host identification
  networking = {
    hostName = "xps";
    hostId = "ea997198";
  };

  # Override timezone from core default (UTC)
  time.timeZone = lib.mkForce "America/Chicago";

  # Locale settings
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "en_US.UTF-8";
    };
  };

  console.keyMap = "us";

  # Firmware updates for Dell XPS
  services.fwupd.enable = true;
  hardware.enableRedistributableFirmware = true;

  # External bridge for Incus LAN-bridged containers
  # MAC address matches USB Ethernet adapter for consistent DHCP reservations
  networking.bridges.externalbr0 = {
    interfaces = ["enp0s20f0u6u1i5"];
  };

  networking.interfaces.externalbr0 = {
    useDHCP = true;
    macAddress = "02:f6:ad:d9:9e:d1";
  };

  # Trust external bridge in firewall
  networking.firewall.trustedInterfaces = lib.mkAfter ["externalbr0"];

  # sops-nix secrets configuration
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    secrets = {
      tailscale-auth = {
        owner = "root";
        mode = "0400";
      };
    };
  };

  # Host-specific packages
  environment.systemPackages = with pkgs; [
    just
  ];

  # Automatic system upgrades
  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
    allowReboot = true;
    flake = "path:/etc/nixos#xps"; # Local path for now
  };

  # NixOS release version
  system.stateVersion = "25.11";
}
