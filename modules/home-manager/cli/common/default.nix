{ lib, config, pkgs, ... }:
{
  options.modules.home-manager.cli.common.enable = lib.mkEnableOption "basic cli tools";

  config = lib.mkIf config.modules.home-manager.cli.common.enable {
    home.packages = with pkgs; [
      htop
      fastfetch
      waybar
      libnotify
      dunst
      swww
      wofi
      helix
    ];
  };
}