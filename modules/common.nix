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
        wget
        curl
        bat
        fastfetch
        nixfmt
        nixfmt-tree
      ];

      programs.git = {
        enable = true;
        config = {
          user = {
            name = "Erik";
            email = "erik@cyberworkforce.com";
          };
          init.defaultBranch = "main";
        };
      };

      programs.bash.shellAliases = {
        nrb = "nixos-rebuild build --flake $HOME/nixos";
        nrs = "sudo nixos-rebuild switch --flake $HOME/nixos";
        nfc = "nix flake check";
        nfu = "nix flake update";
      };

      nixpkgs.config.allowUnfree = true;

      services.openssh.enable = true;

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 22 ];
      };

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
