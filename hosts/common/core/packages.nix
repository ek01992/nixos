# System-wide packages available on all hosts
# Host-specific packages go in hosts/<hostname>/default.nix
# Verification: which vim git htop
{
  config,
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    htop
    tree
    tmux
    alejandra
  ];
}
