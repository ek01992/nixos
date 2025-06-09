{
  description = "flake for nixos with Home Manager enabled";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  }@inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };   
  in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs system;
        };
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.erik = { pkgs, ... }: {
                home = {
                  username = "erik";
                  homeDirectory = "/home/erik";
                  packages = with pkgs; [
                    hello
                  ];
                  stateVersion = "25.05";
                  sessionVariables = { EDITOR = "hx"; };
                };
                programs = {
                  home-manager.enable = true;
                  git = {
                    enable = true;
                    userName = "ek01992";
                    userEmail = "ek01992@proton.me";
                  };
                  chromium = {
                    enable = true;
                    extensions = [
                      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
                    ];
                  };
                };
              };
            };
          }
        ];
      };
    };
  };
}