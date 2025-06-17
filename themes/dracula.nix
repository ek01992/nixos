# themes/dracula.nix
{ pkgs, config, lib, self,... }:

{
  config = {
    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";

    stylix.image = self + "/assets/dracula-wallpaper.png";
  };
}