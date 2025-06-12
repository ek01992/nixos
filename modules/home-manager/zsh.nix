{ lib, config, pkgs, ... }:
{
  options.modules.home-manager.zsh.enable = lib.mkEnableOption "zsh";

  config = lib.mkIf config.modules.home-manager.zsh.enable {
    programs.zsh = {
      enable = true;
      enableCompletions = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
    };
  };
}