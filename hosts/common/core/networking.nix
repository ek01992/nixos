# Basic networking configuration for all hosts
# Host-specific networking (bridges, static IPs) goes in hosts/<hostname>/
# Verification: networkctl status, ip addr show

{
  config,
  lib,
  pkgs,
  ...
}: {

  networking = {
    # Disable IPv6 privacy extensions for predictable addresses
    # Important for static DHCP reservations and container networking
    tempAddresses = "disabled";
    # Default to DHCP disabled - hosts enable per-interface as needed
    useDHCP = lib.mkDefault false;
    # Firewall baseline
    firewall = {
      # Allow SSH by default - critical for remote management
      allowedTCPPorts = [22];
      # Trust Tailscale interface when enabled
      trustedInterfaces = lib.optionals (config.services.tailscale.enable or false) [
        "tailscale0"
      ];
    };
  };

  # systemd-networkd for consistent interface management
  systemd.network.enable = lib.mkDefault true;

  # Enable nftables for Incus compatibility
  networking.nftables.enable = lib.mkDefault true;

}
