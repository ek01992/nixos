# modules/nixos/zsh/default.nix
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
        cd = "z";
        reboot = "sudo reboot now";
        shutdown = "sudo shutdown now";
        mkdir = "mkdir -vp";
        rm = "rm -rifv";
        mv = "mv -iv";
        cp = "cp -riv";
        cat = "bat --paging=never --style=plain";
        ls = "eza -a --icons";
        tree = "eza --tree --icons";
        # nd = "nix develop -c $SHELL";
        rebuild = "sudo nixos-rebuild switch";
        upgrade = "sudo nixos-rebuild switch --upgrade";
      };
    };
  };
}