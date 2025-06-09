{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader = {
    grub.enable = false;
    systemd-boot.enable = true;
    efi = {
      canTouchEfiVariables = true;
    };
  };

  networking = {
    networkmanager.enable = true;
    hostName = "nixos"; # edit this to your liking
  };

  # QEMU-specific
  # services.spice-vdagentd.enable = true;
  # services.qemuGuest.enable = true;

  # locales
  # https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  # graphics
  # services.xserver = {
  #   enable = true;
  #   resolutions = [{ x = 1920; y = 1200; }];
  #   virtualScreen = { x = 1920; y = 1200; };
  #   layout = "us"; # keyboard layout
  #   desktopManager = {
  #     xterm.enable = false;
  #     xfce.enable = true;
  #   };
  #   displayManager.defaultSession = "xfce";
  #   autorun = true; # run on graphic interface startup
  #   libinput.enable = true; # touchpad support
  # };

  # audio
  # sound.enable = true;
  # nixpkgs.config.pulseaudio = true;
  # hardware.pulseaudio.enable = true;

  # user configuration
  users.users = {
    erik = { # change this to you liking
      createHome = true;
      initialPassword = "temp";
      isNormalUser = true; # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/config/users-groups.nix#L100
      extraGroups = [
        "wheel" "audio" "video" "networkmanager"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPakom6FvoSpBc0nmunHQUZwQI9VtS52i4W4WLuiUMpc ek01992@proton.me"
      ];
    };
    root = {
      extraGroups = [
        "wheel"
      ];
    };
  };

  # ssh
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no"; # do not allow to login as root user
    };
  };

  nixpkgs.config.allowUnfree = true;

  # installed packages
  environment.systemPackages = with pkgs; [
    # cli utils
    git
    curl
    wget
    helix
    htop

    # browser
    chromium
  ];
  
  programs.chromium = {
    enable = true;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
    ];
  };

  system.stateVersion = "25.05";
}