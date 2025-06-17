# modules/system/theme/default.nix
{ config, lib, self, ... }:
let
  themesPath = ../../../themes;

  availableThemes = lib.mapAttrs'
    (name: value: {
      name = lib.removeSuffix ".nix" name;
      value = import (themesPath + "/${name}") { inherit self; };
    })
    (lib.filterAttrs (name: _: lib.hasSuffix ".nix" name) (builtins.readDir themesPath));

  themeSettings = availableThemes."${config.theme.name}";
in
{
  options.theme.name = lib.mkOption {
    type = lib.types.enum (lib.attrNames availableThemes);
    default = "dracula";
    description = "The name of the visual theme to apply to the system.";
  };

  config = lib.mkIf (lib.elem config.theme.name (lib.attrNames availableThemes)) {
    stylix = {
      base16Scheme = themeSettings.base16Scheme;
      image = themeSettings.image;
    };
  };
}