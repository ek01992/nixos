{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.system.locale;
in
{
  options.system.locale = {
    enable = mkEnableOption "locale configuration";

    timezone = mkOption {
      type = types.str;
      default = "America/Chicago";
      description = "System timezone";
    };

    defaultLocale = mkOption {
      type = types.str;
      default = "en_US.UTF-8";
      description = "Default system locale";
    };

    keyMap = mkOption {
      type = types.str;
      default = "us";
      description = "Console keymap";
    };

    extraLocaleSettings = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Additional locale settings";
    };
  };

  config = mkIf cfg.enable {
    time.timeZone = cfg.timezone;
    i18n.defaultLocale = cfg.defaultLocale;
    console.keyMap = cfg.keyMap;
    
    i18n.extraLocaleSettings = cfg.extraLocaleSettings;
  };
}
