{ lib, config, ... }:
let
  cfg = config.nixos.zsh;
in
{
  options.nixos.zsh.enable = lib.mkEnableOption "zsh";

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        c = "clear";
        mkdir = "mkdir -vp";
        rm = "rm -rifv";
        mv = "mv -iv";
        cp = "cp -riv";
        cat = "bat --paging=never --style=plain";
        ls = "eza -a --icons";
        tree = "eza --tree --icons";
        # nd = "nix develop -c $SHELL";
        rebuild = "sudo nixos-rebuild switch --fast; notify-send 'Rebuild complete\!'";
      };
    };
  };
}