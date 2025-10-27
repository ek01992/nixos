# Services Configuration Module
# Verification: systemctl status fwupd sshd zfs-*
#               incus list
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myServices;
  inherit (lib) mkEnableOption;
in {
  options.myServices = {
    enable = mkEnableOption "services configuration";
  };

  imports = [
    ./fwupd
    ./zfs
    ./ssh
  ];
}
