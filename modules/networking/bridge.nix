# Bridge Networking Configuration Module
# Verification: ip link show
#               bridge link show
#               systemctl status systemd-networkd
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myNetworking.bridge;
  inherit (lib) mkEnableOption mkOption mkIf types;
in {
  options.myNetworking.bridge = {
    enable = mkEnableOption "bridge networking configuration";

    name = mkOption {
      type = types.str;
      default = "externalbr0";
      description = "Name of the external bridge";
      example = "lanbr0";
    };

    interface = mkOption {
      type = types.str;
      description = "Physical interface to bridge";
      example = "eth0";
    };

    macAddress = mkOption {
      type = types.str;
      description = "MAC address for bridge interface";
      example = "02:f6:ad:d9:9e:d1";
    };
  };

  config = mkIf cfg.enable {
    # Bridge configuration
    networking.bridges = {
      "${cfg.name}" = {
        interfaces = [cfg.interface];
      };
    };

    networking.interfaces = {
      "${cfg.name}" = {
        useDHCP = lib.mkDefault true;
        # MAC address matches USB Ethernet adapter for consistent interface naming
        # Allows Incus containers to receive static DHCP leases based on bridge MAC
        # Without this, interface name changes on reboot and DHCP reservations break
        macAddress = cfg.macAddress;
      };
    };

    # MAC-based interface matching as fallback
    systemd.network.networks."10-usb-ethernet" = {
      matchConfig.MACAddress = cfg.macAddress;
      networkConfig.Bridge = cfg.name;
    };
  };
}
