{ pkgs, ... }:
{

  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;

  services.dunst = {
    enable = true;
    settings = {
      global = {
        origin = "top-right";
        offset = "10x50";
        font = "JetBrainsMono Nerd Font 10";
      };
      urgency_low = {
        background = "#a3be8c";
        foreground = "#2e3440";
        timeout = 5;
      };
      urgency_normal = {
        background = "#ebcb8b";
        foreground = "#2e3440";
        timeout = 10;
      };
      urgency_critical = {
        background = "#bf616a";
        foreground = "#d8dee9";
        frame_color = "#bf616a";
        timeout = 0;
      };
    };
  };
}