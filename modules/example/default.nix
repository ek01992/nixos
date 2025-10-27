# Example Modules
# Demonstrates various patterns and helper function usage
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myExamples;
  inherit (lib) mkEnableOption mkIf;
in {
  options.myExamples = {
    enable = mkEnableOption "example modules for demonstration";
  };

  imports = [
    ./helper-demo
  ];
}
