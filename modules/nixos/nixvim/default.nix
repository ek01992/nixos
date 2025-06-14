{ lib, config, pkgs, ... }:
let
  cfg = config.nixos.nixvim;
in
{
  options.nixos.nixvim.enable = lib.mkEnableOption "nixvim";

  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      enable = true;
      colorschemes.dracula.enable = true;
      plugins.lualine.enable = true;
    };
  };
}