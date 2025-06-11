{ lib, config, pkgs, ... }:
{
  options.modules.desktops.wm.wayland.hyprland.enable = lib.mkEnableOption "hyprland";

  config = lib.mkIf config.modules.desktops.wm.wayland.hyprland.enable {
    programs.hyprland.enable = true;

    environment.systemPackages = with pkgs; [
      rofi-wayland
      waybar
      nwg-look
      nwg-displays
    ];
  };
}