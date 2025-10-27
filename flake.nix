{
  description = "NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    alejandra = {
      url = "github:kamadorueda/alejandra/4.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
    alejandra,
    agenix,
    ...
  } @ inputs: let
    mkSystem = hostname: system:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/${hostname}
        ];
      };

    mkFormatter = system: alejandra.defaultPackage.${system};

    # Import lib helpers for use in modules
    lib = import ./lib {lib = nixpkgs.lib;};
  in {
    formatter.x86_64-linux = mkFormatter "x86_64-linux";
    nixosConfigurations = {
      xps = mkSystem "xps" "x86_64-linux";
    };
    # Expose lib helpers for external use
    lib = lib;
  };
}
