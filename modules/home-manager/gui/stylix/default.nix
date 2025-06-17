# modules/home-manager/gui/stylix/default.nix
{ config, pkgs, lib, inputs, ... }:
let
  cfg = config.gui.stylix;
in
{
  imports = [
    inputs.stylix.homeModules.stylix
  ];

  options.gui.stylix.enable = lib.mkEnableOption "stylix";

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      fonts = {
        monospace = {
          package = pkgs.nerdfonts.override { fonts =; };
          name = "JetBrainsMono Nerd Font";
        };
        emoji = {
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };
      };
      targets = {
        kitty.enable = true;
        gtk.enable = true;
        hyprland = {
          enable = true;
          hyprpaper.enable = true;
        };
        firefox = {
          enable = true;
          profileNames = [
            "erik"
          ];
        };
        waybar.enable = true;
      };
    };
  };
}