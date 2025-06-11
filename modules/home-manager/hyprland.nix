{ lib, config, pkgs, inputs, ... }:
{
  options.modules.home-manager.hyprland.enable = lib.mkEnableOption "hyprland wayland windows manager";

  config = lib.mkIf config.modules.home-manager.hyprland.enable {
    wayland.windowManager.hyprland = {
      enable = true;
    };
  };
}