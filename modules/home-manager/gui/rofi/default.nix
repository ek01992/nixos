# modules/home-manager/gui/rofi/default.nix
{ lib, config, inputs,pkgs, ... }:
let
  cfg = config.gui.rofi;
in
{
  options.gui.rofi.enable = lib.mkEnableOption "rofi";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      rofi
    ];
    programs.rofi = {
      enable = true;
    };
  };
}