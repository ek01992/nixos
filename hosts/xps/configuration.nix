{ config, pkgs, inputs, lib, ... }: 
{
  imports =
    [
      ./hardware-configuration.nix
      ../../users/erik
      ../../modules/home-manager
      ../../modules/nixos
    ];

  home-manager.users.erik = import ../../users/erik/home.nix;
}