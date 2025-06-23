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
        modi = "drun";
        display-drun = "";
        font = "FiraCode Nerd Font 12";
        drun-display-format = "{name}";
        sidebar-mode = false;
      };
    };
  };
}