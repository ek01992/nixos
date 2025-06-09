{ pkgs, ... }: {
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  home.stateVersion = "25.05";

  # Let Home Manager manage my shell configuration.
  programs.home-manager.enable = true;

  # Your user-specific packages.
  home.packages = with pkgs; [
    helix
    htop
  ];

  # Configure user-specific programs.
  programs.git = {
    enable = true;
    userName = "ek01992";
    userEmail = "ek01992@proton.me";
  };
  programs.chromium = {
    enable = true;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
    ];
  };

  # Set user-specific environment variables.
  home.sessionVariables = {
    EDITOR = "hx";
  };
}