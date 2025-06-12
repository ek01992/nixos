{ lib, config, pkgs, ... }:
{
  options.modules.nixos.core.enable = lib.mkEnableOption "core system settings";

  config = lib.mkIf config.modules.nixos.core.enable {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    time.timeZone = "America/Chicago";
    i18n.defaultLocale = "en_US.UTF-8";
    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
      git
      curl
      wget
      kitty
    ];
  };
}