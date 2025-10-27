# Firewall Configuration Module
# Verification: systemctl status nftables
#               nft list ruleset
#               iptables -L
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myNetworking.firewall;
in {
  options.myNetworking.firewall = {
    enable = mkEnableOption "firewall configuration";
  };

  config = mkIf cfg.enable {
    # Firewall configuration
    networking.nftables.enable = true;
    networking.firewall.enable = true;
  };
}
