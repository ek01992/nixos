# modules/system/theme/default.nix
{ config, lib,... }:

let
  themePath = ../../../themes + "/${config.theme.name}.nix";
in
{
  options.theme.name = lib.mkOption {
    type = lib.types.str;
    default = "dracula";
    description = "The name of the visual theme to apply to the system. This must correspond to a file in the `themes/` directory.";
    example = "gruvbox";
  };

  imports = [
    (lib.mkIf (builtins.pathExists themePath) themePath)
  ];
}