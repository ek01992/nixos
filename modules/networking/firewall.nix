# modules/networking/firewall.nix
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.myNetworking.firewall;
in {
  options.myNetworking.firewall = {
    enable = mkEnableOption "firewall configuration";
  };

  config = mkIf cfg.enable {
    networking.nftables.enable = true;
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      trustedInterfaces = [ "tailscale0" config.myNetworking.bridge.name ];
    };
  };
}
