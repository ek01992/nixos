# Networking Configuration Module
# Verification: ip link show
#               systemctl status systemd-networkd
#               networkctl status
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myNetworking;
in {
  options.myNetworking = {
    enable = mkEnableOption "networking configuration";
  };

  imports = [
    ./core.nix
    ./bridge.nix
    ./firewall.nix
    ./tailscale.nix
  ];
}
