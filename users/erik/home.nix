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
      NIXOS_OZONE_WL = "1";
    };
  };

  wayland.windowManager.hyprland.enable = true;

  programs = {
    kitty.enable = true;
    home-manager.enable = true;
    firefox.enable = true;
    
    git = {
      enable = true;
      userName = "ek01992";
      userEmail = "ek01992@proton.me";
    };
  };
}