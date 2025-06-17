# modules/home-manager/services/swaylock/default.nix
{ lib, config, pkgs, ... }:

let
  cfg = config.services.swaylock;
in
{
  options.services.swaylock.enable = lib.mkEnableOption "swaylock";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ swaylock-fancy ];

    services.swayidle = {
      enable = true;
      systemdTarget = "hyprland-session.target";
      timeouts = [
        {
          # After 5 minutes of inactivity on battery, lock the screen.
          timeout = 300;
          command = ''
            if [[ $(cat /sys/class/power_supply/AC/online) -eq 0 ]]; then
              ${pkgs.swaylock-fancy}/bin/swaylock-fancy -f
            fi
          '';
        }
        {
          # After 10 minutes of inactivity on battery, turn the screen off.
          timeout = 600;
          command = ''
            if [[ $(cat /sys/class/power_supply/AC/online) -eq 0 ]]; then
              hyprctl dispatch dpms off
            fi
          '';
          resumeCommand = "hyprctl dispatch dpms on";
        }
      ];
      # Always lock the screen before the system goes to sleep.
      events = [
        { event = "before-sleep"; command = "${pkgs.swaylock-fancy}/bin/swaylock-fancy -f"; }
      ];
    };
  };
}