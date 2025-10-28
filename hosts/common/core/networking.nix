# Basic networking configuration for all hosts
# Host-specific networking (bridges, static IPs) goes in hosts/<hostname>/
# Verification: networkctl status, ip addr show, scripts/network-verify.sh
# Options: myNetworking.core.disableIpv6Privacy, useSystemdNetworkd, useNftables, defaultFirewallPorts
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myNetworking.core;
  inherit (lib) mkEnableOption mkOption mkIf types mkDefault;
in {
  options.myNetworking.core = {
    enable = mkEnableOption "Core networking configuration" // { default = true; };

    disableIpv6Privacy = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Disable IPv6 privacy extensions for predictable addresses.
        Important for static DHCP reservations and container networking.
      '';
    };

    useSystemdNetworkd = mkOption {
      type = types.bool;
      default = true;
      description = "Use systemd-networkd for consistent interface management";
    };

    useNftables = mkOption {
      type = types.bool;
      default = true;
      description = "Enable nftables firewall (required for Incus compatibility)";
    };

    defaultFirewallPorts = mkOption {
      type = types.listOf types.int;
      default = [22];
      example = [22 80 443];
      description = "Default TCP ports to allow through firewall";
    };
  };

  config = mkIf cfg.enable {
    networking = {
      # Disable IPv6 privacy extensions for predictable addresses
      # Important for static DHCP reservations and container networking
      tempAddresses = lib.mkIf cfg.disableIpv6Privacy "disabled";
      # Default to DHCP disabled - hosts enable per-interface as needed
      useDHCP = lib.mkDefault false;
      # Firewall baseline
      firewall = {
        # Allow SSH by default - critical for remote management
        allowedTCPPorts = cfg.defaultFirewallPorts;
        # Core networking only handles SSH - optional modules add their own firewall rules
      };
    };

    # systemd-networkd for consistent interface management
    systemd.network.enable = lib.mkIf cfg.useSystemdNetworkd (lib.mkDefault true);

    # Enable nftables for Incus compatibility
    networking.nftables.enable = lib.mkIf cfg.useNftables (lib.mkDefault true);
  };
}
