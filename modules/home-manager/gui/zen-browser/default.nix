{ lib, config, pkgs, username, inputs, ... }:
{
  options.modules.home-manager.gui.zen-browser.enable = lib.mkEnableOption "zen";

  imports = [
    inputs.zen-browser.homeModules.twilight
  ];

  config = lib.mkIf config.modules.home-manager.gui.zen-browser.enable {
    programs.zen-browser = {
      enable = true;
      policies = {
        DisableAppUpdate = true;
        DisableTelemetry = true;
      };
    };
  };
}