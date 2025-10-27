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
  options.myVirtualization = {
    enable = mkEnableOption "virtualization configuration";
  };

  imports = [
    ./kvmgt
    ./incus
  ];
}
