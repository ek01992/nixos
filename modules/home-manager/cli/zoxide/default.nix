{ lib, config, pkgs, ... }:
let
  cfg = config.cli.zoxide;
in
{
  options.cli.zoxide.enable = lib.mkEnableOption "zoxide";

  config = lib.mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}