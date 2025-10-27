# System Configuration Module
# Verification: nixos-version
#               systemctl status nixos-upgrade.timer
#               nix flake show
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.mySystem;
  inherit (lib) mkEnableOption;
in {
  options.mySystem = {
    enable = mkEnableOption "system configuration";
  };

  imports = [
    ./boot.nix
    ./locale.nix
    ./core.nix
    ./upgrade.nix
  ];
}
