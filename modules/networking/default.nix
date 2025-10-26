# Networking Configuration Module
# Verification: ip link show
#               systemctl status systemd-networkd
#               networkctl status
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myNetworking;
in
{
  options.myNetworking = {
    enable = mkEnableOption "networking configuration";

    hostId = mkOption {
      type = types.str;
      description = "Unique host ID for ZFS";
      example = "8a3e4f2d";
    };

    hostName = mkOption {
      type = types.str;
      default = "nixos";
      description = "System hostname";
      example = "server";
    };

    enableFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Enable nftables firewall";
    };

    enableDhcp = mkOption {
      type = types.bool;
      default = false;
      description = "Enable DHCP on interfaces";
    };

    bridgeName = mkOption {
      type = types.str;
      default = "externalbr0";
      description = "Name of the external bridge";
      example = "lanbr0";
    };

    bridgeInterface = mkOption {
      type = types.str;
      description = "Physical interface to bridge";
      example = "eth0";
    };

    bridgeMacAddress = mkOption {
      type = types.str;
      description = "MAC address for bridge interface";
      example = "02:f6:ad:d9:9e:d1";
    };

    enableTailscale = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Tailscale VPN";
    };
  };

  config = mkIf cfg.enable {
    # Core networking settings
    networking = {
      hostId = cfg.hostId;
      hostName = cfg.hostName;
      tempAddresses = "disabled";
      nftables.enable = cfg.enableFirewall;
      firewall.enable = cfg.enableFirewall;
      useDHCP = cfg.enableDhcp;

      # Bridge configuration
      bridges = {
        "${cfg.bridgeName}" = {
          interfaces = [ cfg.bridgeInterface ];
        };
      };

      interfaces = {
        "${cfg.bridgeName}" = {
          useDHCP = true;
          macAddress = cfg.bridgeMacAddress;
        };
      };
    };

    # MAC-based interface matching as fallback
    systemd.network.networks."10-usb-ethernet" = {
      matchConfig.MACAddress = cfg.bridgeMacAddress;
      networkConfig.Bridge = cfg.bridgeName;
    };

    # Tailscale VPN
    services.tailscale.enable = cfg.enableTailscale;
  };
}
