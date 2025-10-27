# Security Configuration Module
# Verification: systemctl status fwupd sshd zfs-*
#               incus list
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.mySecurity;
  inherit (lib) mkEnableOption;
in {
  options.mySecurity = {
    enable = mkEnableOption "security configuration";
  };

  imports = [
    ./secrets.nix
  ];
}
