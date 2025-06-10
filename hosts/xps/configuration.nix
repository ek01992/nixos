{ config, pkgs, inputs, lib, ... }: 
{
  imports =
    [
      inputs.home-manager.nixosModules.home-manager
      ./hardware-configuration.nix
      ../../users/erik
      ../../modules/home-manager
    ];

  nixpkgs.config.allowUnfree = true;
  
  networking = {
    networkmanager.enable = true;
    hostName = "xps";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
  ];

  system.stateVersion = "25.05";
}