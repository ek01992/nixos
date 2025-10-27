# Incus Virtualization Module
# Verification: incus admin init --dump
#               incus profile list
#               incus storage list
#               incus network list
#               systemctl status incus
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myVirtualization.incus;
  inherit (lib) mkOption mkIf types mkDefault;
in {
  options.myVirtualization.incus = {
    storagePool = mkOption {
      type = types.str;
      default = "tank/incus";
      description = "ZFS pool for Incus storage";
      example = "rpool/incus";
    };

    internalBridge = mkOption {
      type = types.str;
      default = "internalbr0";
      description = "Name of internal bridge for containers";
      example = "lxdbr0";
    };

    externalBridge = mkOption {
      type = types.str;
      default = "externalbr0";
      description = "Name of external bridge for bridged containers";
      example = "lanbr0";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.incus = lib.mkDefault {
      preseed = {
        networks = [
          {
            name = cfg.internalBridge;
            type = "bridge";
            description = "Internal/NATted bridge";
            config = {
              "ipv4.address" = "auto";
              "ipv4.nat" = "true";
              "ipv6.address" = "auto";
              "ipv6.nat" = "true";
            };
          }
        ];
        profiles = [
          {
            name = "default";
            description = "Default Incus Profile";
            devices = {
              eth0 = {
                name = "eth0";
                network = cfg.internalBridge;
                type = "nic";
              };
              root = {
                path = "/";
                pool = "default";
                type = "disk";
              };
            };
          }
          {
            name = "bridged";
            description = "Instances bridged to LAN";
            devices = {
              eth0 = {
                name = "eth0";
                nictype = "bridged";
                parent = cfg.externalBridge;
                type = "nic";
              };
              root = {
                path = "/";
                pool = "default";
                type = "disk";
              };
            };
          }
        ];
        storage_pools = [
          {
            name = "default";
            driver = "zfs";
            config = {
              source = cfg.storagePool;
            };
          }
        ];
      };
    };
  };
}
