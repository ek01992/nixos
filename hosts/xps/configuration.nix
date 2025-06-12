{ config, pkgs, inputs, lib, username, ... }:
{
  imports = [
    ./hardware-configuration.nix
    (import (../../users + "/${username}/default.nix") { inherit username; })
    inputs.self.nixosModules.default
  ];

  modules.nixos.core.enable = true;
  modules.nixos.home-manager.enable = true;
  modules.nixos.ssh.enable = true;
  modules.nixos.hyprland.enable = true;

  home-manager.users."${username}" = ../../users/${username}/home.nix;
}