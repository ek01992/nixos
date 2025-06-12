{ lib, config, pkgs, ... }:
{
  options.modules.home-manager.cli.zsh.enable = lib.mkEnableOption "zsh";

  config = lib.mkIf config.modules.home-manager.cli.zsh.enable {
    programs.zsh = {
      enable = true;
    };
  };
}