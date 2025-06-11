{ lib, config, inputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  options.modules.nixos.home-manager.enable = lib.mkEnableOption "home-manager";

  config = lib.mkIf config.modules.nixos.home-manager.enable {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      extraSpecialArgs = { inherit inputs; };
    };
  };
}