# Services Configuration Module
# Verification: systemctl status fwupd sshd zfs-*
#               incus list
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myServices;
in {
  options.myServices = {
    enable = mkEnableOption "services configuration";
  };

  imports = [
    ./firmware.nix
    ./zfs.nix
    ./ssh.nix
  ];
}
