{ lib, config, inputs, pkgs, ... }:
let
  cfg = config.my.gui.stylix;
in
{
  imports = [
    inputs.stylix.homeManagerModules.stylix
  ];

  options.my.gui.stylix.enable = lib.mkEnableOption "stylix";

  config = lib.mkIf cfg.enable {

    stylix = {
      enable = true;
      image = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/ek01992/wal/refs/heads/main/qhj152f5dc3f1.jpeg";
        sha256 = "32d1e9307e1745bf55227135b9c6a16cff63115571edbd58eb3bd2df7a6700be";
      };
      targets.kitty.enable = true;
    };
  };
}