# Locale Configuration Module
# Verification: timedatectl status
#               localectl status
#               cat /etc/timezone
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.mySystem.locale;
  inherit (lib) mkEnableOption mkOption mkIf types;
in {
  options.mySystem.locale = {
    enable = mkEnableOption "locale configuration";

    timezone = mkOption {
      type = types.str;
      default = "America/Chicago";
      description = "System timezone";
      example = "America/New_York";
    };

    defaultLocale = mkOption {
      type = types.str;
      default = "en_US.UTF-8";
      description = "Default system locale";
      example = "en_GB.UTF-8";
    };

    keyMap = mkOption {
      type = types.str;
      default = "us";
      description = "Console keymap";
      example = "dvorak";
    };

    extraLocaleSettings = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Additional locale settings";
      example = {LC_TIME = "en_GB.UTF-8";};
    };
  };

  config = mkIf cfg.enable {
    time.timeZone = cfg.timezone;
    i18n.defaultLocale = cfg.defaultLocale;
    console.keyMap = cfg.keyMap;

    i18n.extraLocaleSettings = cfg.extraLocaleSettings;
  };
}
