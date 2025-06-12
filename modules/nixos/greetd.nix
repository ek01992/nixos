{ lib, config, pkgs, ... }:
{
  options.modules.nixos.greetd.enable = lib.mkEnableOption "greetd";

  config = lib.mkIf config.modules.nixos.greetd.enable {
    services.greetd = {
      enable = true;
      vt = 1;
      settings = {
        default_session = {
          command = "${pkgs.greetd.greetd}/bin/agreety --cmd hyprland";
        };
      };
    };
  };
}