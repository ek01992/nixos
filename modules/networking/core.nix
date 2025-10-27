# Core Networking Configuration Module
# Verification: ip link show
#               systemctl status systemd-networkd
#               networkctl status
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myNetworking.core;
  inherit (lib) mkEnableOption mkOption mkIf types;
in {
  options.myNetworking.core = {
    enable = mkEnableOption "core networking configuration";

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

    enableDhcp = mkOption {
      type = types.bool;
      default = false;
      description = "Enable DHCP on interfaces";
    };
  };

  config = mkIf cfg.enable {
    # Core networking settings
    networking = {
      hostId = cfg.hostId;
      hostName = cfg.hostName;
      # Disabled to prevent IPv6 privacy extensions interfering with static DHCP leases
      # Incus containers need predictable addresses for bridge networking
      tempAddresses = lib.mkDefault "disabled";
      useDHCP = lib.mkDefault cfg.enableDhcp;
    };
  };
}
