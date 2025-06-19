# modules/home-manager/gui/hyprland/default.nix
{ lib, config, inputs,pkgs, ... }:
let
  cfg = config.gui.hyprland;
in
{
  options.gui.hyprland.enable = lib.mkEnableOption "hyprland";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      swww
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        general = {
          "$mod" = "SUPER";
          gaps_in = 4;
          gaps_out = 8;
          border_size = 0;
          col.active_border = "rgb(FF90BC) rgb(5FBDFF) 45deg";
          col.inactive_border = "rgba(00000000)";
          layout = "dwindle";
          allow_tearing = false;
          monitor = [
            ",preferred,auto,auto"
            "eDP-1,1920x1200@60,auto,1"
          ];
        };

        decoration = {
          rounding = 15;
          rounding_power = 4;
          active_opacity = 0.93;
          inactive_opacity = 0.87;
          shadow = {
            enabled = false;
            range = 8;
            render_power = 4;
            color = "rgba(00000033)";
          };
          blur = {
            enabled = true;
            size = 8;
            passes = 2;
            new_optimizations = true;
            ignore_opacity = false;
            vibrancy = 0.25;
          };
        };

        input = {
          kb_layout = "us";
          follow_mouse = true;
          touchpad.natural_scroll = true;
          accel_profile = "flat";
          sensitivity = 0;
        };

        cursor = {
          sync_gsettings_theme = true;
          no_hardware_cursors = 2;
          enable_hyprcursor = false;
          warp_on_change_workspace = 2;
          no_warps = true;
        };

        animations = {
          enabled = true;

          bezier = [
            "myBezier, 0.05, 0.9, 0.1, 1.05"
            "wobbly, 0.4, 1.8, 0.2, 1.1"
          ];

          animation = [
            "windows, 1, 6, myBezier, slide"
            "windowsOut, 1, 6, default, popin"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default, slide"
          ];
        };

        windowrule = [
          "opacity 0.8 0.4,class:kitty"
          "float, class:(pavucontrol)"
        ];

        exec-once = [
          "waybar"
          "swww-daemon"
          "sleep 1 && swww img ${config.stylix.image}"
        ];

        dwindle = {
          pseudotile = "yes";
          preserve_split = "yes";
        };

        bind = [
          "$mod,Return,exec,kitty"
          "$mod,D,exec,rofi -show drun"
          "$mod,W,exec,firefox"
          "$mod,Q,killactive,"
          "$mod SHIFT,I,togglesplit,"
          "$mod,F,fullscreen,"
          "$mod SHIFT,F,togglefloating,"
          "$mod ALT,F,workspaceopt,allfloat"
          "$mod SHIFT,C,exit,"
          "$mod SHIFT,left,movewindow,l"
          "$mod SHIFT,right,movewindow,r"
          "$mod SHIFT,up,movewindow,u"
          "$mod SHIFT,down,movewindow,d"
          "$mod SHIFT,h,movewindow,l"
          "$mod SHIFT,l,movewindow,r"
          "$mod SHIFT,k,movewindow,u"
          "$mod SHIFT,j,movewindow,d"
          "$mod ALT,left,swapwindow,l"
          "$mod ALT,right,swapwindow,r"
          "$mod ALT,up,swapwindow,u"
          "$mod ALT,down,swapwindow,d"
          "$mod ALT,43,swapwindow,l"
          "$mod ALT,46,swapwindow,r"
          "$mod ALT,45,swapwindow,u"
          "$mod ALT,44,swapwindow,d"
          "$mod,left,movefocus,l"
          "$mod,right,movefocus,r"
          "$mod,up,movefocus,u"
          "$mod,down,movefocus,d"
          "$mod,h,movefocus,l"
          "$mod,l,movefocus,r"
          "$mod,k,movefocus,u"
          "$mod,j,movefocus,d"
          "$mod,1,workspace,1"
          "$mod,2,workspace,2"
          "$mod,3,workspace,3"
          "$mod,4,workspace,4"
          "$mod,5,workspace,5"
          "$mod,6,workspace,6"
          "$mod,7,workspace,7"
          "$mod,8,workspace,8"
          "$mod,9,workspace,9"
          "$mod,0,workspace,10"
          "$mod SHIFT,SPACE,movetoworkspace,special"
          "$mod,SPACE,togglespecialworkspace"
          "$mod SHIFT,1,movetoworkspace,1"
          "$mod SHIFT,2,movetoworkspace,2"
          "$mod SHIFT,3,movetoworkspace,3"
          "$mod SHIFT,4,movetoworkspace,4"
          "$mod SHIFT,5,movetoworkspace,5"
          "$mod SHIFT,6,movetoworkspace,6"
          "$mod SHIFT,7,movetoworkspace,7"
          "$mod SHIFT,8,movetoworkspace,8"
          "$mod SHIFT,9,movetoworkspace,9"
          "$mod SHIFT,0,movetoworkspace,10"
          "$mod CONTROL,right,workspace,e+1"
          "$mod CONTROL,left,workspace,e-1"
          "$mod,mouse_down,workspace, e+1"
          "$mod,mouse_up,workspace, e-1"
          "ALT,Tab,cyclenext"
          "ALT,Tab,bringactivetotop"
        ];

        bindm = [
          "$mod,mouse:272,movewindow"
          "$mod,mouse:273,resizewindow"
        ];

        env = [
          "NIXOS_OZONE_WL,1"
          "NIXPKGS_ALLOW_UNFREE,1"
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
          "XDG_SESSION_DESKTOP,Hyprland"
          "GDK_BACKEND,wayland,x11"
          "CLUTTER_BACKEND,wayland"
          "QT_QPA_PLATFORM=wayland;xcb"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
          "QT_AUTO_SCREEN_SCALE_FACTOR,1"
          "SDL_VIDEODRIVER,x11"
          "MOZ_ENABLE_WAYLAND,1"
          "GDK_SCALE,1"
          "QT_SCALE_FACTOR,1"
          "EDITOR,nvim"
        ];
      };
    };
  };
}