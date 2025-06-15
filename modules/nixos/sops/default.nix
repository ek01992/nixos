{ config, lib, pkgs, inputs, ... }:
{
  options.nixos.sops.enable = lib.mkEnableOption "sops";

  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  config = lib.mkIf config.nixos.sops.enable {
    sops = {
      # TODO: Add sops config
    };
  };
}