{ lib, config, pkgs, username, ... }:
{
  options.modules.nixos.greetd.enable = lib.mkEnableOption "greetd";

  config = lib.mkIf config.modules.nixos.greetd.enable {
    services.greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "${pkgs.hyprland}/bin/Hyprland";
          user = username;
        };
        default_session = initial_session;
      };
    };
  };
}