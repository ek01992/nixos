# configuration.nix
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./disk-config.nix
    ./impermanence.nix
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
  ];

  networking.hostName = "xps"; # This will match the `hostname` of your flake

  networking.networkmanager.enable = true;

  boot.loader.systemd-boot.enable = true; # (for UEFI systems only)
  boot.loader.efi.canTouchEfiVariables = true;
  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #   wget
    git
    helix
  ];

  time.timeZone = "America/Chicago";

  users.users.erik = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Add "wheel" for sudo access
    initialPassword = "temp"; # <-- This is where it goes!
    # home = "/home/nixos"; # Optional: Disko typically handles home subvolumes
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPakom6FvoSpBc0nmunHQUZwQI9VtS52i4W4WLuiUMpc ek01992@proton.me"
    ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users.erik = import ./home.nix;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
    };
  };

  console.keyMap = "us";

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.05";
}