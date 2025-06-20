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
        font = "JetBrainsMono Nerd Font Mono 12";
        drun-display-format = "{name}";
        sidebar-mode = false;
      };
      theme = let
        inherit (config.lib.formats.rasi) mkLiteral;
      in {
        "*" = {
          bg = mkLiteral "#${config.stylix.base16Scheme.base00}";
          bg-alt = mkLiteral "#${config.stylix.base16Scheme.base09}";
          foreground = mkLiteral "#${config.stylix.base16Scheme.base01}";
          selected = mkLiteral "#${config.stylix.base16Scheme.base08}";
          active = mkLiteral "#${config.stylix.base16Scheme.base0B}";
          text-selected = mkLiteral "#${config.stylix.base16Scheme.base00}";
          text-color = mkLiteral "#${config.stylix.base16Scheme.base05}";
          border-color = mkLiteral "#${config.stylix.base16Scheme.base0F}";
          urgent = mkLiteral "#${config.stylix.base16Scheme.base0E}";
        };
      };
    };
  };
}