{ self, inputs, ... }: {

  flake.nixosModules.nixxyConfiguration = { config, pkgs, lib, ... }: {

    imports = [
      self.nixosModules.nixxyHardware
      self.nixosModules.niri
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    };

    networking = {
      hostName = "nixxy";
      networkmanager.enable = true;
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

    services = {
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
      openssh.enable = true;
    };

    security.rtkit.enable = true;

    users = {
      users = {
        erik = {
          isNormalUser = true;
          description = "Erik Kowald";
          extraGroups = [ "networkmanager" "wheel" ];
          packages = with pkgs; [
            #
          ];
        };
      };
    };

    programs = {
      firefox.enable = true;
    };
    
    environment.systemPackages = with pkgs; [
      helix
      git
      bat
      curl
      wget
      nixfmt
    ];

    system.stateVersion = "26.05";
  };
}
