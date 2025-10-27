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
    ./nftables.nix
    ./tailscale.nix
  ];

  config = mkIf cfg.enable {
    # NO LOGIC HERE - category modules are pure containers
    # All configuration logic lives in submodules
  };
}
