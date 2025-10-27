# Networking Configuration Module
# Verification: ip link show
#               systemctl status systemd-networkd
#               networkctl status
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myNetworking;
  inherit (lib) mkEnableOption;
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
