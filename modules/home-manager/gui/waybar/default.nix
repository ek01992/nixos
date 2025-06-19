# modules/home-manager/gui/waybar/default.nix
{ lib, config, inputs,pkgs, ... }:
let
  cfg = config.gui.waybar;
in
{
  options.gui.waybar.enable = lib.mkEnableOption "waybar";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      waybar
    ];
    waybar = {
      enable = true;
    };
  };
}