{ config, pkgs, inputs, lib, ... }:
let
  # Define the users for this specific host
  users = [ "erik" ];
in
{
  imports = [
    ./hardware-configuration.nix
    inputs.self.nixosModules.default
  ];

  # This assumes you refactor your nixos modules to a 'my.nixos' namespace for consistency.
  my.nixos = {
    core.enable = true;
    home-manager.enable = true;
    ssh.enable = true;
    hyprland.enable = true;
    zsh.enable = true;
    greetd.enable = true;
  };

  # Set up home-manager for each user defined above
  home-manager.users = lib.genAttrs users (username: {
    imports = [ ../../users/${username}/home.nix ];
    pkgs = pkgs; # Use the host's pkgs for home-manager
  });

  # Also define the system-level users
  users.users = lib.genAttrs users (username: {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # For sudo access
    # You might want to set a shell for the user here
    shell = pkgs.zsh;
  });
}