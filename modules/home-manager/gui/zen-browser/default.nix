{ lib, config, inputs, ... }:
let
  cfg = config.my.gui.zen-browser;
in
{
  options.my.gui.zen-browser.enable = lib.mkEnableOption "zen";

  imports = [
    inputs.zen-browser.homeModules.twilight
  ];

  config = lib.mkIf cfg.enable {
    programs.zen-browser = {
      enable = true;
      policies = {
        DisableAppUpdate = true;
        DisableTelemetry = true;
      };
    };
  };
}