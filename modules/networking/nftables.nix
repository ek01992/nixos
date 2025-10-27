# Nftables Configuration Module
# Verification: systemctl status nftables
#               nft list ruleset
#               nft list tables
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myNetworking.nftables;
in {
  options.myNetworking.nftables = {
    enable = mkEnableOption "nftables firewall";
  };

  config = mkIf cfg.enable {
    networking.nftables.enable = true;
  };
}
