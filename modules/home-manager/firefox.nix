{ lib, config, pkgs, ... }:
{
  options.modules.home-manager.firefox.enable = lib.mkEnableOption "firefox";

  config = lib.mkIf config.modules.home-manager.firefox.enable {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox;
    };
  };
}