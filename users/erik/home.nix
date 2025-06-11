{ pkgs, inputs, username, ... }:
{
  imports = [
    inputs.self.homeManagerModules.default
    inputs.self.desktopModules.default
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;

  # Correctly enable your custom modules
  modules.home-manager.cli.enable = true;
  modules.home-manager.git = {
    enable = true;
    userName = "ek01992";
    userEmail = "ek01992@proton.me";
  };
  modules.home-manager.helix.enable = true;
  modules.home-manager.hyprland.enable = true;
  modules.desktop.wm.wayland.hyprland.enable = true;
}