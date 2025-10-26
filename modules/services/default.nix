{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myServices;
in
{
  options.myServices = {
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

  imports = [
    ./zfs.nix
    ./ssh.nix
  ];

  config = mkIf cfg.enable {
    # Firmware update service
    services.fwupd.enable = cfg.enableFirmware;
  };
}
