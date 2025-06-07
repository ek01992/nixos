{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.impermanence.nixosModules.impermanence
    inputs.home-manager.nixosModules.home-manager
  ];

  # Global settings
  networking.hostName = "xps";
  system.stateVersion = "25.11";
  nixpkgs.config.allowUnfree = true;
  hardware.enableRedistributableFirmware = true;

  # Bootloader and ephemeral root settings from the old hardware config
  boot.initrd.postDeviceCommands = let
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
  in lib.mkBefore wipeScript;

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
    registry = lib.mapAttrs (_: flake: { inherit flake; }) (lib.filterAttrs (_: lib.isType "flake") inputs);
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") (lib.filterAttrs (_: lib.isType "flake") inputs);
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
      users.erik = {
        home = "/home/erik";
      };
    };
  };
  programs.fuse.userAllowOther = true;
  system.activationScripts.persistent-dirs.text = let
    mkHomePersist = user:
      lib.optionalString user.createHome ''
        mkdir -p /persist/home/erik
        chown erik:erik /persist/home/erik
        chmod 755 /persist/home/erik
      '';
    users = lib.attrValues config.users.users;
  in lib.concatLines (map mkHomePersist users);

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
        inputs.impermanence.nixosModules.home-manager.impermanence
      ];

      home = {
        username = "erik";
        homeDirectory = "/home/erik";
        stateVersion = "25.11";
        sessionPath = [ "/home/erik/.local/bin" ];
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