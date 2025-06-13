{ lib, config, pkgs, ... }:
let
  cfg = config.gui.mako;
in
{
  options.gui.mako.enable = lib.mkEnableOption "mako";

  config = lib.mkIf cfg.enable {
    services.mako = {
      enable = true;
    };
  };
}