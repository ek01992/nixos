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
      ../../users/erik/user.nix
      inputs.home-manager.nixosModules.home-manager
      inputs.hyprland.nixosModules.default
      ../../modules/home-manager.nix
    ];
  nixpkgs.config.allowUnfree = true;
  networking = {
    networkmanager.enable = true;
    hostName = "xps"; # edit this to your liking
  };
  # nix
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # locales
  # https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  # audio
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # ssh
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no"; # do not allow to login as root user
    };
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true; # Use the wayland greeter for SDDM
  };

  # installed packages
  environment.systemPackages = with pkgs; [
    # cli utils
    git
    curl
    wget
    kitty
    (waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];}))
    mako
    libnotify
    swww
    rofi-wayland
  ];

  xdg.portal = {
    enable = true;
    # The build error "Failed assertions: - Setting xdg.portal.enable to true requires a
    # portal implementation..." means we must explicitly list the portal backends we want to use.
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    # This configures the preference order for portals.
    config = {
      common.default = ["hyprland" "gtk"];
    };
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };
  system.stateVersion = "25.05";
}