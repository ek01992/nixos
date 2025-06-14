{ lib, config, pkgs, ... }:
let
  cfg = config.gui.waybar;
in
{
  options.gui.waybar.enable = lib.mkEnableOption "waybar";

  config = lib.mkIf cfg.enable {
    programs.wofi = {
      enable = true;
      settings = {
      };
    };
  };
}