{
  description = "flake for nixos with Home Manager enabled";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, ... }@inputs: 
  let
    lib = import ./lib { inherit inputs; };
  in {

    nixosModules.default = import ./modules/nixos;
    homeManagerModules.default = import ./modules/home-manager;

    nixosConfigurations = {
      xps = lib.nixosSystem {
        system = "x86_64-linux";
        hostName = "xps";
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./hosts/xps/configuration.nix
        ];
      };
    };
  };
}