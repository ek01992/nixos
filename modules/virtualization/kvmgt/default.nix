{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myVirtualization.kvmgt;
  inherit (lib) mkEnableOption mkIf;
in {
  options.myVirtualization.kvmgt = {
    enable = mkEnableOption "Intel GVT-g GPU virtualization";
  };

  config = mkIf cfg.enable {
    virtualisation.kvmgt.enable = lib.mkDefault true;
  };
}
