# Virtualization stack (Incus + KVM-GT)
# Enable in host config with: imports = [ ../common/optional/virtualization.nix ];
# Verification: incus list, systemctl status incus, scripts/network-verify.sh
# Options: myVirtualization.incus.storagePool, internalBridge, externalBridge, trustedUsers, internalNetwork
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myVirtualization.incus;
  inherit (lib) mkEnableOption mkOption mkIf types mkDefault;
in {
  options.myVirtualization.incus = {
    enable = mkEnableOption "Incus virtualization";

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
      example = ["admin" "developer"];
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

      ipv6Address = mkOption {
        type = types.str;
        default = "auto";
        example = "fd42:1234:5678::1/64";
        description = ''
          IPv6 address for internal bridge.
          "auto" = Let Incus choose (recommended)
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    # Intel GVT-g GPU virtualization
    virtualisation.kvmgt.enable = true;

    # Incus container and VM management
    virtualisation.incus = {
      enable = true;
      package = pkgs.incus;
      ui.enable = true;
      preseed = {
        networks = [
          {
            name = cfg.internalBridge;
            type = "bridge";
            description = "Internal/NATted bridge";
            config = {
              "ipv4.address" = cfg.internalNetwork.ipv4Address;
              "ipv4.nat" = "true";
              "ipv6.address" = cfg.internalNetwork.ipv6Address;
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

    # Add users to incus-admin group
    users.users = lib.genAttrs cfg.trustedUsers (name: {
      extraGroups = lib.mkAfter ["incus-admin"];
    });

    # Trust bridges in firewall
    networking.firewall.trustedInterfaces = lib.mkAfter (
      [ cfg.internalBridge ]
      ++ lib.optional (config.networking.bridges ? ${cfg.externalBridge})
                      cfg.externalBridge
    );
  };
}
