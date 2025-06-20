# modules/home-manager/gui/rofi/default.nix
{ lib, config, inputs,pkgs, ... }:
let
  cfg = config.gui.rofi;
in
{
  options.gui.rofi.enable = lib.mkEnableOption "rofi";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      rofi-wayland
    ];
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      extraConfig = {
        modi = "drun,filebrowser,run";
        show-icons = true;
        icon-theme = "Papirus";
        font = "JetBrainsMono Nerd Font Mono 12";
        drun-display-format = "{icon} {name}";
        display-drun = " Apps";
        display-run = " Run";
        display-filebrowser = " File";
      };
    };
  };
}