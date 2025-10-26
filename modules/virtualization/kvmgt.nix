{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myVirtualisation.kvmgt;
in
{
  options.myVirtualisation.kvmgt = {
    enable = mkEnableOption "Intel GVT-g GPU virtualization";
  };

  config = mkIf cfg.enable {
    virtualisation.kvmgt.enable = true;
  };
}
