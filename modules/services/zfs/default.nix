# ZFS Service Module
# Verification: zpool status, zpool list, systemctl status zfs-scrub@<pool>, systemctl status zfs-trim@<pool>, scripts/network-verify.sh
# Options: myServices.zfs.autoScrub.enable/interval/pools, trim.enable/interval
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myServices.zfs;
  inherit (lib) mkEnableOption mkOption mkIf types;
in {
  options.myServices.zfs = {
    enable = mkEnableOption "ZFS services";

    autoScrub = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable automatic ZFS scrubbing";
      };

      interval = mkOption {
        type = types.str;
        default = "weekly";
        example = "monthly";
        description = "Systemd timer interval for scrubbing";
      };

      pools = mkOption {
        type = types.listOf types.str;
        default = [];
        example = ["tank"];
        description = "Specific pools to scrub. Empty = all pools";
      };
    };

    trim = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable ZFS trim";
      };

      interval = mkOption {
        type = types.str;
        default = "weekly";
        example = "daily";
        description = "Systemd timer interval for TRIM";
      };
    };
  };

  config = mkIf cfg.enable {
    services.zfs = {
      # Weekly scrubbing prevents data corruption and maintains pool health
      # Runs automatically on Sundays at 2 AM
      autoScrub.enable = lib.mkDefault cfg.autoScrub.enable;
      # Trim improves SSD performance by marking unused blocks
      # Different from scrub - trim is for performance, scrub is for integrity
      trim.enable = lib.mkDefault cfg.trim.enable;
    };

    # Custom scrub timer if pools specified
    systemd.timers = lib.mkIf (cfg.autoScrub.enable && cfg.autoScrub.pools != []) (
      lib.listToAttrs (map (pool: {
        name = "zfs-scrub-${pool}";
        value = {
          wantedBy = ["timers.target"];
          timerConfig = {
            OnCalendar = cfg.autoScrub.interval;
            Persistent = true;
          };
        };
      }) cfg.autoScrub.pools)
    );

    # Custom scrub services if pools specified
    systemd.services = lib.mkIf (cfg.autoScrub.enable && cfg.autoScrub.pools != []) (
      lib.listToAttrs (map (pool: {
        name = "zfs-scrub-${pool}";
        value = {
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.zfs}/bin/zpool scrub ${pool}";
          };
        };
      }) cfg.autoScrub.pools)
    );
  };
}
