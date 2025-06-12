{ config, pkgs, inputs, lib, username, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../users/${username}/default.nix
    inputs.self.nixosModules.default
  ];

  modules.nixos.core.enable = true;
  modules.nixos.home-manager.enable = true;
  modules.nixos.ssh.enable = true;
  modules.nixos.hyprland.enable = true;
  modules.nixos.zsh.enable = true;

  home-manager.users."${username}" = ../../users/${username}/home.nix;
}