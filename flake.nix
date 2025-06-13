{
  description = "flake for nixos with Home Manager enabled";

  outputs = { self, nixpkgs, home-manager, nixos-hardware, zen-browser, stylix, ... }@inputs: 
  let
    lib = import ./lib { inherit inputs; };
  in {

    nixosModules.default = import ./modules/nixos;
    homeManagerModules.default = import ./modules/home-manager;

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
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #sops-nix = {
    #  url = "github:Mic92/sops-nix";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
  };
}