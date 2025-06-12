{ lib, config, pkgs, ... }:
{
  options.modules.home-manager.zsh.enable = lib.mkEnableOption "zsh";

  config = lib.mkIf config.modules.home-manager.zsh.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;
      syntaxHighlighting.enable = true;
      oh-my-zsh = {
        enable = true;
      };
    };
  };
}