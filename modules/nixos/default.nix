# modules/nixos/default.nix
{
  imports = [
    ./core
    ./home-manager
    ./ssh
    ./hyprland
    ./zsh
    ./greetd
    ./blueman
    ./obsidian
    ./nixvim
    ./power-management
    ./nixfmt
    ./mako
  ];
}