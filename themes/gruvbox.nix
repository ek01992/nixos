# themes/gruvbox.nix
{ pkgs, config, lib, self,... }:

{
  config = {
    stylix.base16Scheme = "Gruvbox Dark";

    stylix.image = self + "/assets/gruvbox-wallpaper.png";
  };
}