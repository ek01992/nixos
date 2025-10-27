# modules/networking/firewall.nix
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myNetworking.firewall;
  inherit (lib) mkEnableOption mkIf;
in {
  options.myNetworking.firewall = {
    enable = mkEnableOption "firewall configuration";
  };

  config = mkIf cfg.enable {
    networking.nftables.enable = lib.mkDefault true;
    networking.firewall = {
      enable = lib.mkDefault true;
      allowedTCPPorts = lib.mkDefault [22];
      trustedInterfaces = lib.mkDefault ["tailscale0" config.myNetworking.bridge.name];
    };
  };
}
