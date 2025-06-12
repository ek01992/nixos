{ lib, config, ... }:
let
  cfg = config.my.nixos.zsh;
in
{
  options.my.nixos.zsh.enable = lib.mkEnableOption "zsh";

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
    };
  };
}