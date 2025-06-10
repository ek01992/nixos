{ pkgs, ... }: {
  imports = [
    ./hyprland.nix
  ];
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
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

  # Configure user-specific programs.
  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      userName = "ek01992";
      userEmail = "ek01992@proton.me";
    };
    chromium = {
      enable = true;
      extensions = [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      ];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;

  };
}