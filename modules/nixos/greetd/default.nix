{ lib, config, pkgs, username, ... }: 
let
  cfg = config.my.nixos.greetd;
in
{
  options.my.nixos.greetd.enable = lib.mkEnableOption "greetd";

  config = lib.mkIf cfg.enable {
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