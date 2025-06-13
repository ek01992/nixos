{ lib, config, inputs, pkgs, ... }:
let
  cfg = config.my.nixos.stylix;
in
{
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  options.my.nixos.stylix.enable = lib.mkEnableOption "stylix";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      base16-schemes
    ];

    stylix = {
      enable = true;
      image = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/ek01992/wal/refs/heads/main/qhj152f5dc3f1.jpeg";
        sha256 = "32d1e9307e1745bf55227135b9c6a16cff63115571edbd58eb3bd2df7a6700be";
      };
    };
  };
}