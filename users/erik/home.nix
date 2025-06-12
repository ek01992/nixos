{ pkgs, inputs, username, ... }:
{
  imports = [
    inputs.self.homeManagerModules.default
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;

  modules.home-manager = {
    pkgs.enable = true;
    git = {
      enable = true;
      userName = "ek01992";
      userEmail = "ek01992@proton.me";
    };
    helix.enable = true;
    zen-browser.enable = true;
    zsh.enable = true;
    hyprland.enable = true;
  };
}