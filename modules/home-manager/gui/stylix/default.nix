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
          package = pkgs.nerd-fonts.fira-code;
          name = "FiraCode Nerd Font";
        };
        emoji = {
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };
      };

      image = ../../../../wal/rose.png;

      base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";

      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };

      targets = {
        kitty.enable = true;
        gtk.enable = true;
        hyprland.enable = true;
        waybar.enable = false;
        rofi.enable = false;
        firefox = {
          enable = true;
          profileNames = [
            "erik"
          ];
        };
      };
    };
  };
}