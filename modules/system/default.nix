# System Configuration Module
# Verification: nixos-version
#               systemctl status nixos-upgrade.timer
#               nix flake show
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.mySystem;
in
{
  options.mySystem = {
    enable = mkEnableOption "system configuration";

    enableAutoUpgrade = mkOption {
      type = types.bool;
      default = false;
      description = "Enable automatic system upgrades";
    };

    autoUpgradeDates = mkOption {
      type = types.str;
      default = "weekly";
      description = "Cron schedule for auto-upgrade";
      example = "daily at 02:00";
    };

    allowReboot = mkOption {
      type = types.bool;
      default = true;
      description = "Allow automatic reboots after upgrade";
    };

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

  imports = [
    ./boot.nix
    ./locale.nix
  ];

  config = mkIf cfg.enable {
    # System settings
    system.stateVersion = cfg.stateVersion;

    # Auto-upgrade configuration
    system.autoUpgrade = mkIf cfg.enableAutoUpgrade {
      enable = true;
      dates = cfg.autoUpgradeDates;
      allowReboot = cfg.allowReboot;
    };

    # Nix configuration
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nixpkgs.config.allowUnfree = true;

    # Hardware configuration
    hardware.enableRedistributableFirmware = cfg.enableFirmware;
  };
}
