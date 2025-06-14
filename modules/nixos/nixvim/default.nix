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

    plugins = with pkgs.vimPlugins; [
      nvim-lspconfig
      nvim-treesitter.withAllGrammars
      telescope-nvim
      lualine-nvim
    ];

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