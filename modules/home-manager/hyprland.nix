{ lib, config, pkgs, ... }:
{
  options.modules.home-manager.hyprland.enable = lib.mkEnableOption "hyprland";

  config = lib.mkIf config.modules.home-manager.hyprland.enable {
    wayland.windowManager.hyprland = {
      enable = true;
  };
}