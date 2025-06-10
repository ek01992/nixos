{ config, pkgs, inputs, lib, ... }: 
{
  imports =
    [
      inputs.home-manager.nixosModules.home-manager
      ./hardware-configuration.nix
      ../../users/erik
      ../../modules
    ];
  
  networking = {
    networkmanager.enable = true;
    hostName = "xps";
  };
}