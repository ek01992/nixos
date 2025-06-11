{ config, pkgs, ... }:
{
  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs; [
    rofi-wayland
    waybar
    nwg-look
    nwg-displays
  ];
}