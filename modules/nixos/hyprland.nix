{ pkgs, ... }:
{
  # System-wide Hyprland configuration
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Enable SDDM as a graphical login manager
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
}