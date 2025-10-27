# Tailscale VPN Configuration Module
# Verification: systemctl status tailscaled
#               tailscale status
#               tailscale ip
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myNetworking.tailscale;
  inherit (lib) mkEnableOption mkIf mkDefault;
in {
  options.myNetworking.tailscale = {
    enable = mkEnableOption "Tailscale VPN";
  };

  config = mkIf cfg.enable {
    # Tailscale VPN
    services.tailscale.enable = lib.mkDefault true;
  };
}
