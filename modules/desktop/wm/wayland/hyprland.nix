{ lib, config, pkgs, inputs, ... }:
{
  options.modules.desktops.wm.wayland.hyprland.enable = lib.mkEnableOption "hyprland wayland windows manager";

  config = lib.mkIf config.modules.desktops.wm.wayland.hyprland.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    };

    programs.uwsm.enable = true;
  };
}