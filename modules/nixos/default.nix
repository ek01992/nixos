{ pkgs, ... }:
{
  imports = [
    ./hyprland.nix
    ./fonts.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Basic system settings
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
  nixpkgs.config.allowUnfree = true;

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