{ config, lib, pkgs, ... }:
{
  options.nixos.obsidian.enable = lib.mkEnableOption "obsidian";

  config = lib.mkIf config.nixos.obsidian.enable {
    environment.systemPackages = with pkgs; [
      obsidian
    ];
  };
}