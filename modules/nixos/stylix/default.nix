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
      base24-schemes
    ];

    stylix = {
      enable = true;
      base24Scheme = "${pkgs.base24-schemes}/share/themes/dracula.yaml";
    };
  };
}