{ config, pkgs, inputs, lib, ... }: 
{
  imports =
    [
      ../../users/erik
      ../../modules/home-manager
      ../../modules/nixos
    ];

  home-manager.users.erik = import ../../users/erik/home.nix;
}