{ config, lib, pkgs, ... }:
{
  options.gui.cursor.enable = lib.mkEnableOption "cursor";

  config = lib.mkIf config.gui.cursor.enable {
    home.packages = with pkgs; [
      code-cursor
    ];
  };
}