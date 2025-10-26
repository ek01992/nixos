{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services;
in
{
  options.services = {
    enable = mkEnableOption "services configuration";

    enableZfs = mkOption {
      type = types.bool;
      default = true;
      description = "Enable ZFS services";
    };

    enableSsh = mkOption {
      type = types.bool;
      default = true;
      description = "Enable SSH daemon";
    };

    enableFirmware = mkOption {
      type = types.bool;
      default = true;
      description = "Enable firmware update service";
    };
  };

  config = mkIf cfg.enable {
    # Import service modules
    imports = [
      (mkIf cfg.enableZfs ./zfs.nix)
      (mkIf cfg.enableSsh ./ssh.nix)
    ];

    # Firmware update service
    services.fwupd.enable = cfg.enableFirmware;
  };
}
