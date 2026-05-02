{ self, inputs, ... }:
{

  flake.nixosModules.nixxyConfiguration =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      imports = [
        self.nixosModules.nixxyHardware
        self.nixosModules.niri
        self.nixosModules.common
      ];

      boot = {
        loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };
      };

      programs = {
        firefox.enable = true;
      };

      fonts = {
        enableDefaultPackages = true;
        packages = with pkgs; [
          noto-fonts
          noto-fonts-color-emoji
        ];
      };

      services = {
        greetd = {
          enable = true;
          useTextGreeter = true;
          settings.default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
            user = "greeter";
          };
        };

        pulseaudio.enable = false;
        pipewire = {
          enable = true;
          alsa = {
            enable = true;
            support32Bit = true;
          };
          pulse.enable = true;
        };
      };

      security.rtkit.enable = true;

      networking = {
        hostName = "nixxy";
        networkmanager.enable = true;
      };

      users = {
        users = {
          erik = {
            isNormalUser = true;
            description = "Erik Kowald";
            extraGroups = [
              "networkmanager"
              "wheel"
            ];
            packages = with pkgs; [
              # Add packages
            ];
          };
        };
      };

      system.stateVersion = "26.05";
    };
}
