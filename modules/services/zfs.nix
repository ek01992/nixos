{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myServices.zfs;
in
{
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
