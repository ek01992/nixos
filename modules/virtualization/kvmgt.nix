{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.virtualisation.kvmgt;
in
{
  options.virtualisation.kvmgt = {
    enable = mkEnableOption "Intel GVT-g GPU virtualization";
  };

  config = mkIf cfg.enable {
    virtualisation.kvmgt.enable = true;
  };
}
