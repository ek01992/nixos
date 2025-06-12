{ lib, config, pkgs, username, inputs, ... }:
{
  options.modules.home-manager.zen-browser.enable = lib.mkEnableOption "zen";

  imports = [
    inputs.zen-browser.homeManagerModules.twilight
  ];

  config = lib.mkIf config.modules.home-manager.zen-browser.enable {
    programs.zen-browser = {
      enable = true;
      policies = {
        DisableAppUpdate = true;
        DisableTelemetry = true;
      };
    };
  };
}