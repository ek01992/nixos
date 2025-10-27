# Intel GVT-g GPU Virtualization Module
# Verification: ls /sys/devices/pci*/mdev_supported_types
#               dmesg | grep -i "gvt\|mdev"
#               ls /sys/bus/mdev/devices/
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myVirtualization.kvmgt;
  inherit (lib) mkEnableOption mkIf;
in {
  options.myVirtualization.kvmgt = {
    enable = mkEnableOption "Intel GVT-g GPU virtualization";
  };

  config = mkIf cfg.enable {
    virtualisation.kvmgt.enable = true;
  };
}
