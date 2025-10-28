# Core configuration required on ALL hosts
# This module must work unchanged on every host in your infrastructure
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./nix-settings.nix
    ./networking.nix
    ./users.nix
    ./packages.nix
  ];

  # Boot configuration - works for all modern UEFI systems
  boot.loader = {
    systemd-boot.enable = lib.mkDefault true;
    efi.canTouchEfiVariables = lib.mkDefault true;
    systemd-boot.configurationLimit = lib.mkDefault 16;
  };

  # Security baseline
  security.sudo.wheelNeedsPassword = lib.mkDefault false;

  # SSH hardening - required on all infrastructure hosts
  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      PasswordAuthentication = lib.mkDefault false;
      PermitRootLogin = lib.mkDefault "no";
      KbdInteractiveAuthentication = lib.mkDefault false;
    };
  };

  # Firewall enabled by default
  networking.firewall.enable = lib.mkDefault true;

  # Time zone - override per host as needed
  time.timeZone = lib.mkDefault "UTC";

  # NixOS release compatibility
  system.stateVersion = lib.mkDefault "25.11";
}
