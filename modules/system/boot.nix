# Boot Configuration Module
# Verification: bootctl status
#               ls /boot/loader/entries/
#               cat /proc/cmdline
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.mySystem.boot;
  inherit (lib) mkEnableOption mkOption mkIf types;
in {
  options.mySystem.boot = {
    enable = mkEnableOption "boot configuration";

    enableSystemdBoot = mkOption {
      type = types.bool;
      default = true;
      description = "Enable systemd-boot";
    };

    enableEfiVariables = mkOption {
      type = types.bool;
      default = true;
      description = "Enable EFI variables access";
    };

    enableZfsSupport = mkOption {
      type = types.bool;
      default = true;
      description = "Enable ZFS filesystem support";
    };

    enableKvmOptions = mkOption {
      type = types.bool;
      default = true;
      description = "Enable KVM kernel options";
    };
  };

  config = mkIf cfg.enable {
    boot.loader.systemd-boot.enable = cfg.enableSystemdBoot;
    boot.loader.efi.canTouchEfiVariables = cfg.enableEfiVariables;

    boot.supportedFilesystems = lib.mkIf cfg.enableZfsSupport (lib.mkDefault ["zfs"]);

    boot.extraModprobeConfig = mkIf cfg.enableKvmOptions ''
      options kvm ignore_msrs=1 report_ignored_msrs=0
    '';
  };
}
