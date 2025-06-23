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
      theme = let
        inherit (config.lib.formats.rasi) mkLiteral;
      in {
        "*" = {
        };
        "window" = {
          width = mkLiteral "40%";
          transparency = "real";
        };
        "prompt" = { 
          enabled = false;
        };
        "entry" = {
          placeholder = mkLiteral "Search...";
          expand = true;
          padding = mkLiteral "1.5%";
          border-radius = mkLiteral "8px";
        };
        "inputbar" = {
          children = map mkLiteral [ "prompt" "entry" ];
          background-image = mkLiteral ''url("../../../../wal/rose.png", height)'';
          expand = false;
          border-radius = mkLiteral "0px 0 8px 8px";
          padding = mkLiteral "100px 30px 30px 300px";
        };
        "listview" = {
          columns = mkLiteral "1";
          lines = mkLiteral "4";
          cycle = false;
          dynamic = true;
          layout = mkLiteral "vertical";
          padding = mkLiteral "30px 200px 30px 30px";
        };
        "mainbox" = {
          children = map mkLiteral [ "inputbar" "listview" ];
        };
        "element" = {
          orientation = mkLiteral "vertical";
          padding = mkLiteral "10px 0px";
          border-radius = mkLiteral "8px";
        };
        "element-text" = {
          expand = true;
          vertical-align = mkLiteral "0.5";
          margin = mkLiteral "0.5% 3% 0% 3%";
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
        };
        "element-icon" = {
          background-color = mkLiteral "transparent";
        };
        "element selected" = {
          border-radius = mkLiteral "8px";
        };
      };
    };
  };
}