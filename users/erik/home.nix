{ pkgs, ... }:
{
  imports = [
    ./hyprland.nix
  ];

  home = {
    username = "erik";
    homeDirectory = "/home/erik";
    stateVersion = "25.05";
    packages = with pkgs; [
      helix
      htop
    ];
    sessionVariables = {
      EDITOR = "hx";
      NIXOS_OZONE_WL = "1";
    };
  };

  programs = {
    # Enable home-manager
    home-manager.enable = true;

    # Browser
    firefox.enable = true;

    # Shell tools
    kitty.enable = true;
    git = {
      enable = true;
      userName = "ek01992";
      userEmail = "ek01992@proton.me";
    };
  };
}