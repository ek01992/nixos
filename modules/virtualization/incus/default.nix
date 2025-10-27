# Incus Virtualization Module
# Verification: incus admin init --dump
#               incus profile list
#               incus storage list
#               incus network list
#               systemctl status incus
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myVirtualization.incus;
  inherit (lib) mkEnableOption mkOption mkIf types mkDefault;
in {
  options.myVirtualization.incus = {
    enable = mkEnableOption "Incus container and VM management";

    enableUi = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Incus web UI";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.incus = lib.mkDefault {
      enable = true;
      ui.enable = cfg.enableUi;
      package = pkgs.incus;
    };
  };

  imports = [
    ./preseed
  ];
}
