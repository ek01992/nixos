{ lib, config, inputs, username, pkgs, ... }:
let
  cfg = config.my.nixos.hyprland;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  options.my.nixos.hyprland.enable = lib.mkEnableOption "hyprland";

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}