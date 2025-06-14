{
  description = "flake for nixos with Home Manager enabled";

  outputs = { self, nixpkgs, home-manager, nixos-hardware, stylix, nur, ... }@inputs: 
  let
    lib = import ./lib { inherit inputs; };
  in {

    nixosModules.default = import ./modules/nixos;
    homeModules.default = import ./modules/home-manager;

    nixosConfigurations = {
      xps = lib.nixosSystem {
        system = "x86_64-linux";
        hostName = "xps";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/xps/configuration.nix
        ];
      };
    };
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    hyprland.url = "github:hyprwm/Hyprland";
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #sops-nix = {
    #  url = "github:Mic92/sops-nix";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}