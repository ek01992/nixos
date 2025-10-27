# Virtualization Configuration Module
# Verification: systemctl status incus
#               ls /sys/devices/pci*/mdev_supported_types
#               incus list
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myVirtualization;
in {
  options.myVirtualization = {
    enable = mkEnableOption "virtualization configuration";
  };

  imports = [
    ./kvmgt.nix
    ./incus.nix
  ];

  config =
    mkIf cfg.enable {
  };
}
