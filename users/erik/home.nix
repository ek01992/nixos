{ pkgs, inputs, config, ... }:
{
  imports = [
    inputs.self.homeManagerModules.default
  ];

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  my = {
    cli = {
      common.enable = true;
      git = {
        enable = true;
        userName = "ek01992";
        userEmail = "ek01992@proton.me";
      };
      zsh.enable = true;
      kitty.enable = true;
    };
    gui = {
      hyprland.enable = true;
      zen-browser.enable = true;
    };
  };
}