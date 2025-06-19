# modules/home-manager/gui/default.nix
{
  imports = [
    ./hyprland
    ./firefox
    ./stylix
    ./kitty
    ./cursor
    ./waybar
  ];
}