{ lib, config, pkgs, ... }:
let
  cfg = config.nixos.nixvim;
in
{
  imports = [
    inputs.nixvim.nixosModules.nixvim
  ];
  options.nixos.nixvim.enable = lib.mkEnableOption "nixvim";

  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      enable = true;
      colorschemes.dracula.enable = true;
      plugins.lualine.enable = true;
    };
  };
}