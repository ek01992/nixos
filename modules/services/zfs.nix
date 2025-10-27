# ZFS Service Module
# Verification: zpool status
#               zpool list
#               systemctl status zfs-scrub@<pool>
#               systemctl status zfs-trim@<pool>
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

    enableScrub = mkOption {
      type = types.bool;
      default = true;
      description = "Enable automatic ZFS scrubbing";
    };

    enableTrim = mkOption {
      type = types.bool;
      default = true;
      description = "Enable ZFS trim";
    };
  };

  config = mkIf cfg.enable {
    services.zfs = {
      autoScrub.enable = cfg.enableScrub;
      trim.enable = cfg.enableTrim;
    };
  };
}
