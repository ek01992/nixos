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
    programs.waybar = {
      enable = true;
      settings = {
        layer = "top";
        position = "top";
        height = 32;
        spacing = 0;
        modules-left = [
          "hyprland/workspaces"
          "tray"
          "custom/lock"
          "custom/reboot"
          "custom/power"
        ];
        modules-center = [
          "hyprland/window"
        ];
        modules-right = [
          "network"
          "battery"
          "bluetooth"
          "pulseaudio"
          "backlight"
          "custom/temperature"
          "memory"
          "cpu"
          "clock"
        ];
      };
    };
  };
}