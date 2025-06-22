# modules/nixos/mako/default.nix
{ lib, config, pkgs, ... }:
let
  cfg = config.nixos.mako;
in
{
  options.nixos.mako = {
    enable = lib.mkEnableOption "mako";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.mako ];
  };
}