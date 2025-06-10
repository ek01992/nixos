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

  # ssh
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no"; # do not allow to login as root user
    };
  };

  # installed packages
  environment.systemPackages = with pkgs; [
    # cli utils
    git
    curl
    wget
  ];

  system.stateVersion = "25.05";
}