# modules/nixos/hyprland/default.nix
{ lib, config, inputs, pkgs, ... }:
let
  cfg = config.nixos.hyprland;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  options.nixos.hyprland.enable = lib.mkEnableOption "hyprland";

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
      xwayland.enable = false;
    };
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };
}