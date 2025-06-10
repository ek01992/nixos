{ pkgs, ... }: 
{
  imports = [
    ./hyprland.nix
  ];

  home = {
    stateVersion = "25.05";
    packages = with pkgs; [
      helix
      htop
    ];
    sessionVariables = {
      EDITOR = "hx";
    };
  };
  programs = {
    kitty.enable = true;
    home-manager.enable = true;
    git = {
      enable = true;
      userName = "ek01992";
      userEmail = "ek01992@proton.me";
    };
    chromium = {
      enable = true;
      extensions = [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm"
      ];
    };
  };
}