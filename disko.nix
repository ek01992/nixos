{ pkgs, ... }:

let
  # IMPORTANT: Change this to the actual device path for your main drive.
  # You can find it by running `ls -l /dev/disk/by-id/`.
  # Pick the one that corresponds to your main NVMe or SSD.
  mainDisk = "/dev/disk/by-id/nvme-ESE2A047-M24_NVMe_Phison_1024GB_9AB4072506F500088240";
in
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = mainDisk;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "defaults" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                label = "xps"; # Set the btrfs filesystem label

                # Create the main subvolumes
                subvolumes = {
                  "/@" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" ];
                  };
                  "/@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "/@persist" = {
                    mountpoint = "/persist";
                    mountOptions = [ "compress=zstd" ];
                  };
                  "/@swap" = {
                    mountpoint = "/swap";
                    mountOptions = [ "noatime" ];
                  };

                  # This is the blank snapshot for your ephemeral root setup
                  "/@blank" = { };
                };
              };
            };
          };
        };
      };
    };
    # Define the swap file within the @swap subvolume
    swap = {
      swapfile = {
        type = "swap";
        file = "/swap/swapfile";
        size = "8G";
      };
    };
  };
}