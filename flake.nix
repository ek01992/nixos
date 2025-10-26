{
  description = "NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = { self, nixpkgs, nixos-hardware, ... }@inputs:
    let
      mkSystem = hostname: system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/${hostname}/default.nix
          ];
        };
    in {
      modules = {
        system = ./modules/system;
        networking = ./modules/networking;
        services = ./modules/services;
        virtualisation = ./modules/virtualization;
        users = ./modules/users;
      };

      profiles = {
        server = ./profiles/server;
      };

      nixosConfigurations = {
        nixos = mkSystem "xps" "x86_64-linux";
      };
    };
}
