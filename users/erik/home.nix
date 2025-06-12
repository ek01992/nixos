{ pkgs, inputs, username, ... }:
{
  imports = [
    # This now imports all modules under the 'my' namespace
    inputs.self.homeManagerModules.default
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;

  # This is where you enable and configure your custom modules
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
    };
  };
}