{ lib, config, pkgs, ... }:
{
  options.modules.desktops.wm.wayland.hyprland.enable = lib.mkEnableOption "hyprland wayland windows manager";

  config = lib.mkIf config.modules.desktops.wm.wayland.hyprland.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };

    programs.uwsm.enable = true;

    environment.systemPackages = with pkgs; [
      rofi-wayland
      waybar
      nwg-look
      nwg-displays
    ];
  };
}