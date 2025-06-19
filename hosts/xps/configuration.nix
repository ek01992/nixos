# hosts/xps/configuration.nix
{ config, pkgs, inputs, lib, ... }:
let
  users = [ "erik" ];
in
{
  imports = [
    ./hardware-configuration.nix
    inputs.self.nixosModules.default
  ]
  ++ (map (username: ../../users + "/${username}/default.nix") users);

  nixos = {
    core.enable = true;
    home-manager.enable = true;
    ssh.enable = true;
    hyprland.enable = true;
    zsh.enable = true;
    greetd = {
      enable = true;
      user = "erik";
    };
    obsidian.enable = true;
    nixvim.enable = true;
    power-management.enable = true;
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = lib.genAttrs users (username: {
      imports = [ ../../users/${username}/home.nix ];
    });
  };

   fonts.packages = with pkgs; [                                                                          
    noto-fonts                                                                                           
    noto-fonts-cjk                                                                                       
    noto-fonts-emoji                                                                                     
    liberation_ttf
    nerdfonts
    roboto-mono
    font-awesome
  ]

  users = {
    users = lib.genAttrs users (username: {
      isNormalUser = true;
      createHome = true;
    });
  };
}