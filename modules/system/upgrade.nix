# System Upgrade Configuration Module
# Verification: systemctl status nixos-upgrade.timer
#               systemctl list-timers | grep upgrade
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.mySystem.upgrade;
  inherit (lib) mkEnableOption mkOption mkIf types;
in {
  options.mySystem.upgrade = {
    enable = mkEnableOption "automatic system upgrades";

    dates = mkOption {
      type = types.str;
      default = "weekly";
      description = "Cron schedule for auto-upgrade";
      example = "daily at 02:00";
    };

    allowReboot = mkOption {
      type = types.bool;
      default = true;
      description = "Allow automatic reboots after upgrade";
    };
  };

  config = mkIf cfg.enable {
    # Auto-upgrade configuration with overridable defaults
    system.autoUpgrade = {
      enable = lib.mkDefault true;
      dates = lib.mkDefault cfg.dates;
      allowReboot = lib.mkDefault cfg.allowReboot;
    };
  };
}
