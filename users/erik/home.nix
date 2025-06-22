# users/erik/home.nix
{ pkgs, inputs, config, ... }:
{
  imports = [
    inputs.self.homeModules.default
  ];

  home.stateVersion = "25.05";

  cli = {
    git = {
      enable = true;
      userName = "ek01992";
      userEmail = "ek01992@proton.me";
    };
    zsh.enable = true;
    zoxide.enable = true;
    starship.enable = true;
  };
  gui = {
    hyprland.enable = true;
    firefox.enable  = true;
    stylix.enable = true;
    kitty.enable = true;
    cursor.enable = true;
    waybar.enable = true;
    rofi.enable = true;
  };
}