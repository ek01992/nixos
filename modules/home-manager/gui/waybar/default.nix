{ lib, config, pkgs, ... }:
let
  cfg = config.gui.waybar;
in
{
  options.gui.waybar.enable = lib.mkEnableOption "waybar";

  config = lib.mkIf cfg.enable {
    services.waybar = {
      enable = true;
      package = pkgs.waybar;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 30;
          modules-left = [ "hyprland/workspaces" "hyprland/mode" ];
          modules-center = [ "hyprland/window" ];
          modules-right = [ "tray" "clock" "pulseaudio" "network" "cpu" "memory" ];

          "hyprland/workspaces" = {
            format = "{name}: {icon}";
            format-icons = {
              "1" = "";
              "2" = "";
              "3" = "";
              "4" = "";
              "5" = "🎵";
              "urgent" = "";
              "focused" = "";
              "default" = "";
            };
          };

          tray = {
            icon-size = 21;
            spacing = 10;
          };

          clock = {
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            format-alt = "{:%Y-%m-%d}";
          };

          pulseaudio = {
            format = "{volume}% {icon} {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = " {icon} {format_source}";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = ["" "" ""];
            };
            on-click = "pavucontrol";
          };

          network = {
            format-wifi = "{essid} ({signalStrength}%) ";
            format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
            tooltip-format = "{ifname} via {gwaddr} ";
            format-linked = "{ifname} (No IP) ";
            format-disconnected = "Disconnected ⚠";
            format-alt = "{ifname}: {ipaddr}/{cidr}";
          };
        };
      };
    };

    home.packages = with pkgs; [
      pavucontrol
    ];
  };
}