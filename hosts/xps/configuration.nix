{ config, pkgs, inputs, lib, ... }:
let
  users = [ "erik" ];
in
{
  imports = [
    ./hardware-configuration.nix
    inputs.self.nixosModules.default
  ];

  my.nixos = {
    core.enable = true;
    home-manager.enable = true;
    ssh.enable = true;
    hyprland.enable = true;
    zsh.enable = true;
    greetd.enable = true;
  };

  home-manager.extraSpecialArgs = { inherit inputs; };

  home-manager.users = lib.genAttrs users (username: {
    imports = [ ../../users/${username}/home.nix ];
  });

  users.users = lib.genAttrs users (username: {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  });
}