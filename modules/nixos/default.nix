{ pkgs, ... }:
{
  imports = [
    ./hyprland.nix
    ./fonts.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    cachix
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  system.stateVersion = "25.05";
}