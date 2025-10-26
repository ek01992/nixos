{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myVirtualization;
in
{
  options.myVirtualization = {
    enable = mkEnableOption "virtualization configuration";
  };

  imports = [
    ./kvmgt.nix
    ./incus.nix
  ];
}
