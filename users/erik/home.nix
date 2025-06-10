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
      spacefetch
    ];
    sessionVariables = {
      EDITOR = "hx";
      NIXOS_OZONE_WL = "1";
    };
  };

  programs = {
    home-manager.enable = true;
    firefox.enable = true;
    kitty.enable = true;
    git = {
      enable = true;
      userName = "ek01992";
      userEmail = "ek01992@proton.me";
    };
  };
}