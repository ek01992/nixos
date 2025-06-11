{ lib, config, inputs, ... }:
{
  options.modules.nixos.home-manager.enable = lib.mkEnableOption "home-manager";

  config = lib.mkIf config.modules.nixos.home-manager.enable {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      extraSpecialArgs = { inherit inputs; };
    };
  };
}