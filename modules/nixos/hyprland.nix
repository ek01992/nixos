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

  programs.rofi = {
    enable = true;
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        "modules-left" = [ "hyprland/workspaces" "hyprland/mode" ];
        "modules-center" = [ "hyprland/window" ];
        "modules-right" = [ "pulseaudio" "network" "cpu" "memory" "clock" ];
        "hyprland/workspaces" = {
          "on-click" = "activate";
          "format" = "{icon}";
          "format-icons" = {
            "1" = "";
            "2" = "";
            "3" = "";
            "4" = "";
            "5" = "";
            "urgent" = "";
            "default" = "";
          };
        };
        "hyprland/window" = {
          "max-length" = 30;
        };
        clock = {
          "format" = "{:%H:%M}";
          "tooltip-format" = "<big>{:%Y-%m-%d}</big>\n<tt><small>{calendar}</small></tt>";
        };
      };
    };
    style = ''
      * {
          border: none;
          font-family: "JetBrainsMono Nerd Font";
          font-size: 13px;
          min-height: 0;
      }
      window#waybar {
          background: rgba(46, 52, 64, 0.8);
          color: #d8dee9;
      }
      #workspaces button {
          padding: 0 5px;
          background: transparent;
          color: #d8dee9;
      }
      #workspaces button.active {
          color: #88c0d0;
      }
      #workspaces button:hover {
          background: #4c566a;
      }
    '';
  };
}