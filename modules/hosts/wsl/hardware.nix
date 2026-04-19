{ self, inputs, ... }: {

  flake.nixosModules.nixxyHardware = { config, lib, pkgs, modulesPath, ... }: {
    imports = [];

    boot = {
      initrd = {
        availableKernelModules = [];
        kernelModules = [];
      };
      kernelModules = [ "kvm-intel" ];
      extraModulePackages = [];
    };

    fileSystems."/lib/modules/6.6.87.2-microsoft-standard-WSL2" =
      { device = "none";
        fsType = "overlay";
      };

    fileSystems."/mnt/wsl" =
      { device = "none";
        fsType = "tmpfs";
      };

    fileSystems."/usr/lib/wsl/drivers" =
      { device = "drivers";
        fsType = "9p";
      };

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/662019ff-5cc2-4a40-a7cf-a3f395f242b4";
        fsType = "ext4";
      };

    fileSystems."/mnt/wslg" =
      { device = "none";
        fsType = "tmpfs";
      };

    fileSystems."/mnt/wslg/distro" =
      { device = "";
        fsType = "none";
        options = [ "bind" ];
      };

    fileSystems."/usr/lib/wsl/lib" =
      { device = "none";
        fsType = "overlay";
      };

    fileSystems."/tmp/.X11-unix" =
      { device = "/mnt/wslg/.X11-unix";
        fsType = "none";
        options = [ "bind" ];
      };

    fileSystems."/mnt/wslg/doc" =
      { device = "none";
        fsType = "overlay";
      };

    fileSystems."/mnt/c" =
      { device = "C:\134";
        fsType = "9p";
      };

    fileSystems."/mnt/d" =
      { device = "D:\134";
        fsType = "9p";
      };

    fileSystems."/mnt/e" =
      { device = "E:\134";
        fsType = "9p";
      };

    fileSystems."/mnt/wslg/run/user/1000" =
      { device = "tmpfs";
        fsType = "tmpfs";
      };

    swapDevices =
        [ { device = "/dev/disk/by-uuid/fd82a5ac-a68d-4ecb-b50d-ddcc66a96bde"; }
        ];
  };
}
