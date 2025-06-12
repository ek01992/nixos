{ lib, config, pkgs, ... }:
{
  options.modules.home-manager.hyprland.enable = lib.mkEnableOption "hyprland";

  config = lib.mkIf config.modules.home-manager.hyprland.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        general = {
          "$mod" = "SUPER";
          gaps_in = 6;
          gaps_out = 8;
          border_size = 2;
          resize_on_border = true;
          layout = "dwindle";
          allow_tearing = true;
        };

        input = {
            kb_layout = "us";
            follow_mouse = true;
            touchpad = {
              natural_scroll = true;
            };
            accel_profile = "flat";
            sensitivity = 0;
          };

        bind = [
          "$mod SHIFT,Return,exec,rofi-launcher"
          "$mod,Return,exec,kitty"
          "$mod,W,exec,firefox"
          "$mod,Q,killactive,"
          "$mod SHIFT,I,togglesplit,"
          "$mod,F,fullscreen,"
          "$mod SHIFT,F,togglefloating,"
          "$mod ALT,F,workspaceopt, allfloat"
          "$mod SHIFT,C,exit,"
          "$mod SHIFT,left,movewindow,l"
          "$mod SHIFT,right,movewindow,r"
          "$mod SHIFT,up,movewindow,u"
          "$mod SHIFT,down,movewindow,d"
          "$mod SHIFT,h,movewindow,l"
          "$mod SHIFT,l,movewindow,r"
          "$mod SHIFT,k,movewindow,u"
          "$mod SHIFT,j,movewindow,d"
          "$mod ALT, left, swapwindow,l"
          "$mod ALT, right, swapwindow,r"
          "$mod ALT, up, swapwindow,u"
          "$mod ALT, down, swapwindow,d"
          "$mod ALT, 43, swapwindow,l"
          "$mod ALT, 46, swapwindow,r"
          "$mod ALT, 45, swapwindow,u"
          "$mod ALT, 44, swapwindow,d"
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
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

        cursor = {
          sync_gsettings_theme = true;
          no_hardware_cursors = 2;
          enable_hyprcursor = false;
          warp_on_change_workspace = 2;
          no_warps = true;
        };

        extraConfig = ''
          monitor=,preferred,auto,auto
          monitor=eDP-1,1920x1200@60,auto,1
        '';

        animations = {
          enabled = true;
          bezier = [
            "overshot, 0.05, 0.9, 0.1, 1.05"
            "smoothOut, 0.5, 0, 0.99, 0.99"
            "smoothIn, 0.5, -0.5, 0.68, 1.5"
          ];
          animation = [
            "windows, 1, 5, overshot, slide"
            "windowsOut, 1, 3, smoothOut"
            "windowsIn, 1, 3, smoothOut"
            "windowsMove, 1, 4, smoothIn, slide"
            "border, 1, 5, default"
            "fade, 1, 5, smoothIn"
            "fadeDim, 1, 5, smoothIn"
            "workspaces, 1, 6, default"
          ];
        };

        env = [
          "NIXOS_OZONE_WL, 1"
          "NIXPKGS_ALLOW_UNFREE, 1"
          "XDG_CURRENT_DESKTOP, Hyprland"
          "XDG_SESSION_TYPE, wayland"
          "XDG_SESSION_DESKTOP, Hyprland"
          "GDK_BACKEND, wayland, x11"
          "CLUTTER_BACKEND, wayland"
          "QT_QPA_PLATFORM=wayland;xcb"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
          "QT_AUTO_SCREEN_SCALE_FACTOR, 1"
          "SDL_VIDEODRIVER, x11"
          "MOZ_ENABLE_WAYLAND, 1"
          # Disabling this by default as it can result in inop cfg
          # Added card2 in case this gets enabled. For better coverage
          # This is mostly needed by Hybrid laptops.
          #"AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1:/dev/card2"
          "GDK_SCALE,1"
          "QT_SCALE_FACTOR,1"
          "EDITOR,hx"
        ];

        decoration = {
          rounding = 10;
          blur = {
            enabled = true;
            size = 5;
            passes = 3;
            ignore_opacity = false;
            new_optimizations = true;
          };

          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
            color = "rgba(1a1a1aee)";
          };
        };
        systemd.enable = true;
      };
    };
  };
}