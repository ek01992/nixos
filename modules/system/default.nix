# System Configuration Module
# Verification: nixos-version
#               systemctl status nixos-upgrade.timer
#               nix flake show
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.mySystem;
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

  config = mkIf cfg.enable {
    # NO LOGIC HERE - category modules are pure containers
    # All configuration logic lives in submodules
  };
}
