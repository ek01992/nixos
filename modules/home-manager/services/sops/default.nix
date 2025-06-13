/*
{ lib, config, inputs, ... }:
let
  cfg = config.my.sops;
in
{
  options.my.sops.enable = lib.mkEnableOption "sops";

  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      age
    ];
    sops = {
      defaultSopsFile = ./secrets.yaml;
    };
  };
}
*/
{}