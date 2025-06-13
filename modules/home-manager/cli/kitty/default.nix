{ lib, config, pkgs, ... }:
let
  cfg = config.my.cli.kitty;
in
{
  options.my.cli.kitty.enable = lib.mkEnableOption "kitty";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      kitty
    ];

    programs.kitty = lib.mkForce {
      enable = true;
      settings = {
        confirm_os_window_close = 0;
        dynamic_background_opacity = true;
        enable_audio_bell = false;
        mouse_hide_wait = "-1.0";
        window_padding_width = "10";
        background_opacity = "0.5";
        background_blur = 5;
      };
    };
  };
}