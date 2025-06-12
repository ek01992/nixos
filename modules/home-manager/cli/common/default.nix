{ lib, config, pkgs, ... }:
let
  cfg = config.my.cli.common;
in
{
  options.my.cli.common.enable = lib.mkEnableOption "basic cli tools";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      htop
      fastfetch
      waybar
      libnotify
      dunst
      swww
      wofi
    ];
  };
}