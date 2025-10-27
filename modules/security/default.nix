# Security Configuration Module
# Verification: systemctl status fwupd sshd zfs-*
#               incus list
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.mySecurity;
in {
  options.mySecurity = {
    enable = mkEnableOption "security configuration";
  };

  imports = [
    ./secrets.nix
  ];
}
