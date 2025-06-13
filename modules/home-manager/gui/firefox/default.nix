{ lib, config, inputs, nur, ... }:
let
  cfg = config.my.gui.firefox;
in
{
  options.my.gui.firefox.enable = lib.mkEnableOption "firefox";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs.nur.repos.rycee.firefox-addons; [
      ublock-origin
      proton-pass
      dracula-dark-colorscheme
    ];
    programs.firefox = {
      enable = true;
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          proton-pass
          dracula-dark-colorscheme
      ];
      profiles.erik = {
        settings = {
          "extensions.activeThemeID" = "dracula-dark-colorscheme@protonmail.ch";
        };
      }
    };
  };
}