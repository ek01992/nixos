{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.tailscale;
in
{
  options.services.tailscale = {
    enable = mkEnableOption "Tailscale VPN service";
  };

  config = mkIf cfg.enable {
    services.tailscale.enable = true;
  };
}
