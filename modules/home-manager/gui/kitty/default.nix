{ lib, config, pkgs, ... }:
let
  cfg = config.my.gui.kitty;
in
{
  options.my.gui.kitty.enable = lib.mkEnableOption "kitty";

  config = lib.mkIf cfg.enable {
    programs.kitty = lib.mkForce {
      enable = true;
      settings = {
        confirm_os_window_close = 0;
        dynamic_background_opacity = true;
        enable_audio_bell = false;
        mouse_hide_wait = "-1.0";
        window_padding_width = "10";
      };
    };
  };
}