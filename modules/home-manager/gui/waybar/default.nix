# modules/home-manager/gui/hyprland/default.nix
{ lib, config, inputs,pkgs, ... }:
let
  cfg = config.gui.hyprland;
in
{
  options.gui.hyprland.enable = lib.mkEnableOption "hyprland";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      waybar
    ];
    waybar = {
      enable = true;
    };
  };
}