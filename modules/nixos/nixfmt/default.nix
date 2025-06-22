# modules/nixos/nixfmt/default.nix
{ lib, config, pkgs, ... }:
let
  cfg = config.nixos.nixfmt;
in
{
  options.nixos.nixfmt = {
    enable = lib.mkEnableOption "nixfmt";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.nixfmt-rfc-style ];
    programs.nixfmt-rfc-style = {
      enable = true;
    };
  };
}