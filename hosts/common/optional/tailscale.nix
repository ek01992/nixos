# Tailscale VPN connectivity
# Enable in host config with: imports = [ ../common/optional/tailscale.nix ];
# Verification: tailscale status, tailscale ip -4, scripts/network-verify.sh
# Options: myNetworking.tailscale.useAuthKeyFile, extraUpFlags, trustInterface
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myNetworking.tailscale;
  inherit (lib) mkEnableOption mkOption mkIf types;
in {
  options.myNetworking.tailscale = {
    enable = mkEnableOption "Tailscale VPN" // { default = true; };

    useAuthKeyFile = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Use authentication key from sops secret.
        Set to false for manual authentication workflow.
      '';
    };

    extraUpFlags = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ["--ssh" "--accept-routes"];
      description = "Additional flags for tailscale up";
    };

    trustInterface = mkOption {
      type = types.bool;
      default = true;
      description = "Trust tailscale0 interface in firewall";
    };
  };

  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;

      # Use secret from sops if configured and enabled
      authKeyFile = lib.mkIf (
        cfg.useAuthKeyFile &&
        (config.sops.secrets ? tailscale-auth)
      ) config.sops.secrets.tailscale-auth.path;

      # Apply extra flags if provided
      extraUpFlags = cfg.extraUpFlags;
    };

    # Trust Tailscale interface in firewall if enabled
    networking.firewall.trustedInterfaces = lib.mkIf cfg.trustInterface ["tailscale0"];
  };
}
