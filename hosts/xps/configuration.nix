{ config, pkgs, inputs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.self.nixosModules.default
    ../../users/erik/default.nix
  ];

  modules.nixos.core.enable = true;
  modules.nixos.home-manager.enable = true;
  modules.nixos.ssh.enable = true;

  home-manager.users.erik = import ../../users/erik/home.nix;
}