{ config, pkgs, inputs, lib, username, ... }:
{
  imports = [
    # Static host and user imports
    ./hardware-configuration.nix
    (import (../../users + "/${username}/default.nix") { inherit username; })
    ../../modules/desktops/wm/wayland/hyprland.nix

    # Shared module imports
    inputs.self.nixosModules.default
  ];

  # Enable the modules for this host
  modules.nixos.core.enable = true;
  modules.nixos.home-manager.enable = true;
  modules.nixos.ssh.enable = true;
  modules.desktops.wm.wayland.hyprland.enable = true;

  # Assign the user's home-manager config
  home-manager.users."${username}" = ../../users/${username}/home.nix;
}