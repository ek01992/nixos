# modules/nixos/core/default.nix
{ lib, config, pkgs, ... }:
let
  cfg = config.nixos.core;
in
{
  options.nixos.core.enable = lib.mkEnableOption "core system settings";

  config = lib.mkIf cfg.enable {
    nix.extraOptions = "gc-keep-outputs = true";
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [ 
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      download-buffer-size = 524288000;
    };

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
    services.pulseaudio.enable = false;

    fonts = {
      packages = with pkgs; [
        font-awesome
        material-icons
      ];
    };

    environment.systemPackages = with pkgs; [
      alsa-ucm-conf
      bat
      cachix
      coreutils
      curl
      direnv
      dnsutils
      eza
      fastfetch
      fzf
      git
      jq
      lm_sensors
      nmap
      pavucontrol
      ripgrep
      tcpdump
      unzip
      wget
      whois
      wl-clipboard
      zoxide
    ];
  };
}