{ self, inputs, ... }:
{
  flake.nixosModules.common =
    { pkgs, lib, ... }:
    {
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      environment.systemPackages = with pkgs; [
        git
        wget
        curl
        bat
        fastfetch
        nixfmt
        nixfmt-tree
      ];

      nixpkgs.config.allowUnfree = true;

      services.openssh.enable = true;

      time.timeZone = "America/Chicago";

      i18n = {
        defaultLocale = "en_US.UTF-8";
        extraLocaleSettings = {
          LC_ADDRESS = "en_US.UTF-8";
          LC_IDENTIFICATION = "en_US.UTF-8";
          LC_MEASUREMENT = "en_US.UTF-8";
          LC_MONETARY = "en_US.UTF-8";
          LC_NAME = "en_US.UTF-8";
          LC_NUMERIC = "en_US.UTF-8";
          LC_PAPER = "en_US.UTF-8";
          LC_TELEPHONE = "en_US.UTF-8";
          LC_TIME = "en_US.UTF-8";
        };
      };
    };
}
