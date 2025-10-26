{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.system;
in
{
  options.system = {
    enable = mkEnableOption "system configuration";

    timezone = mkOption {
      type = types.str;
      default = "America/Chicago";
      description = "System timezone";
    };

    locale = mkOption {
      type = types.str;
      default = "en_US.UTF-8";
      description = "System locale";
    };

    keyMap = mkOption {
      type = types.str;
      default = "us";
      description = "Console keymap";
    };

    enableAutoUpgrade = mkOption {
      type = types.bool;
      default = true;
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

    enableZfs = mkOption {
      type = types.bool;
      default = true;
      description = "Enable ZFS filesystem support";
    };

    enableKvm = mkOption {
      type = types.bool;
      default = true;
      description = "Enable KVM virtualization support";
    };

    enableFirmware = mkOption {
      type = types.bool;
      default = true;
      description = "Enable redistributable firmware";
    };
  };

  config = mkIf cfg.enable {
    # Boot configuration
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    
    boot.supportedFilesystems = mkIf cfg.enableZfs [ "zfs" ];
    
    boot.extraModprobeConfig = mkIf cfg.enableKvm ''
      options kvm ignore_msrs=1 report_ignored_msrs=0
    '';

    # System settings
    time.timeZone = cfg.timezone;
    console.keyMap = cfg.keyMap;
    i18n.defaultLocale = cfg.locale;
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
