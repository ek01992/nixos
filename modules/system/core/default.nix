# Core System Configuration Module
# Verification: nixos-version
#               nix flake show
#               cat /etc/nix/nix.conf
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.mySystem.core;
  inherit (lib) mkEnableOption mkOption mkIf types;
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
    nix.settings.experimental-features = lib.mkDefault ["nix-command" "flakes"];
    nixpkgs.config.allowUnfree = lib.mkDefault true;

    # Hardware configuration
    hardware.enableRedistributableFirmware = lib.mkDefault cfg.enableFirmware;
  };
}
