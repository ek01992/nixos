{ lib, config, pkgs, ... }:
{
  options.modules.home-manager.cli.enable = lib.mkEnableOption "basic cli tools";

  config = lib.mkIf config.modules.home-manager.cli.enable {
    home.packages = with pkgs; [
      htop
      fastfetch
    ];
  };
}