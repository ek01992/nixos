{ lib, config, pkgs, ... }:
{
  options.modules.home-manager.cli.helix.enable = lib.mkEnableOption "helix editor";

  config = lib.mkIf config.modules.home-manager.cli.helix.enable {
    home.sessionVariables = {
      EDITOR = "hx";
    };
  };
}