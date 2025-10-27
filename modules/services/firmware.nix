# Firmware Update Service Module
# Verification: systemctl status fwupd
#               fwupdmgr get-devices
#               fwupdmgr get-updates
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myServices.firmware;
  inherit (lib) mkEnableOption mkIf;
in {
  options.myServices.firmware = {
    enable = mkEnableOption "firmware update service";
  };

  config = mkIf cfg.enable {
    services.fwupd.enable = true;
  };
}
