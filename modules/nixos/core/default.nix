{ lib, config, pkgs, ... }:
let
  cfg = config.nixos.core;
in
{
  options.nixos.core.enable = lib.mkEnableOption "core system settings";

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
        font-awesome
        material-icons
      ];
    };

    environment.systemPackages = with pkgs; [
      git
      curl
      wget
      alsa-ucm-conf
      pavucontrol
      eza
      bat
      coreutils
      direnv
      dnsutils
      nmap
      whois
      unzip
      age
      sops
      ssh-to-age
      fastfetch
      jq
      tcpdump
      zoxide
      fzf
      ripgrep
      libnotify
      mako
    ];
  };
}