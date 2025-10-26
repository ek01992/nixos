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
    };

    hostName = mkOption {
      type = types.str;
      default = "nixos";
      description = "System hostname";
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
    };

    bridgeInterface = mkOption {
      type = types.str;
      description = "Physical interface to bridge";
    };

    bridgeMacAddress = mkOption {
      type = types.str;
      description = "MAC address for bridge interface";
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

    # Tailscale VPN
    services.tailscale.enable = cfg.enableTailscale;
  };
}
