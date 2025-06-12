{ lib, config, ... }:
{
  options.modules.nixos.zsh.enable = lib.mkEnableOption "zsh";

  config = lib.mkIf config.modules.nixos.zsh.enable {
    programs.zsh.enable = true;
  };
}