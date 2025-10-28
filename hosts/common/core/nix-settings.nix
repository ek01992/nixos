# Nix daemon and flakes configuration
# Applied to all hosts to ensure consistent build behavior
# Verification: cat /etc/nix/nix.conf
{
  config,
  lib,
  pkgs,
  ...
}: {
  nix = {
    settings = {
      # Enable flakes and new nix command
      experimental-features = ["nix-command" "flakes"];
      # Auto-optimize store by hard-linking identical files
      auto-optimise-store = true;
      # Binary caches for faster rebuilds
      substituters = [
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      # Allow wheel group to use nix commands
      trusted-users = ["root" "@wheel"];
    };
    # Automatic garbage collection prevents /nix/store bloat
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = lib.mkDefault true;
}
