# modules/nixos/home-manager/default.nix
{ lib, config, inputs, ... }:
let
  cfg = config.nixos.home-manager;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  options.nixos.home-manager.enable = lib.mkEnableOption "home-manager";

  config = lib.mkIf cfg.enable {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      extraSpecialArgs = { inherit inputs; };
    };
    nixpkgs.overlays = [
      inputs.nur.overlays.default
    ];
  };
}