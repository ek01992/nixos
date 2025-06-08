{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  phase1Systemd = config.boot.initrd.systemd.enable;
  wipeScript = ''
    mkdir /tmp -p
    MNTPOINT=$(mktemp -d)
    (
      mount -t btrfs -o subvol=/ /dev/disk/by-label/xps "$MNTPOINT"
      trap 'umount "$MNTPOINT"' EXIT

      echo "Creating needed directories"
      mkdir -p "$MNTPOINT"/persist/var/{log,lib/{nixos,systemd}}

      echo "Cleaning root subvolume"
      btrfs subvolume list -o "$MNTPOINT/@" | cut -f9 -d ' ' | sort |
      while read -r subvolume; do
        btrfs subvolume delete "$MNTPOINT/$subvolume"
      done && btrfs subvolume delete "$MNTPOINT/@"

      echo "Restoring blank subvolume"
      btrfs subvolume snapshot "$MNTPOINT/@blank" "$MNTPOINT/@"
    )
  '';
in {
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    inputs.impermanence.nixosModules.impermanence
    inputs.home-manager.nixosModules.home-manager
  ];

  # Global settings
  networking.hostName = "xps";
  system.stateVersion = "25.11";
  nixpkgs.config.allowUnfree = true;
  hardware.enableRedistributableFirmware = true;

  # Bootloader and ephemeral root settings from the old hardware config
  boot.initrd = {
    supportedFilesystems = ["btrfs"];
    postDeviceCommands = lib.mkIf (!phase1Systemd) (lib.mkBefore wipeScript);
    systemd.services.restore-root = lib.mkIf phase1Systemd {
      description = "Rollback btrfs rootfs";
      wantedBy = ["initrd.target"];
      requires = [
        "dev-disk-by\\x2dlabel-xps.device"
      ];
      after = [
        "dev-disk-by\\x2dlabel-xps.device"
        "systemd-cryptsetup@xps.service"
      ];
      before = ["sysroot.mount"];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = wipeScript;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/xps";
      fsType = "btrfs";
      options = ["subvol=@" "compress=zstd"];
    };

    "/nix" = {
      device = "/dev/disk/by-label/xps";
      fsType = "btrfs";
      options = ["subvol=@nix" "noatime" "compress=zstd"];
    };

    "/persist" = {
      device = "/dev/disk/by-label/xps";
      fsType = "btrfs";
      options = ["subvol=@persist" "compress=zstd"];
      neededForBoot = true;
    };

    "/swap" = {
      device = "/dev/disk/by-label/xps";
      fsType = "btrfs";
      options = ["subvol=@swap" "noatime"];
    };
  };

  # Environment settings
  environment = {
    defaultPackages = lib.mkForce [];
    systemPackages = with pkgs; [
      btrfs-progs
      coreutils
      ffmpeg
      file
      git
      jq
      lm_sensors
      logrotate
      p7zip
      rar
      tree
      unrar
      unzip
      zip
    ];
  };

  # Locale settings
  time.timeZone = "America/Chicago";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" ];
    extraLocaleSettings = { LC_MONETARY = "en_US.UTF-8"; };
  };
  console.keyMap = "us";

  # Nix settings
  nix = {
    settings = {
      trusted-users = [ "root" "@wheel" ];
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than +3";
    };
    registry = lib.mapAttrs' (name: value: {
      inherit name;
      value = { flake = value; };
    }) (lib.filterAttrs (key: value: value ? "url" || value ? "path") inputs);
  };

  # Persistence settings
  environment.persistence = {
    "/persist" = {
      files = [ "/etc/machine-id" ];
      directories = [
        "/var/lib/systemd"
        "/var/lib/nixos"
        "/etc/nixos"
        "/var/log"
        "/srv"
      ];
    };
  };
  programs.fuse.userAllowOther = true;
  systemd.tmpfiles.rules = [
    "d /persist/home/erik 0755 erik erik -"
  ];

  # Sudo settings
  security.sudo = {
    execWheelOnly = true;
    wheelNeedsPassword = false;
  };

  # SSH settings
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  # User settings
  users.mutableUsers = false;
  users.groups.erik.gid = 1000;
  users.users.erik = {
    uid = 1000;
    isNormalUser = true;
    home = "/home/erik";
    createHome = true;
    shell = pkgs.bash;
    group = "erik";
    extraGroups = [ "wheel" "users" "audio" "video" "networkmanager" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPakom6FvoSpBc0nmunHQUZwQI9VtS52i4W4WLuiUMpc ek01992@proton.me"
    ];
    initialPassword = "temp";
    packages = with pkgs; [ home-manager ];
  };

  # Home Manager settings
  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs; };
    users.erik = {
      imports = [
        inputs.impermanence.homeManagerModules.impermanence
      ];

      home = {
        username = "erik";
        homeDirectory = "/home/erik";
        stateVersion = "25.11";
        sessionPath = ["$HOME/.local/bin"];
        sessionVariables = {NH_FLAKE = "$HOME/workspace/nixos";};
      };

      home.persistence."/persist/home/erik" = {
        allowOther = true;
        directories = [
          "desktop"
          "documents"
          "downloads"
          "music"
          "pictures"
          "public"
          "videos"
          "workspace"
          ".local/bin"
          ".local/share/nix"
          ".ssh"
        ];
      };

      systemd.user.startServices = "sd-switch";

      programs = {
        home-manager.enable = true;
      };

      programs.bash = {
        enable = true;
      };

      programs.git = {
        enable = true;
        userName = "Erik Kowald";
        userEmail = "ek01992@proton.me";
      };
    };
  };
} 