{ pkgs, inputs, config, ... }:
{
  imports = [
    inputs.self.homeModules.default
  ];

  home.stateVersion = "25.05";

  my = {
    cli = {
      common.enable = true;
      git = {
        enable = true;
        userName = "ek01992";
        userEmail = "ek01992@proton.me";
      };
      zsh.enable = true;
    };
    gui = {
      hyprland.enable = true;
      zen-browser.enable = true;
      stylix.enable = true;
      kitty.enable = true;
    };
  };
}