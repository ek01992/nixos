{ lib, config, pkgs, ... }:
let
  cfg = config.my.nixos.greetd;
in
{
  options.my.nixos.greetd = {
    enable = lib.mkEnableOption "greetd";

    # This 'user' option is what's missing from your current file.
    user = lib.mkOption {
      type = lib.types.str;
      default = "erik"; # Setting a default is good practice
      description = "The user to log in automatically with greetd.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "${pkgs.hyprland}/bin/Hyprland";
          user = cfg.user; # This line can now find the option
        };
        default_session = initial_session;
      };
    };
  };
}