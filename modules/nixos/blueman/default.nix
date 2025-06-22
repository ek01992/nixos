{ config, lib, pkgs, ... }:
let
  cfg = config.nixos.blueman;
in
{
  options.nixos.blueman = {
    enable = lib.mkEnableOption "blueman";
  };

  config = lib.mkIf cfg.enable {
    services.blueman.enable = true;
  };
}