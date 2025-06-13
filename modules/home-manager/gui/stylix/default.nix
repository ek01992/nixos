{ lib, config, inputs, pkgs, ... }:
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
      base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";

      image = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/ek01992/wal/refs/heads/main/qhj152f5dc3f1.jpeg";
        sha256 = "32d1e9307e1745bf55227135b9c6a16cff63115571edbd58eb3bd2df7a6700be";
      };

      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };

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
      };
    };
  };
}