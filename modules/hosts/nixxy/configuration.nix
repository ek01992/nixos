{ self, inputs, ... }: {

  flake.nixosModules.nixxyConfiguration = { config, pkgs, lib, ... }: {

    imports = [
      self.nixosModules.nixxyHardware
      self.nixosModules.niri
      self.nixosModules.nixxyClaudeConfig
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    };

    environment.systemPackages = with pkgs; [
      # Add System Package
      claude-code
      bun
      git
      helix
      wget
      curl
      bat
      fastfetch
      nixfmt
      uv
    ];


    programs = {
      firefox.enable = true;
    };

    services = {
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
      };
      openssh.enable = true;
    };

    nixpkgs.config.allowUnfree = true;
    
    security.rtkit.enable = true;

    time.timeZone = "America/Chicago";

    networking = {
      hostName = "nixxy";
      networkmanager.enable = true;
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
          extraGroups = [ "networkmanager" "wheel" ];
          packages = with pkgs; [
            # Add packages
          ];
        };
      };
    };

    system.stateVersion = "26.05";
  };
}
