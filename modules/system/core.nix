# Core System Configuration Module
# Verification: nixos-version
#               nix flake show
#               cat /etc/nix/nix.conf
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.mySystem.core;
in {
  options.mySystem.core = {
    enable = mkEnableOption "core system configuration";

    stateVersion = mkOption {
      type = types.str;
      default = "25.11";
      description = "NixOS state version";
      example = "24.11";
    };

    enableFirmware = mkOption {
      type = types.bool;
      default = true;
      description = "Enable redistributable firmware";
    };
  };

  config = mkIf cfg.enable {
    # System settings
    system.stateVersion = cfg.stateVersion;

    # Nix configuration
    nix.settings.experimental-features = ["nix-command" "flakes"];
    nixpkgs.config.allowUnfree = true;

    # Hardware configuration
    hardware.enableRedistributableFirmware = cfg.enableFirmware;
  };
}
