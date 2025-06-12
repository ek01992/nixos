{ lib, config, pkgs, ... }:
let
  cfg = config.my.nixos.core;
in
{
  options.my.nixos.core.enable = lib.mkEnableOption "core system settings";

  config = lib.mkIf cfg.enable {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    time.timeZone = "America/Chicago";
    i18n.defaultLocale = "en_US.UTF-8";
    nixpkgs.config.allowUnfree = true;

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    fonts = {
      packages = with pkgs; [
        noto-fonts-emoji
        noto-fonts-cjk-sans
        font-awesome
        symbola
        material-icons
        fira-code
        fira-code-symbols
      ];
    };

    environment.systemPackages = with pkgs; [
      git
      curl
      wget
      kitty
    ];
  };
}