{
  description = "NixOS Infrastructure Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra = {
      url = "github:kamadorueda/alejandra/4.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
    sops-nix,
    alejandra,
    ...
  }: {
    # Formatter
    formatter.x86_64-linux = alejandra.defaultPackage.x86_64-linux;

    # NixOS configurations - explicit for single host
    nixosConfigurations = {
      xps = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit self;};
        modules = [
          # Core configuration - required on all hosts
          ./hosts/common/core
          # Host-specific configuration
          ./hosts/xps
          # Hardware support
          nixos-hardware.nixosModules.dell-xps-13-9315
          # Secrets management
          sops-nix.nixosModules.sops
        ];
      };
    };

    # Expose common modules for external use
    nixosModules.default = ./hosts/common/core;
  };
}
