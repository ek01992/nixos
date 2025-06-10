{
  wayland.windowManager.hyprland = {
    settings = {
      monitor = ",preferred,auto,1";

      exec-once = "waybar & swww init";

      input = {
        kb_layout = "us";
        follow_mouse = 1;
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
      };

      bind = [
        "SUPER, Q, killactive,"
        "SUPER, M, exit,"
        "SUPER, E, exec, kitty"
        "SUPER, V, togglefloating,"
        "SUPER, P, pseudo,"
        "SUPER, J, togglesplit,"
        "SUPER, left, movefocus, l"
        "SUPER, right, movefocus, r"
        "SUPER, up, movefocus, u"
        "SUPER, down, movefocus, d"
      ];
    };
  };
}