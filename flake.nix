{
  description = "NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    alejandra.url = "github:kamadorueda/alejandra/4.0.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixos-hardware, alejandra, ... }@inputs:
    let
      mkSystem = hostname: system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/${hostname}/default.nix
          ];
        };

      mkFormatter = system: alejandra.defaultPackage.${system};
    in {
      formatter.x86_64-linux = mkFormatter "x86_64-linux";
      nixosConfigurations = {
        xps = mkSystem "xps" "x86_64-linux";
      };
    };
}
