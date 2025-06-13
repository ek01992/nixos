{ lib, config, pkgs, ... }:
let
  cfg = config.cli.zsh;
in
{
  options.cli.zsh.enable = lib.mkEnableOption "zsh";

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
    };
  };
}