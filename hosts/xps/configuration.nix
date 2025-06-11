{ config, pkgs, inputs, lib, username, ... }:
lib.mkMerge [
  ((import (../../users + "/${username}/default.nix")) { inherit username; })
  {
    imports = [
      ./hardware-configuration.nix
      inputs.self.nixosModules.default
    ];

    modules.nixos.core.enable = true;
    modules.nixos.home-manager.enable = true;
    modules.nixos.ssh.enable = true;

    home-manager.users."${username}" = ../../users/${username}/home.nix;
  }
]