# themes/gruvbox.nix
{ pkgs, config, lib, self,... }:

{
  config = {
    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";

    stylix.image = self + "/assets/gruvbox-wallpaper.png";
  };
}