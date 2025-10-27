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
  cfg = config.myVirtualization;
  inherit (lib) mkEnableOption;
in {
  options.myVirtualization = {
    enable = mkEnableOption "virtualization configuration";
  };

  imports = [
    ./kvmgt.nix
    ./incus.nix
  ];
}
