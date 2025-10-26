{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.system;
in
{
  options.system = {
    enable = mkEnableOption "system configuration";

    enableBoot = mkOption {
      type = types.bool;
      default = true;
      description = "Enable boot configuration";
    };

    enableLocale = mkOption {
      type = types.bool;
      default = true;
      description = "Enable locale configuration";
    };

    enableAutoUpgrade = mkOption {
      type = types.bool;
      default = false;
      description = "Enable automatic system upgrades";
    };

    autoUpgradeDates = mkOption {
      type = types.str;
      default = "weekly";
      description = "Cron schedule for auto-upgrade";
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
    # Enable sub-modules
    system.boot.enable = cfg.enableBoot;
    system.locale.enable = cfg.enableLocale;

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
