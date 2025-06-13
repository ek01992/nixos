{ lib, config, pkgs, ... }:
let
  cfg = config.my.gui.firefox;
in
{
  options.my.gui.firefox.enable = lib.mkEnableOption "firefox";

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      profiles.erik = {
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          proton-pass
          dracula-dark-colorscheme
        ];
      };
    };
  };
}