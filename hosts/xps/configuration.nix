{ config, pkgs, inputs, lib, ... }: 
{
  imports =
    [
      ./hardware-configuration.nix
      ../../users/erik
      ../../modules/home-manager
      ../../modules/nixos/desktop.nix
      ../../modules/nixos/base.nix
    ];

  home-manager.users.erik = import ../../users/erik/home.nix;

  networkmanager.enable = true;
}