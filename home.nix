{ inputs, config, pkgs, ... }:

{
  imports = [
    inputs.impermanence.homeManagerModules.impermanence
  ];

  home = {
    username = "erik";
    homeDirectory = "/home/erik";
    stateVersion = "25.05";
    packages = with pkgs; [
      hello
    ];
    sessionVariables = { EDITOR = "helix"; };
  };

  home.persistence."/persist/home/erik" = {
    allowOther = true;
    directories = [
      "downloads"
      "desktop"
      "public"
      "music"
      "pictures"
      ".ssh"
      "videos"
      "documents"
    ];

    files = [
      ".bash_history"
    ];
  };
  
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "ek01992";
    userEmail = "ek01992@proton.me";
  };
}