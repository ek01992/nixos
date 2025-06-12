{ lib, config, pkgs, ... }:
{
  options.modules.home-manager.helix.enable = lib.mkEnableOption "helix editor";

  config = lib.mkIf config.modules.home-manager.helix.enable {
    home.packages = with pkgs; [
      helix
    ];
    home.sessionVariables = {
      EDITOR = "hx";
    };
  };
}