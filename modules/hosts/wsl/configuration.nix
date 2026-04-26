{ self, inputs, ... }:
{

  flake.nixosModules.nixos-wslConfiguration =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      imports = [
        self.nixosModules.nixos-wslHardware
        inputs.nixos-wsl.nixosModules.default
      ];

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      wsl = {
        enable = true;
        defaultUser = "erik";
        interop.includePath = false;
      };

      environment.systemPackages = with pkgs; [
        # Add System Packages
        git
        wget
        curl
        bat
        fastfetch
        nixfmt
        nixfmt-tree
      ];

      programs = {
        # programName = {
        #   enable = true;
        #   ...
        # };
      };

      services = {
        # serviceName = {
        #   enable - true;
        #   ...
        # };
      };

      time.timeZone = "America/Chicago";

      networking.hostName = "nixos-wsl";

      fileSystems."/shared" = {
        device = "/mnt/d/wsl/shared";
        fsType = "none";
        options = [
          "bind"
          "nofail"
        ];
      };

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

      users = {
        users = {
          erik = {
            isNormalUser = true;
            description = "Erik Kowald";
            extraGroups = [ "wheel" ];
            packages = with pkgs; [
              # Add User-Specific Packages
            ];
          };
        };
      };

      system.stateVersion = "26.05";
    };
}
