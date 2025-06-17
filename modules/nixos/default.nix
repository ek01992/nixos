# modules/nixos/default.nix
{
  imports = [
    ./core
    ./home-manager
    ./ssh
    ./hyprland
    ./zsh
    ./greetd
    ./obsidian
    ./nixvim
    ./power-management
  ];
}