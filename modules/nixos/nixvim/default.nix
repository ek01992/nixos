{ lib, config, pkgs, inputs, ... }:
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
    defaultEditor = true;

    plugins = {
      lsp.enable = true;
      treesitter.enable = true;
      telescope.enable = true;
      lualine.enable = true;
    };


    opts = {
      number = true;
      relativenumber = true;
      hlsearch = true;
    };

    keymaps = [
      {
        key = "<leader>ff";
        action = "<cmd>Telescope find_files<cr>";
        options.desc = "Find Files";
      } ];
    };
  };
}