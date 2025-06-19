# modules/home-manager/gui/waybar/default.nix
{ config, lib, pkgs, ... }:
{
  options.gui.waybar.enable = lib.mkEnableOption "waybar";
  config = lib.mkIf config.gui.waybar.enable {
    home.packages = with pkgs; [
      waybar
    ];

    waybar = {
      enable = true;
    };
  };
}