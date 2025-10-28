# Tailscale VPN connectivity
# Enable in host config with: imports = [ ../common/optional/tailscale.nix ];
# Verification: tailscale status, tailscale ip -4
{
  config,
  lib,
  pkgs,
  ...
}: {
  services.tailscale = {
    enable = true;

    # Use secret from sops if configured
    authKeyFile =
      lib.mkIf (config.sops.secrets ? tailscale-auth)
      config.sops.secrets.tailscale-auth.path;
  };

  # Trust Tailscale interface in firewall
  networking.firewall.trustedInterfaces = ["tailscale0"];
}
