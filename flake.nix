{
  description = "NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = { self, nixpkgs, nixos-hardware, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
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

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/xps/default.nix
          nixos-hardware.nixosModules.dell-xps-13-9315
        ];
      };
    };
}
