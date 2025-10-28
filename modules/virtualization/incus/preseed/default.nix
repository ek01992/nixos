# Incus Virtualization Module
# Verification: incus admin init --dump
#               incus profile list
#               incus storage list
#               incus network list
#               systemctl status incus
#               nft list ruleset | grep -E "internalbr|externalbr"
# Options: myVirtualization.incus.trustedUsers, internalNetwork.ipv4Address, externalNetwork.ipv4Address
# Features: Automatic firewall trust for bridges, user group management
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

    trustedUsers = mkOption {
      type = types.listOf types.str;
      default = ["erik"];
      description = "Users to add to incus-admin group";
      example = ["admin" "user1"];
    };

    internalNetwork = {
      ipv4Address = mkOption {
        type = types.str;
        default = "auto";
        example = "10.100.100.1/24";
        description = ''
          IPv4 address for internal bridge.
          "auto" = Let Incus choose (recommended)
        '';
      };
    };

    externalNetwork = {
      ipv4Address = mkOption {
        type = types.str;
        default = "auto";
        example = "192.168.1.100/24";
        description = ''
          IPv4 address for external bridge.
          "auto" = Let Incus choose (recommended)
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    # Automatically trust bridge interfaces in firewall
    # This removes the need for manual firewall rules in host config
    networking.firewall.trustedInterfaces = lib.mkAfter (
      [ cfg.internalBridge ]
      ++ lib.optional (config.networking.bridges ? ${cfg.externalBridge}) 
                      cfg.externalBridge
    );

    # Add users to incus-admin group
    users.groups.incus-admin.members = cfg.trustedUsers;

    virtualisation.incus = lib.mkDefault {
      preseed = {
        networks = [
          {
            name = cfg.internalBridge;
            type = "bridge";
            description = "Internal/NATted bridge";
            config = {
              "ipv4.address" = cfg.internalNetwork.ipv4Address;
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
