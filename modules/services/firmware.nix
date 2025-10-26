# Firmware Update Service Module
# Verification: systemctl status fwupd
#               fwupdmgr get-devices
#               fwupdmgr get-updates
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myServices.firmware;
in
{
  options.myServices.firmware = {
    enable = mkEnableOption "firmware update service";
  };

  config = mkIf cfg.enable {
    services.fwupd.enable = true;
  };
}
