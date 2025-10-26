{
  description = "Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs: {

    nixosConfigurations.nixops = nixpkgs.lib.nixosSystem {
      modules = [
        ./hosts/xps/configuration.nix
      ];
    };
  };
}
