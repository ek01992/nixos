# modules/home-manager/gui/fonts/default.nix
{ config, pkgs, lib, inputs, ... }:
let
  cfg = config.gui.fonts;
in
{
  imports = [
    inputs.stylix.homeModules.stylix
  ];

  options.gui.fonts.enable = lib.mkEnableOption "fonts";

  config = lib.mkIf cfg.enable {
    stylix = {
      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font Mono";
        };
        emoji = {
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };
      };
    };
  };
}