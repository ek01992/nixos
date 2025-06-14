{ lib, config, pkgs, ... }:
let
  cfg = config.gui.wofi;
in
{
  options.gui.wofi.enable = lib.mkEnableOption "wofi";

  config = lib.mkIf cfg.enable {
    programs.wofi = {
      enable = true;
      settings = {
      };
    };
  };
}