{ lib, config, pkgs, ... }:
let
  cfg = config.cli.nixvim;
in
{
  options.cli.nixvim.enable = lib.mkEnableOption "nixvim";

  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      enable = true;
      colorschemes.dracula.enable = true;
      plugins.lualine.enable = true;
    };
  };
}