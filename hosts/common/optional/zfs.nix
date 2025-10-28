# ZFS filesystem services
# Enable in host config with: imports = [ ../common/optional/zfs.nix ];
# Verification: zpool status, systemctl status zfs-scrub@*

{
  config,
  lib,
  pkgs,
  ...
}: {

  # ZFS support in boot
  boot.supportedFilesystems = ["zfs"];

  # ZFS kernel module options for KVM compatibility
  boot.extraModprobeConfig = ''
    options kvm ignore_msrs=1 report_ignored_msrs=0
  '';

  # ZFS services
  services.zfs = {
    # Weekly scrubbing prevents silent data corruption
    autoScrub = {
      enable = true;
      interval = "weekly";
    };
    # TRIM support for SSDs
    trim = {
      enable = true;
      interval = "weekly";
    };
  };

}
