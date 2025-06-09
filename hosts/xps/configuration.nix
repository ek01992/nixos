{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports =
    [
      ./hardware-configuration.nix
      ../../users/erik/user.nix
      inputs.home-manager.nixosModules.home-manager
      inputs.hyprland.nixosModules.default
      ../../modules/home-manager.nix
    ];
  nixpkgs.config.allowUnfree = true;
  networking = {
    networkmanager.enable = true;
    hostName = "xps"; # edit this to your liking
  };

  # nix
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # locales
  # https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  # audio
  # sound.enable = true;
  # nixpkgs.config.pulseaudio = true;
  # hardware.pulseaudio.enable = true;

  # ssh
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no"; # do not allow to login as root user
    };
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # installed packages
  environment.systemPackages = with pkgs; [
    # cli utils
    git
    curl
    wget
    kitty
  ];

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
  };
  system.stateVersion = "25.05";
}