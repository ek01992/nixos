{ lib, config, inputs, ... }:
let
  cfg = config.my.gui.firefox;
in
{
  options.my.gui.firefox.enable = lib.mkEnableOption "zen";

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      policies = {
        DisableTelemetry = true;
        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          "jid1-MnnxcxisBPnSXQ@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
            installation_mode = "force_installed";
          };
          "78272b6fa58f4a1abaac99321d503a20@proton.me" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/proton-pass/latest.xpi";
            installation_mode = "force_installed";
          };
        };
      };
    };
  };
}