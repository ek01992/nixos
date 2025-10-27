# Modules
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption;
in {
  options.myModules = {
    enable = mkEnableOption "modules";
  };

  imports = [
    ./system
    ./networking
    ./services
    ./virtualization
    ./users
    ./security
  ];
}
