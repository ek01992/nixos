# modules/home-manager/gui/rofi/default.nix
{ lib, config, inputs,pkgs, ... }:
let
  cfg = config.gui.mako;
in
{
  options.gui.mako.enable = lib.mkEnableOption "mako";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      mako
    ];
    programs.mako = {
      enable = true;
    };
  };
}