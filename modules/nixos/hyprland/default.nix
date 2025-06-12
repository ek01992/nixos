{ lib, config, inputs, username, pkgs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  options.modules.nixos.hyprland.enable = lib.mkEnableOption "hyprland";

  config = lib.mkIf config.modules.nixos.hyprland.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}