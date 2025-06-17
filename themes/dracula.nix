# themes/dracula.nix
{ pkgs, config, lib, self,... }:

{
  config = {
    stylix.base16Scheme = "Dracula";

    stylix.image = self + "/assets/dracula-wallpaper.png";
  };
}