{ lib, config, pkgs, ... }:
let
  cfg = config.my.cli.zsh;
in
{
  options.my.cli.zsh.enable = lib.mkEnableOption "zsh";

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
    };
  };
}