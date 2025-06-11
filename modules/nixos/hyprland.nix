{ pkgs, ... }:
{

  # nix.settings = {
    # substituters = ["https://hyprland.cachix.org"];
    # trusted-substituters = ["https://hyprland.cachix.org"];
    # trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  # };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    # xwayland.enable = true;
  };
  
  # xdg.portal = {
    # enable = true;
    # extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  # };

  # services.xserver.enable = true;
  # services.displayManager.sddm.enable = true;
}