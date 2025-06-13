{ lib, config, inputs, ... }:
let
  cfg = config.my.nixos.home-manager;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  options.my.nixos.home-manager.enable = lib.mkEnableOption "home-manager";

  config = lib.mkIf cfg.enable {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      extraSpecialArgs = { inherit inputs; };
    };
    nixpkgs.overlays = [
      inputs.nur.overlay
    ];
  };
}