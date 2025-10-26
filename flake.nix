{
  description = "Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = { self, nixpkgs, nixos-hardware, ... }@inputs: {

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        ./hosts/xps/configuration.nix
        nixos-hardware.nixosModules.dell-xps-13-9315
      ];
    };
  };
}
