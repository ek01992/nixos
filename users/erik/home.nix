{ pkgs, inputs, ... }:
{
  imports = [
    inputs.self.homeManagerModules.default
  ];

  home = {
    username = "erik";
    homeDirectory = "/home/erik";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;

  modules.home-manager.cli.enable = true;
  modules.home-manager.git.enable = true;
  modules.home-manager.helix.enable = true;
}