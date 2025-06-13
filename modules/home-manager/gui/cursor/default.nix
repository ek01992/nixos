{
  config,
  lib,
  pkgs,
  ...
}: {
  options.my.gui.cursor.enable = lib.mkEnableOption "cursor";

  config = lib.mkIf config.my.gui.cursor.enable {
    home.packages = with pkgs; [
      code-cursor
    ];
  };
}