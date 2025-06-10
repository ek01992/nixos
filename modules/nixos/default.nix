{ pkgs, ... }:
{
  imports = [
    ./hyprland.nix
    ./fonts.nix
  ];

  # Basic system settings
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
  nixpkgs.config.allowUnfree = true;

  # Nix settings for flakes and Cachix
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = ["https://hyprland.cachix.org"];
    trusted-substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  # Core packages needed on the system
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    cachix
  ];

  # Enable the OpenSSH daemon
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Set the state version
  system.stateVersion = "25.05";
}