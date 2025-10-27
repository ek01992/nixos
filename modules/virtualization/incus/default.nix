# Virtualization Configuration Module
# Verification: systemctl status incus
#               ls /sys/devices/pci*/mdev_supported_types
#               incus list
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption;
in {
  options.myVirtualization.incus = {
    enable = mkEnableOption "Incus container and VM management";
  };

  imports = [
    ./core
    ./preseed
  ];
}
