# themes/dracula.nix
{ pkgs, config, lib, self,... }:

{
  config = {
    stylix.base16Scheme = "${pkgs.schemes}/share/themes/dracula.yaml";

    stylix.image = self + "/assets/dracula-wallpaper.png";
  };
}